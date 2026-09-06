import copy
from contextlib import redirect_stderr, redirect_stdout
import io
import json
import plistlib
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from fingerprint import source_fingerprint
from verify_release_gate import REQUIRED_CASES, validate, has_recorded_release_exception, main


class ReleaseGateTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        (self.root / "Package.swift").write_text("fixture")
        (self.root / "docs/quality").mkdir(parents=True)
        (self.root / "docs/quality/evidence.txt").write_text("Synthetic verifier test, not hardware evidence")
        fingerprint = source_fingerprint(self.root)
        self.record = {"version": "1.0.0", "display_state_validation": "passed", "source_fingerprint": fingerprint, "performance_report": "docs/quality/performance.json",
                       "hardware": {name: {"status": "passed", "actual_hardware": True, "source_fingerprint": fingerprint,
                                    "evidence": ["docs/quality/evidence.txt"]} for name in REQUIRED_CASES}}
        self.performance = {"build": {"source_fingerprint": fingerprint}, "runs": []}
        for index, scenario in enumerate(["idle", "focus", "meeting-switch"] * 2):
            self.performance["runs"].append({"scenario": scenario, "uninterrupted": True, "display_visible": True,
                "samples": [{"time": index * 100 + second, "cpu_ns": second * 1_000_000,
                             "interrupt_wakeups": 0, "screen_locked": False, "on_console": True, "logged_in": True} for second in range(31)]})

    def check(self, version="1.0.0"):
        (self.root / "docs/quality" / f"{version}.json").write_text(json.dumps(self.record))
        (self.root / "docs/quality/performance.json").write_text(json.dumps(self.performance))
        return validate(version, self.root)

    def testReleaseLabelsDoNotMaskRuntimeIdentityChanges(self):
        support = self.root / "Support"
        support.mkdir()
        path = support / "Info.plist"
        info = {"CFBundleIdentifier": "quality.fixture", "CFBundleShortVersionString": "0.9.0", "CFBundleVersion": "21"}
        path.write_bytes(plistlib.dumps(info))
        original = source_fingerprint(self.root)
        info.update(CFBundleShortVersionString="1.0.0", CFBundleVersion="22")
        path.write_bytes(plistlib.dumps(info))
        self.assertEqual(source_fingerprint(self.root), original)
        info["CFBundleIdentifier"] = "different.identity"
        path.write_bytes(plistlib.dumps(info))
        self.assertNotEqual(source_fingerprint(self.root), original)

    def testCompleteEvidencePasses(self):
        self.assertEqual(self.check(), [])

    def testMissingExternalDeviceCannotBeWaivedByStatus(self):
        self.record["hardware"]["cross_screen_wake"]["actual_hardware"] = False
        self.assertTrue(any("cross_screen_wake" in error for error in self.check()))

    def testChangedCodeInvalidatesBothEvidenceSets(self):
        (self.root / "Package.swift").write_text("changed")
        self.assertTrue(any("fingerprint" in error for error in self.check()))
        self.assertTrue(any("stale" in error for error in self.check()))

    def testPassingBooleanCannotMaskCpuFailure(self):
        run = self.performance["runs"][0]
        run["passed"] = True
        for index, sample in enumerate(run["samples"]):
            sample["cpu_ns"] = index * 1_000_000_000
        self.assertTrue(any("Resource budget failed" in error for error in self.check()))

    def testInterruptedAndShortSamplesAreRejected(self):
        self.performance["runs"][0]["uninterrupted"] = False
        self.performance["runs"][1]["samples"] = self.performance["runs"][1]["samples"][:10]
        self.assertEqual(sum("Interrupted or incomplete" in error for error in self.check()), 2)

    def testUnknownDisplayStateBlocksRelease(self):
        self.record["display_state_validation"] = "pending"
        self.assertTrue(any("display unlocked" in error for error in self.check()))

    def testMissingEvidenceFileIsRejected(self):
        (self.root / "docs/quality/evidence.txt").unlink()
        self.assertTrue(any("Missing device evidence" in error for error in self.check()))

    def recordException(self, errors, version="1.0.0"):
        request = f"Release {version} with the disclosed pending checks"
        self.record["owner_release_request"] = {
            "version": version, "requested_by": "project_owner", "request": request,
        }
        self.record["release_exception"] = {
            "version": version, "decision": "publish_with_pending_acceptance",
            "authorized_by": "project_owner", "request": request,
            "reason": "Outstanding hardware acceptance disclosed in the release notes",
            "source_fingerprint": source_fingerprint(self.root),
            "accepted_pending_checks": errors,
        }
        self.check(version)

    def testExplicitExceptionPreservesStrictAcceptanceFailures(self):
        self.record["hardware"]["external_hover"]["status"] = "pending"
        errors = self.check()
        self.recordException(errors)
        self.assertEqual(self.check(), errors)
        self.assertTrue(has_recorded_release_exception("1.0.0", errors, self.root))
        self.assertFalse(has_recorded_release_exception("1.0.1", errors, self.root))

    def testChangedSourcesAndNewGapsInvalidateException(self):
        self.record["display_state_validation"] = "pending"
        self.recordException(self.check())
        self.record["hardware"]["external_hover"]["status"] = "pending"
        self.assertFalse(has_recorded_release_exception("1.0.0", self.check(), self.root))
        (self.root / "Package.swift").write_text("new runtime")
        self.assertFalse(has_recorded_release_exception("1.0.0", self.check(), self.root))

    def testRecordedExceptionCannotWaiveMeasuredBudgetFailure(self):
        for index, sample in enumerate(self.performance["runs"][0]["samples"]):
            sample["cpu_ns"] = index * 1_000_000_000
        errors = self.check()
        self.recordException(errors)
        self.assertFalse(has_recorded_release_exception("1.0.0", errors, self.root))

    def testEachVersionRequiresItsOwnMatchingOwnerRequestAndException(self):
        self.record["version"] = "1.1.0"
        self.record["display_state_validation"] = "pending"
        errors = self.check("1.1.0")
        self.recordException(errors, version="1.1.0")
        self.assertTrue(has_recorded_release_exception("1.1.0", errors, self.root))
        self.assertFalse(has_recorded_release_exception("1.0.0", errors, self.root))
        self.assertFalse(has_recorded_release_exception("1.2.0", errors, self.root))
        self.assertEqual(self.check("1.1.0"), errors, "Strict acceptance remains pending")

    def testCopyingAnOlderExceptionDoesNotAuthorizeANewRelease(self):
        self.record["display_state_validation"] = "pending"
        self.recordException(self.check())
        self.record["version"] = "1.1.0"
        self.record["source_fingerprint"] = source_fingerprint(self.root)
        self.record["release_exception"]["version"] = "1.1.0"
        errors = self.check("1.1.0")
        self.assertFalse(has_recorded_release_exception("1.1.0", errors, self.root), "The owner request still belongs to 1.0.0")

    def testMissingMalformedAndIncompleteRecordsFailClosed(self):
        errors = ["Need two independent samples: idle"]
        path = self.root / "docs/quality/1.1.0.json"
        for payload in [None, "{", "[]", "{}", '{"release_exception": true}']:
            with self.subTest(payload=payload):
                if payload is None:
                    self.assertFalse(path.exists())
                else:
                    path.write_text(payload)
                self.assertFalse(has_recorded_release_exception("1.1.0", errors, self.root))

    def testOwnerRequestMustMatchTheRecordedOriginalExactly(self):
        self.record["display_state_validation"] = "pending"
        errors = self.check()
        self.recordException(errors)
        original = copy.deepcopy(self.record)
        for key, value in [("request", "A different request"), ("requested_by", "contributor"), ("version", "1.1.0")]:
            with self.subTest(key=key):
                self.record = copy.deepcopy(original)
                self.record["owner_release_request"][key] = value
                self.check()
                self.assertFalse(has_recorded_release_exception("1.0.0", errors, self.root))

    def testRecordedExceptionCannotWaiveActualHardwareFailure(self):
        self.record["hardware"]["notched_click"]["status"] = "failed"
        errors = self.check()
        self.assertIn("Hardware acceptance failed: notched_click", errors)
        self.recordException(errors)
        self.assertFalse(has_recorded_release_exception("1.0.0", errors, self.root))

    def testRecordedExceptionCannotWaiveInterruptedOrLockedSamples(self):
        for field, value in [("uninterrupted", False), ("screen_locked", True)]:
            with self.subTest(field=field):
                if field == "uninterrupted":
                    self.performance["runs"][0][field] = value
                else:
                    self.performance["runs"][0]["uninterrupted"] = True
                    self.performance["runs"][0]["samples"][0][field] = value
                errors = self.check()
                self.recordException(errors)
                self.assertFalse(has_recorded_release_exception("1.0.0", errors, self.root))

    def testRecordAndExceptionFingerprintsMustBothMatchRuntime(self):
        self.record["display_state_validation"] = "pending"
        errors = self.check()
        self.recordException(errors)
        original = copy.deepcopy(self.record)
        for name in [None, "release_exception"]:
            self.record = copy.deepcopy(original)
            section = self.record if name is None else self.record[name]
            section["source_fingerprint"] = "old-runtime"
            self.check()
            self.assertFalse(has_recorded_release_exception("1.0.0", errors, self.root))
        self.record = copy.deepcopy(original)
        self.record["version"] = "1.1.0"
        self.assertTrue(any("record version" in error for error in self.check()))
        self.assertFalse(has_recorded_release_exception("1.0.0", errors, self.root))

    def testStrictCommandNeverAcceptsARecordedReleaseException(self):
        errors = ["Need two independent samples: idle"]
        with patch("verify_release_gate.validate", return_value=errors), \
                patch("verify_release_gate.has_recorded_release_exception", return_value=True) as exception_check:
            with patch("sys.argv", ["verify_release_gate.py", "1.1.0", "--strict"]), redirect_stderr(io.StringIO()):
                self.assertEqual(main(), 1)
                exception_check.assert_not_called()
            with patch("sys.argv", ["verify_release_gate.py", "1.1.0"]), redirect_stdout(io.StringIO()) as output:
                self.assertEqual(main(), 0)
                self.assertIn("recorded 1.1.0 exception", output.getvalue())


if __name__ == "__main__":
    unittest.main()
