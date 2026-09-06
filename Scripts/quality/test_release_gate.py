import copy
import json
import plistlib
from pathlib import Path
import tempfile
import unittest

from fingerprint import source_fingerprint
from verify_release_gate import REQUIRED_CASES, validate


class ReleaseGateTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        (self.root / "Package.swift").write_text("fixture")
        (self.root / "docs/quality").mkdir(parents=True)
        (self.root / "docs/quality/evidence.txt").write_text("Synthetic verifier test, not hardware evidence")
        fingerprint = source_fingerprint(self.root)
        self.record = {"display_state_validation": "passed", "source_fingerprint": fingerprint, "performance_report": "docs/quality/performance.json",
                       "hardware": {name: {"status": "passed", "actual_hardware": True, "source_fingerprint": fingerprint,
                                    "evidence": ["docs/quality/evidence.txt"]} for name in REQUIRED_CASES}}
        self.performance = {"build": {"source_fingerprint": fingerprint}, "runs": []}
        for index, scenario in enumerate(["idle", "focus", "meeting-switch"] * 2):
            self.performance["runs"].append({"scenario": scenario, "uninterrupted": True, "display_visible": True,
                "samples": [{"time": index * 100 + second, "cpu_ns": second * 1_000_000,
                             "interrupt_wakeups": 0, "screen_locked": False, "on_console": True, "logged_in": True} for second in range(31)]})

    def check(self):
        (self.root / "docs/quality/1.0.0.json").write_text(json.dumps(self.record))
        (self.root / "docs/quality/performance.json").write_text(json.dumps(self.performance))
        return validate("1.0.0", self.root)

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


if __name__ == "__main__":
    unittest.main()
