"""
Summarizes why tests fail: runs the test project of each package on one framework and groups failures by exception text.

Usage: python -I .scripts/test-failures.py <container root> <result.json> <package> [<package> ...]
Result: {"<package>": {"<failed test>": "<first line of the error message>"}}; prints a histogram of error messages.
"""
import collections
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

HEADER = re.compile(r"^\s+Failed (\S+) \[")
MESSAGE = re.compile(r"^\s+Error Message:\s*$")


def run(root, package):
    """Runs one test project and returns {test: first message line}."""
    project = os.path.join(root, package, package + ".Tests", package + ".Tests.csproj")
    try:
        out = subprocess.run(["dotnet", "test", project, "-nologo", "-f", "net10.0", "--logger", "console;verbosity=detailed"],
                             capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=280).stdout
    except subprocess.TimeoutExpired:
        return package, {"<timeout>": "timeout"}
    failures = {}
    lines = out.splitlines()
    for i, line in enumerate(lines):
        match = HEADER.match(line)
        if match:
            for j in range(i + 1, min(i + 6, len(lines))):
                if MESSAGE.match(lines[j]) and j + 1 < len(lines):
                    failures[match.group(1)] = lines[j + 1].strip()[:200]
                    break
    return package, failures


def main():
    root = os.path.abspath(sys.argv[1])
    with ThreadPoolExecutor(3) as pool:
        results = dict(pool.map(lambda p: run(root, p), sys.argv[3:]))
    json.dump(results, open(sys.argv[2], "w", encoding="utf-8"), indent=1)
    histogram = collections.Counter(re.sub(r"\d+", "N", m)[:90] for v in results.values() for m in v.values())
    for message, count in histogram.most_common(15):
        print(count, message)


if __name__ == "__main__":
    main()
