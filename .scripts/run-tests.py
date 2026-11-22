"""
Runs `dotnet test` for the *.Tests projects of the given packages and writes a summary.

Usage: python -I .scripts/run-tests.py <container root> <result.json> <package> [<package> ...]
Result: {"<package>": {"passed": n, "failed": n, "skipped": n, "build_error": bool, "failures": ["Namespace.Class.Method", ...]}}
Each project is limited to 280 seconds; three run in parallel.
"""
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

TOTALS = re.compile(r"(Passed|Failed)!\s+-\s+Failed:\s+(\d+),\s+Passed:\s+(\d+),\s+Skipped:\s+(\d+)")
FAILED = re.compile(r"^\s+Failed (\S+)")


def run(root, package):
    """Runs the test project of one package."""
    project = os.path.join(root, package, package + ".Tests", package + ".Tests.csproj")
    if not os.path.exists(project):
        return package, None
    try:
        out = subprocess.run(["dotnet", "test", project, "-nologo", "-v", "q"], capture_output=True, text=True,
                             encoding="utf-8", errors="replace", timeout=280).stdout
    except subprocess.TimeoutExpired:
        return package, {"passed": 0, "failed": 0, "skipped": 0, "build_error": False, "failures": ["<timeout>"]}
    passed = failed = skipped = 0
    for match in TOTALS.finditer(out):
        failed += int(match.group(2))
        passed += int(match.group(3))
        skipped += int(match.group(4))
    failures = sorted({m.group(1) for line in out.splitlines() for m in [FAILED.match(line)] if m})
    return package, {"passed": passed, "failed": failed, "skipped": skipped,
                     "build_error": passed + failed + skipped == 0 and "error" in out, "failures": failures}


def main():
    root = os.path.abspath(sys.argv[1])
    with ThreadPoolExecutor(3) as pool:
        results = dict(pool.map(lambda p: run(root, p), sys.argv[3:]))
    results = {k: v for k, v in results.items() if v}
    json.dump(results, open(sys.argv[2], "w", encoding="utf-8"), indent=1)
    print("projects:", len(results), "passed:", sum(v["passed"] for v in results.values()), "failed:", sum(v["failed"] for v in results.values()),
          "build errors:", sum(1 for v in results.values() if v["build_error"]))


if __name__ == "__main__":
    main()
