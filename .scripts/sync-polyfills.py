"""
Keeps every Net48Polyfills.cs identical to the canonical copy in .scripts/shared/Net48Polyfills.cs.
Usage: python -I .scripts/sync-polyfills.py <root> [--apply]
Without --apply it only lists copies that differ from the canonical file.
"""
import os
import sys


def main():
    root = sys.argv[1]
    apply = "--apply" in sys.argv
    canonical = open(os.path.join(root, ".scripts", "shared", "Net48Polyfills.cs"), "rb").read()
    different = []
    for folder, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in (".git", "bin", "obj", "node_modules", "shared")]
        if "Net48Polyfills.cs" in files:
            path = os.path.join(folder, "Net48Polyfills.cs")
            if open(path, "rb").read() != canonical:
                different.append(path)
                if apply:
                    open(path, "wb").write(canonical)
    print(f"different={len(different)} apply={apply}")
    for path in different:
        print(path)


if __name__ == "__main__":
    main()
