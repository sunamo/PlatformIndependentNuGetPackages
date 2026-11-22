"""
Adds <EnablePackageValidation>true</EnablePackageValidation> after <IsPackable>true</IsPackable> in package csproj files.

Usage: python -I .scripts/add-package-validation.py <container root> [<container root> ...]
Idempotent; only touches <package>/<package>/<package>.csproj. Verify first with `dotnet pack -p:EnablePackageValidation=true`.
"""
import os
import re
import sys

changed = 0
for root in sys.argv[1:]:
    for package in sorted(os.listdir(root)):
        project = os.path.join(root, package, package, package + ".csproj")
        if not os.path.exists(project):
            continue
        raw = open(project, "rb").read()
        text = raw.decode("utf-8-sig")
        if "<EnablePackageValidation>" in text or "<IsPackable>true</IsPackable>" not in text:
            continue
        nl = "\r\n" if "\r\n" in text else "\n"
        text = re.sub(r"([ \t]*)(<IsPackable>true</IsPackable>)", lambda m: m.group(1) + m.group(2) + nl + m.group(1) + "<EnablePackageValidation>true</EnablePackageValidation>", text, count=1)
        open(project, "wb").write((b"\xef\xbb\xbf" if raw.startswith(b"\xef\xbb\xbf") else b"") + text.encode("utf-8"))
        changed += 1
print("projects updated:", changed)
