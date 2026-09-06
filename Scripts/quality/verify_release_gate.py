#!/usr/bin/env python3
"""Fail closed for a stable release with incomplete device or performance evidence."""
import argparse
from collections import Counter
import json
from pathlib import Path
import sys
from fingerprint import source_fingerprint
from measure import BUDGETS

ROOT = Path(__file__).resolve().parents[2]
REQUIRED_CASES = ["notched_hover", "notched_click", "notched_activity", "notched_keyboard",
                  "notched_sleep_wake", "external_hover", "external_click", "external_activity",
                  "external_keyboard", "cross_screen_wake"]


def validate(version, root=ROOT):
    if int(version.split(".")[0]) < 1:
        return []
    path = root / "docs/quality" / f"{version}.json"
    if not path.is_file():
        return [f"Missing quality record: {path.relative_to(root)}"]
    report = json.loads(path.read_text())
    errors = []
    if report.get("version") != version:
        errors.append(f"Quality record version does not match requested release: {version}")
    if report.get("display_state_validation") != "passed":
        errors.append("Confirm the performance samples were taken with the display unlocked and on")
    fingerprint = source_fingerprint(root)
    if report.get("source_fingerprint") != fingerprint:
        errors.append("Device evidence does not match the current runtime source fingerprint")
    for name in REQUIRED_CASES:
        case = report.get("hardware", {}).get(name, {})
        if case.get("status") == "failed":
            errors.append(f"Hardware acceptance failed: {name}")
        elif case.get("status") != "passed" or case.get("actual_hardware") is not True:
            errors.append(f"Hardware acceptance pending: {name}")
        if case.get("source_fingerprint") != fingerprint:
            errors.append(f"Device evidence is stale for current sources: {name}")
        evidence = case.get("evidence", [])
        if not evidence or any(not (root / p).is_file() for p in evidence):
            errors.append(f"Missing device evidence: {name}")
    performance_path = report.get("performance_report")
    if not performance_path or not (root / performance_path).is_file():
        errors.append("Missing standalone performance report")
        return errors
    performance = json.loads((root / performance_path).read_text())
    if performance.get("build", {}).get("source_fingerprint") != fingerprint:
        errors.append("Performance measurements are stale for this source tree")
    counts = Counter()
    for run in performance.get("runs", []):
        scenario = run.get("scenario")
        if scenario not in BUDGETS:
            errors.append("Unknown performance scenario")
            continue
        counts[scenario] += 1
        samples = run.get("samples", [])
        if len(samples) < 31 or run.get("uninterrupted") is not True or run.get("display_visible") is not True:
            errors.append(f"Interrupted or incomplete sample: {scenario}")
            continue
        if any(s.get("screen_locked") is True or s.get("on_console") is not True or s.get("logged_in") is not True for s in samples):
            errors.append(f"Missing or locked console-session evidence: {scenario}")
            continue
        import math
        a, b = samples[0], samples[-1]
        elapsed = b["time"] - a["time"]
        if elapsed < 30 or any(y["time"] <= x["time"] or y["cpu_ns"] < x["cpu_ns"] for x, y in zip(samples, samples[1:])):
            errors.append(f"Invalid counter sequence: {scenario}")
            continue
        cpus = sorted((y["cpu_ns"] - x["cpu_ns"]) / ((y["time"] - x["time"]) * 1e9) * 100 for x, y in zip(samples, samples[1:]))
        metrics = {"cpu_mean_percent": (b["cpu_ns"] - a["cpu_ns"]) / elapsed / 1e9 * 100,
                   "cpu_p95_percent": cpus[math.ceil(0.95 * len(cpus)) - 1],
                   "interrupt_wakeups_per_second": (b["interrupt_wakeups"] - a["interrupt_wakeups"]) / elapsed}
        for metric, limit in BUDGETS[scenario].items():
            if not math.isfinite(metrics[metric]) or metrics[metric] < 0 or metrics[metric] > limit:
                errors.append(f"Resource budget failed: {scenario} {metric}={metrics[metric]:.3f} limit={limit}")
    for scenario in BUDGETS:
        if counts[scenario] < 2:
            errors.append(f"Need two independent samples: {scenario}")
    return errors


def has_recorded_release_exception(version, errors, root=ROOT):
    """Honor only this version's recorded owner decision for this runtime build.

    Measured failures, unreadable reports and changed sources remain blockers.
    The owner's original request and exact outstanding checks must match the
    reviewed release record; a previous version's exception never carries over.
    """
    if not errors or not all(isinstance(error, str) for error in errors):
        return False
    try:
        record = json.loads((root / "docs/quality" / f"{version}.json").read_text())
        fingerprint = source_fingerprint(root)
    except (OSError, ValueError, TypeError):
        return False
    if not isinstance(record, dict):
        return False
    exception = record.get("release_exception", {})
    owner_request = record.get("owner_release_request", {})
    if not isinstance(exception, dict) or not isinstance(owner_request, dict):
        return False
    accepted = exception.get("accepted_pending_checks")
    request = owner_request.get("request")
    if not isinstance(accepted, list) or not all(isinstance(item, str) for item in accepted):
        return False
    if not isinstance(request, str) or not request.strip():
        return False
    pending_prefixes = (
        "Confirm the performance samples were taken with the display unlocked and on",
        "Hardware acceptance pending: ",
        "Device evidence is stale for current sources: ",
        "Missing device evidence: ",
        "Need two independent samples: ",
    )
    return (
        record.get("version") == version
        and record.get("source_fingerprint") == fingerprint
        and owner_request.get("version") == version
        and owner_request.get("requested_by") == "project_owner"
        and exception.get("version") == version
        and exception.get("decision") == "publish_with_pending_acceptance"
        and exception.get("authorized_by") == "project_owner"
        and exception.get("request") == request
        and isinstance(exception.get("reason"), str)
        and bool(exception["reason"].strip())
        and exception.get("source_fingerprint") == fingerprint
        and sorted(accepted) == sorted(errors)
        and all(error.startswith(pending_prefixes) for error in errors)
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("version")
    parser.add_argument("--strict", action="store_true", help="Report all acceptance gaps, ignoring any recorded exception for this release")
    args = parser.parse_args()
    try:
        version = args.version.removeprefix("v")
        errors = validate(version)
        if errors and not args.strict and has_recorded_release_exception(version, errors):
            print(f"Release authorized with pending acceptance (recorded {version} exception):\n- " + "\n- ".join(errors))
            return 0
    except (ValueError, KeyError, TypeError, OSError) as error:
        errors = [f"Invalid or unreadable quality evidence: {error}"]
    if errors:
        print("Release quality gate blocked:\n- " + "\n- ".join(errors), file=sys.stderr)
        return 1
    print("Release quality gate passed")
    return 0

if __name__ == "__main__":
    sys.exit(main())
