"""Cross-check Mach time conversion against Python's independent POSIX CPU clock."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest


@unittest.skipUnless(sys.platform == "darwin", "macOS resource accounting")
class ResourceSamplerTests(unittest.TestCase):
    def testCpuNanosecondsAgreeWithPosixProcessTime(self):
        with tempfile.TemporaryDirectory() as directory:
            sampler = Path(directory) / "rusage"
            source = Path(__file__).with_name("rusage.c")
            subprocess.run(["xcrun", "clang", "-Wall", "-Wextra", "-Werror", "-O2", "-framework", "CoreGraphics", "-framework", "CoreFoundation", str(source), "-o", str(sampler)], check=True)
            def sample():
                return json.loads(subprocess.check_output([str(sampler), str(os.getpid())], text=True))
            before = sample()
            start = time.process_time()
            while time.process_time() - start < 0.25:
                sum(index * index for index in range(1000))
            cpu_seconds = time.process_time() - start
            after = sample()
            measured = (after["cpu_ns"] - before["cpu_ns"]) / 1e9
            self.assertAlmostEqual(measured, cpu_seconds, delta=0.04)
            self.assertGreaterEqual(after["interrupt_wakeups"], before["interrupt_wakeups"])
            self.assertGreater(after["time"], before["time"])


if __name__ == "__main__":
    unittest.main()
