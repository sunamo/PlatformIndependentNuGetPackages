"""
Extracts or replaces Czech comments (comment text containing Czech diacritics) in C# files.

Usage:
  python -I .scripts/czech-comments.py extract <root> <texts.json>   writes {"<id>": "<czech text>"} of unique comment texts
  python -I .scripts/czech-comments.py apply <root> <texts.json> <translations.json> [--apply]   replaces texts by translations
A comment text is what follows "//" (or sits inside /* */), trimmed. Line endings and BOM are preserved.
"""
import json
import os
import re
import sys

DIACRITICS = re.compile(r"[áčďéěíňóřšťúůýžÁČĎÉĚÍŇÓŘŠŤÚŮÝŽ]")


def comment_parts(line, in_block):
    """Returns (code_prefix, comment_text, suffix, in_block_after) for one line; comment_text is None without a comment."""
    i = 0
    n = len(line)
    if in_block:
        end = line.find("*/")
        if end == -1:
            return "", line, "", True
        return "", line[:end], line[end:], False
    in_string = None
    verbatim = False
    while i < n:
        ch = line[i]
        if in_string:
            if verbatim and ch == '"' and line[i + 1:i + 2] == '"':
                i += 2
                continue
            if not verbatim and ch == "\\":
                i += 2
                continue
            if ch == in_string:
                in_string = None
        else:
            if ch == '"':
                in_string = '"'
                verbatim = i > 0 and line[i - 1] == "@" or (i > 1 and line[i - 2:i] == "$@") or (i > 1 and line[i - 2:i] == "@$")
            elif ch == "'" and i + 2 < n and (line[i + 2] == "'" or line[i + 1] == "\\"):
                i += 3 if line[i + 1] != "\\" else 4
                continue
            elif line.startswith("//", i):
                j = i + 2
                while j < n and line[j] == "/":
                    j += 1
                return line[:j], line[j:], "", False
            elif line.startswith("/*", i):
                end = line.find("*/", i + 2)
                if end == -1:
                    return line[:i + 2], line[i + 2:], "", True
                return line[:i + 2], line[i + 2:end], line[end:], False
        i += 1
    return line, None, "", False


def walk(root):
    """Yields .cs file paths under root, skipping build folders."""
    for folder, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in (".git", "bin", "obj", "node_modules")]
        for name in files:
            if name.endswith(".cs"):
                yield os.path.join(folder, name)


def read_lines(path):
    """Returns (bom, lines) or None when the file is not UTF-8."""
    raw = open(path, "rb").read()
    bom = raw.startswith(b"\xef\xbb\xbf")
    try:
        text = (raw[3:] if bom else raw).decode("utf-8")
    except UnicodeDecodeError:
        return None
    return bom, text.splitlines(keepends=True)


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    mode, root, texts_path = sys.argv[1:4]
    if mode == "extract":
        texts = {}
        files = 0
        for path in walk(root):
            data = read_lines(path)
            if not data:
                continue
            in_block = False
            hit = False
            for line in data[1]:
                body = line.rstrip("\r\n")
                prefix, comment, suffix, in_block = comment_parts(body, in_block)
                if comment is not None and DIACRITICS.search(comment):
                    texts.setdefault(comment.strip(), None)
                    hit = True
            files += hit
        ordered = {str(index): text for index, text in enumerate(sorted(texts))}
        json.dump(ordered, open(texts_path, "w", encoding="utf-8"), ensure_ascii=False, indent=0)
        print(f"files={files} uniqueTexts={len(ordered)}")
    else:
        translations_path = sys.argv[4]
        apply = "--apply" in sys.argv
        texts = json.load(open(texts_path, encoding="utf-8"))
        translated = json.load(open(translations_path, encoding="utf-8"))
        mapping = {texts[key]: translated[key] for key in texts if key in translated and translated[key]}
        changed = 0
        missing = set()
        for path in walk(root):
            data = read_lines(path)
            if not data:
                continue
            bom, lines = data
            in_block = False
            out = []
            modified = False
            for line in lines:
                body = line.rstrip("\r\n")
                eol = line[len(body):]
                prefix, comment, suffix, in_block_after = comment_parts(body, in_block)
                if comment is not None and DIACRITICS.search(comment):
                    key = comment.strip()
                    if key in mapping:
                        lead = comment[: len(comment) - len(comment.lstrip())] or " "
                        trail = comment[len(comment.rstrip()):]
                        body = prefix + lead + mapping[key] + trail + suffix
                        modified = True
                    else:
                        missing.add(key)
                in_block = in_block_after
                out.append(body + eol)
            if modified:
                changed += 1
                if apply:
                    data_bytes = "".join(out).encode("utf-8")
                    open(path, "wb").write((b"\xef\xbb\xbf" if bom else b"") + data_bytes)
        print(f"changedFiles={changed} missingTexts={len(missing)} apply={apply}")


if __name__ == "__main__":
    main()
