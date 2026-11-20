"""
Splits a large file with one `partial class` into several files of at most N lines, cutting only between members.

Usage: python -I .scripts/split-partial.py <file.cs> [--max 450] [--apply]
Parts are written next to the original as <ClassName>.Part2.cs, <ClassName>.Part3.cs, ...; the first part stays in the original file.
Requirements: file-scoped namespace (or none), exactly one top-level type, declared `partial`.
Cuts are made only at brace depth 1 outside #if blocks, so no member is divided. Without --apply only prints the plan.
Verify with a build afterwards.
"""
import os
import re
import sys


def scan_depth(lines):
    """Returns the brace depth after every line (strings, chars and comments are ignored)."""
    depths = []
    depth = 0
    in_block = False
    in_verbatim = False
    for line in lines:
        i = 0
        in_string = False
        while i < len(line):
            ch = line[i]
            two = line[i:i + 2]
            if in_block:
                if two == "*/":
                    in_block = False
                    i += 1
            elif in_verbatim:
                if two == '""':
                    i += 1
                elif ch == '"':
                    in_verbatim = False
            elif in_string:
                if ch == "\\":
                    i += 1
                elif ch == '"':
                    in_string = False
            else:
                if two == "//":
                    break
                if two == "/*":
                    in_block = True
                    i += 1
                elif two in ("$@", "@$") and line[i + 2:i + 3] == '"':
                    in_verbatim = True
                    i += 2
                elif two == '@"':
                    in_verbatim = True
                    i += 1
                elif ch == '"':
                    in_string = True
                elif ch == "'":
                    end = line.find("'", i + 2 if line[i + 1:i + 2] == "\\" else i + 1)
                    i = end if end > i else i
                elif ch == "{":
                    depth += 1
                elif ch == "}":
                    depth -= 1
            i += 1
        depths.append(depth)
    return depths


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    path = sys.argv[1]
    limit = int(sys.argv[sys.argv.index("--max") + 1]) if "--max" in sys.argv else 450
    raw = open(path, "rb").read()
    text = raw.decode("utf-8-sig")
    newline = "\r\n" if "\r\n" in text else "\n"
    lines = text.replace("\r\n", "\n").split("\n")
    depths = scan_depth(lines)
    class_line = next((i for i, l in enumerate(lines) if re.match(r"^\s*(public|internal)\s+(static\s+|sealed\s+|abstract\s+)*partial\s+class\s+\w+", l)), None)
    if class_line is None:
        print("no partial class found")
        return 1
    open_line = next(i for i in range(class_line, len(lines)) if depths[i] == depths[class_line - 1 if class_line else 0] + 1 and "{" in lines[i])
    base = depths[open_line]
    close_line = max(i for i, l in enumerate(lines) if l.strip() == "}" and depths[i] == base - 1)
    name = re.search(r"class\s+(\w+)", lines[class_line]).group(1)
    header = lines[: open_line + 1]
    part_header = [l for l in header[:class_line] if l.strip().startswith(("namespace", "global using", "using", "#nullable", "#pragma"))] + [""]
    part_header += [lines[class_line].rstrip(), lines[open_line].rstrip()] if open_line != class_line else [lines[class_line].rstrip()]
    body = list(range(open_line + 1, close_line))
    # candidate cut: blank line at depth == base outside #if blocks, directly followed by a member start
    preproc = 0
    cuts = []
    for i in body:
        stripped = lines[i].strip()
        if stripped.startswith(("#if", "#region")):
            preproc += 1
        elif stripped.startswith(("#endif", "#endregion")):
            preproc -= 1
        if preproc == 0 and depths[i] == base and stripped == "":
            cuts.append(i)
    parts = []
    start = open_line + 1
    for i in cuts:
        if i - start >= limit:
            parts.append((start, i))
            start = i + 1
    parts.append((start, close_line))
    print(f"{path}: {len(lines)} lines, class {name}, {len(parts)} parts:", [e - s for s, e in parts])
    if len(parts) == 1 or "--apply" not in sys.argv:
        return 0
    directory = os.path.dirname(path)
    for index, (s, e) in enumerate(parts):
        content = lines[s:e]
        if index == 0:
            out = header + content + ["}"] + lines[close_line + 1:]
            target = path
        else:
            out = part_header + [""] + content + ["}"]
            target = os.path.join(directory, f"{name}.Part{index + 1}.cs")
            if os.path.exists(target):
                print("exists:", target)
                return 1
        open(target, "wb").write((b"\xef\xbb\xbf" if raw.startswith(b"\xef\xbb\xbf") else b"") + newline.join(out).encode("utf-8"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
