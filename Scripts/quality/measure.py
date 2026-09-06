#!/usr/bin/env python3
"""Measure the optimized standalone native quality app; never accesses a real calendar."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import signal
import sys
import subprocess
import time

ROOT = Path(__file__).resolve().parents[2]
# Set before the baseline. CPU uses one logical core = 100%.
BUDGETS = {
    "idle": {"cpu_mean_percent": 0.5, "cpu_p95_percent": 2.0, "interrupt_wakeups_per_second": 1.0},
    "focus": {"cpu_mean_percent": 2.0, "cpu_p95_percent": 5.0, "interrupt_wakeups_per_second": 5.0},
    "meeting-switch": {"cpu_mean_percent": 3.0, "cpu_p95_percent": 8.0, "interrupt_wakeups_per_second": 10.0},
}


def measure(scenario, output, seconds, sampler, env, app):
    output.mkdir(parents=True, exist_ok=False)
    run_env = dict(env, NOTCH_QUALITY_SCENARIO=scenario, NOTCH_QUALITY_OUTPUT=str(output),
                   NOTCH_QUALITY_SECONDS=str(seconds + 3))
    with (output / "test.log").open("w") as log:
        process = subprocess.Popen([str(app / "Contents/MacOS/NotchCalendar")],
                                   cwd=ROOT, env=run_env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        display_assertion = subprocess.Popen(["caffeinate", "-d", "-w", str(process.pid)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        try:
            deadline = time.monotonic() + 40
            ready = output / "state.json"
            while not ready.exists():
                if process.poll() is not None or time.monotonic() > deadline:
                    raise RuntimeError(f"Probe did not start; see {output / 'test.log'}")
                time.sleep(0.1)
            state = json.loads(ready.read_text())
            samples = []
            for index in range(seconds + 1):
                samples.append(json.loads(subprocess.check_output([str(sampler), str(state["pid"])], text=True)))
                if samples[-1].get("screen_locked") is True:
                    raise RuntimeError("Screen locked: unlock the Mac manually before acceptance sampling")
                if index < seconds:
                    time.sleep(1)
            code = process.wait(timeout=15)
            if code != 0:
                raise RuntimeError(f"Native probe failed with {code}")
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
                process.wait(timeout=10)
            if display_assertion.poll() is None:
                display_assertion.terminate()
                display_assertion.wait(timeout=5)
    final_state = json.loads(ready.read_text())
    pointer_events = final_state.get("pointerEvents", 0) - state.get("pointerEvents", 0)
    session_unlocked = all(s.get("screen_locked") is not True and s.get("on_console") is True and s.get("logged_in") is True for s in samples)
    display_visible = session_unlocked and state.get("displayVisible") is True and final_state.get("displayVisible") is True and final_state.get("occludedDuringSample") is False
    uninterrupted = pointer_events == 0 and display_visible and not state["expanded"] and not final_state["expanded"]
    first, last = samples[0], samples[-1]
    elapsed = last["time"] - first["time"]
    cpus = sorted((b["cpu_ns"] - a["cpu_ns"]) / ((b["time"] - a["time"]) * 1e9) * 100
                  for a, b in zip(samples, samples[1:]))
    metrics = {
        "elapsed_seconds": elapsed,
        "cpu_mean_percent": (last["cpu_ns"] - first["cpu_ns"]) / (elapsed * 1e9) * 100,
        "cpu_p95_percent": cpus[math.ceil(0.95 * len(cpus)) - 1],
        "interrupt_wakeups_per_second": (last["interrupt_wakeups"] - first["interrupt_wakeups"]) / elapsed,
        "package_idle_wakeups_per_second": (last["package_idle_wakeups"] - first["package_idle_wakeups"]) / elapsed,
    }
    result = {"scenario": scenario, "metrics": metrics, "budgets": BUDGETS[scenario],
              "passed": uninterrupted and all(metrics[k] <= limit for k, limit in BUDGETS[scenario].items()),
              "screens": state["screens"], "samples": samples, "pointer_events": pointer_events,
              "uninterrupted": uninterrupted, "display_visible": display_visible,
              "scope": "Release-optimized standalone app with real notch panel and hidden workspace; synthetic calendar; network, notification delivery and WidgetKit extension excluded."}
    (output / "metrics.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"scenario": scenario, "passed": result["passed"], **metrics}), flush=True)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("--seconds", type=int, default=30)
    parser.add_argument("--repeats", type=int, default=2)
    parser.add_argument("--app", type=Path, default=ROOT / ".build/quality-app/Notch Quality.app")
    args = parser.parse_args()
    if args.seconds < 30 or args.repeats < 1:
        parser.error("Use at least 30 seconds and one repeat")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    env = dict(os.environ, DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer")
    sampler = output / "rusage"
    subprocess.run(["xcrun", "clang", "-Wall", "-Wextra", "-Werror", "-O2", "-framework", "CoreGraphics", "-framework", "CoreFoundation", str(ROOT / "Scripts/quality/rusage.c"), "-o", str(sampler)], env=env, check=True)
    session = json.loads(subprocess.check_output([str(sampler), str(os.getpid())], text=True))
    if session.get("screen_locked") is True:
        raise RuntimeError("Screen locked: unlock the Mac manually before acceptance sampling")
    build_info = json.loads((args.app.resolve().parent / "build.json").read_text())
    actual_hash = hashlib.sha256((args.app / "Contents/MacOS/NotchCalendar").read_bytes()).hexdigest()
    if actual_hash != build_info["binary_sha256"]:
        raise RuntimeError("Probe executable does not match its build manifest")
    results = [measure(scenario, output / f"{scenario}-{repeat + 1}", args.seconds, sampler, env, args.app.resolve())
               for repeat in range(args.repeats) for scenario in BUDGETS]
    report = {"schema_version": 1, "display_sleep_prevention": "temporary caffeinate -d assertion; manual lock is not disabled", "build": build_info, "passed": all(r["passed"] for r in results), "runs": results}
    (output / "report.json").write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    try:
        main()
    except RuntimeError as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
