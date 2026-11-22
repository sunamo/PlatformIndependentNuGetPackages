"""
Finds direct PackageReference versions with known vulnerabilities (NuGet vulnerability data) in the csproj files of containers.

Usage: python -I .scripts/scan-vulnerable-packages.py <container root> [<container root> ...]
Prints "<csproj>  <package> <version>  severity=<n>  fixed-range=<range>"; severity 0 low, 1 moderate, 2 high, 3 critical.
Floating versions (containing *) and transitive packages are not checked.
"""
import gzip
import json
import os
import re
import sys
import urllib.request

REFERENCE = re.compile(r'<PackageReference\s+[^>]*?Include="([^"]+)"[^>]*?Version="([^"]+)"', re.S)


def version_key(text):
    """Returns a comparable tuple for a numeric version string."""
    numbers = re.findall(r"\d+", text.split("-")[0].split("+")[0])
    return tuple(int(n) for n in numbers) + (0,) * (4 - len(numbers))


def in_range(version, expression):
    """True when version is inside a NuGet interval expression like [1.0.0, 2.0.0)."""
    match = re.match(r"^([\[\(])\s*([^,]*)\s*,\s*([^\]\)]*)\s*([\]\)])$", expression.strip())
    if not match:
        return False
    low_open, low, high, high_open = match.groups()
    key = version_key(version)
    if low.strip():
        low_key = version_key(low)
        if key < low_key or (key == low_key and low_open == "("):
            return False
    if high.strip():
        high_key = version_key(high)
        if key > high_key or (key == high_key and high_open == ")"):
            return False
    return True


def fetch_json(url):
    """Downloads a JSON document, decompressing it when the server sends gzip."""
    raw = urllib.request.urlopen(url, timeout=120).read()
    return json.loads(gzip.decompress(raw) if raw[:2] == bytes([31, 139]) else raw)


def load_vulnerabilities():
    """Returns {lowercase package id: [(range, severity)]} from the NuGet vulnerability base page."""
    index = fetch_json("https://api.nuget.org/v3/vulnerabilities/index.json")
    data = {}
    for page in index:
        if page["@name"] not in ("base", "update"):
            continue
        for package, entries in fetch_json(page["@id"]).items():
            for entry in entries:
                data.setdefault(package.lower(), []).append((entry["versions"], entry["severity"]))
    return data


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    vulnerabilities = load_vulnerabilities()
    found = 0
    for root in sys.argv[1:]:
        for folder, dirs, files in os.walk(root):
            dirs[:] = [d for d in dirs if d not in (".git", "bin", "obj", "node_modules", ".claudehistory")]
            for name in files:
                if not name.endswith(".csproj"):
                    continue
                text = re.sub(r"<!--.*?-->", "", open(os.path.join(folder, name), encoding="utf-8-sig", errors="replace").read(), flags=re.S)
                for package, version in REFERENCE.findall(text):
                    if "*" in version or "$" in version:
                        continue
                    for expression, severity in vulnerabilities.get(package.lower(), []):
                        if in_range(version, expression):
                            found += 1
                            print(f"{os.path.relpath(os.path.join(folder, name), root)}  {package} {version}  severity={severity}  range={expression}")
    print("vulnerable references:", found)
    sys.exit(1 if found else 0)


if __name__ == "__main__":
    main()
