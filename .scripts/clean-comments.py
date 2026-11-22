"""
Cleans comments in C# files of this repo and all submodules.

Modes:
  code     removes commented-out code (// lines and /* */ blocks that look like code)
  english  removes "// CZ: ..." lines and strips the "EN: " prefix, so only English remains

Usage:
  python -I .scripts/clean-comments.py <mode> <root> [--apply] [--report <file>]
Without --apply it only prints statistics (dry run).
Each changed file is listed in the report as "<path>\t<removed line count>".
"""
import os
import re
import sys

DIACRITICS = re.compile(r"[áčďéěíňóřšťúůýžÁČĎÉĚÍŇÓŘŠŤÚŮÝŽ]")
LABEL_PROSE = re.compile(r"^(?!case\b|default\b)[A-Za-z][A-Za-z ]{0,30}:\s")
BRACES_ONLY = re.compile(r"^[\{\}\)\]]+[;,\)]*$")
KEYWORD_PAREN = re.compile(r"^(if|while|for|foreach|switch|catch|lock|using)\s*\(")
KEYWORD_ALONE = re.compile(r"^(else|try|finally|do)\b\s*(\{.*)?$")
KEYWORD_ELSE_IF = re.compile(r"^else\s+if\s*\(")
KEYWORD_DECL = re.compile(
    r"^(using\s+(static\s+)?[\w\.]+\s*;|namespace\s+[\w\.]+|public|private|protected|internal|static|class|interface|enum|struct|abstract|sealed|override|virtual|async|partial|readonly|const|\[[A-Z]\w*)\b"
)
RETURN_LIKE = re.compile(r"^(return|throw|await|yield|break|continue|case|default)\b")
DECLARATION = re.compile(r"^[\w][\w<>\[\],\.\?]*\s+\w+\s*(=|\{|;)")
ASSIGNMENT = re.compile(r"^[\w\.\[\]]+\s*(=|\+=|-=|\+\+|--)\s*[^\s=]")
CALL = re.compile(r"^[\w\.<>\[\]]+\s*\(.*\)\s*;?$")
FLUENT = re.compile(r"^\.\w+(<.*>)?\(")


def is_code(text):
    """Returns True for code-like text, False for prose, None for an empty (neutral) line."""
    text = text.strip()
    if text == "":
        return None
    if re.match(r"^(EN|CZ):", text):
        return False
    if DIACRITICS.search(text) and not text.endswith(";"):
        return False
    if re.match(r"^(public|internal|private|protected)\s+(static\s+|abstract\s+|sealed\s+|partial\s+)*(class|interface|enum|struct)\s+\w+", text):
        return True
    if BRACES_ONLY.match(text):
        return True
    if LABEL_PROSE.match(text):
        return False
    if text.endswith(";"):
        return True
    if KEYWORD_PAREN.match(text) or KEYWORD_ELSE_IF.match(text) or KEYWORD_ALONE.match(text):
        return text.endswith(")") or text.endswith("{") or text.endswith(";") or KEYWORD_ALONE.match(text) is not None
    if KEYWORD_DECL.match(text):
        return any(ch in text for ch in "({=;") or text.endswith(")")
    if RETURN_LIKE.match(text):
        return text.endswith(";") or text.endswith(":")
    if FLUENT.match(text):
        return True
    if DECLARATION.match(text):
        return True
    if ASSIGNMENT.match(text):
        return True
    if CALL.match(text):
        return True
    if text.endswith("{") and " " not in text.rstrip("{ ").strip():
        return True
    return False


def strip_slashes(line):
    """Returns the text after // for a plain comment line, or None when the line is not a plain // comment."""
    stripped = line.strip()
    if stripped.startswith("//") and not stripped.startswith("///"):
        return stripped[2:]
    return None


def looks_like_continuation(text):
    """True for leftover lines of a commented multi-line statement (indented, argument lists, operators)."""
    if DIACRITICS.search(text) or re.match(r"^\s*(EN|CZ):", text):
        return False
    stripped = text.strip()
    if stripped == "":
        return False
    if len(stripped.split()) >= 5 and not re.search(r"[;{}=()\[\]]", stripped):
        return False
    indented = len(text) - len(text.lstrip(" \t")) >= 2
    return indented or stripped.endswith(",") or stripped.endswith("+") or stripped.startswith(("&&", "||", "?", ":", "."))


def clean_code_mode(lines):
    """Returns (new_lines, removed_lines) with commented-out code removed."""
    n = len(lines)
    remove = [False] * n

    # block comments
    i = 0
    while i < n:
        stripped = lines[i].strip()
        if stripped.startswith("/*") and not stripped.startswith("/**"):
            j = i
            while j < n and "*/" not in lines[j]:
                j += 1
            if j < n and lines[j].strip().endswith("*/"):
                inner = []
                for k in range(i, j + 1):
                    t = lines[k].strip()
                    if k == i:
                        t = t[2:]
                    if k == j:
                        t = t[:-2] if t.endswith("*/") else t
                    t = t.strip().lstrip("*").strip()
                    inner.append(t)
                verdicts = [is_code(t) for t in inner if t.strip() != ""]
                if verdicts and sum(1 for v in verdicts if v) * 2 >= len(verdicts) and not any(
                    DIACRITICS.search(t) and not t.endswith(";") for t in inner
                ):
                    for k in range(i, j + 1):
                        remove[k] = True
                i = j + 1
                continue
        i += 1

    # line comments, grouped in contiguous blocks
    i = 0
    while i < n:
        if strip_slashes(lines[i]) is None or remove[i]:
            i += 1
            continue
        j = i
        while j < n and strip_slashes(lines[j]) is not None:
            j += 1
        block = [strip_slashes(lines[k]) for k in range(i, j)]
        verdicts = [is_code(t) for t in block]
        has_code = any(v for v in verdicts)
        for offset, t in enumerate(block):
            idx = i + offset
            if verdicts[offset]:
                remove[idx] = True
            elif has_code and verdicts[offset] is None and t.strip() == "":
                remove[idx] = True  # empty // inside a code block, trimmed below if dangling
            elif has_code and verdicts[offset] is False and looks_like_continuation(t):
                # leftover of a multi-line commented statement: only when next to a removed code line
                near = (offset > 0 and verdicts[offset - 1]) or (offset + 1 < len(block) and verdicts[offset + 1])
                if near:
                    remove[idx] = True
        # an empty // line is removed only when the block still has removed code around it
        for offset, t in enumerate(block):
            idx = i + offset
            if remove[idx] and t.strip() == "" and verdicts[offset] is None:
                before = any(remove[k] and (strip_slashes(lines[k]) or "").strip() != "" for k in range(i, idx))
                after = any(remove[k] and (strip_slashes(lines[k]) or "").strip() != "" for k in range(idx + 1, j))
                if not (before and after):
                    remove[idx] = False
        i = j

    new_lines = []
    removed = []
    for idx, line in enumerate(lines):
        if remove[idx]:
            removed.append(line)
        else:
            new_lines.append(line)
    return new_lines, removed


INLINE_PAIR = re.compile(r"//\s*EN:\s*(.*?)\s*\|\s*CZ:.*$")


def clean_english_mode(lines):
    """Returns (new_lines, removed_lines): drops // CZ: lines, strips the EN: prefix, handles inline EN|CZ pairs."""
    new_lines = []
    removed = []
    for line in lines:
        stripped = line.strip()
        text = strip_slashes(line)
        if text is not None:
            body = text.strip()
            if re.match(r"^CZ:", body):
                removed.append(line)
                continue
            m = re.match(r"^(\s*)//(\s*)EN:\s?(.*)$", line.rstrip("\r\n"))
            if m:
                eol = line[len(line.rstrip("\r\n")):]
                new_lines.append(f"{m.group(1)}// {m.group(3)}{eol}")
                continue
        elif stripped.startswith("///"):
            body = stripped[3:].strip()
            if re.match(r"^CZ:", body):
                removed.append(line)
                continue
            m = re.match(r"^(\s*///\s*)EN:\s?(.*)$", line.rstrip(chr(13) + chr(10)))
            if m:
                eol = line[len(line.rstrip(chr(13) + chr(10))):]
                new_lines.append(f"{m.group(1)}{m.group(2)}{eol}")
                continue
        else:
            m = INLINE_PAIR.search(line.rstrip("\r\n"))
            if m:
                eol = line[len(line.rstrip("\r\n")):]
                new_lines.append(line.rstrip("\r\n")[: m.start()] + "// " + m.group(1) + eol)
                continue
        new_lines.append(line)
    return new_lines, removed


def process_file(path, mode, apply):
    """Processes one file; returns the list of removed lines (empty when nothing changed) or None for unreadable files."""
    with open(path, "rb") as handle:
        raw = handle.read()
    bom = raw.startswith(b"\xef\xbb\xbf")
    try:
        text = raw[3:].decode("utf-8") if bom else raw.decode("utf-8")
    except UnicodeDecodeError:
        return None
    lines = text.splitlines(keepends=True)
    if mode == "code":
        new_lines, removed = clean_code_mode(lines)
    else:
        new_lines, removed = clean_english_mode(lines)
    changed = new_lines != lines
    if not changed:
        return []
    if apply:
        data = "".join(new_lines).encode("utf-8")
        with open(path, "wb") as handle:
            handle.write((b"\xef\xbb\xbf" if bom else b"") + data)
    return removed if removed else ["<prefix stripped>"]


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    mode, root = sys.argv[1], sys.argv[2]
    apply = "--apply" in sys.argv
    report = sys.argv[sys.argv.index("--report") + 1] if "--report" in sys.argv else None
    skipped = []
    changed_files = []
    total_removed = 0
    samples = []
    for folder, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in (".git", "bin", "obj", "node_modules")]
        for name in files:
            if not name.endswith(".cs"):
                continue
            path = os.path.join(folder, name)
            result = process_file(path, mode, apply)
            if result is None:
                skipped.append(path)
            elif result:
                changed_files.append((path, len(result)))
                total_removed += len(result)
                samples.extend(r.strip() for r in result)
    print(f"mode={mode} apply={apply} changedFiles={len(changed_files)} removedLines={total_removed} unreadable={len(skipped)}")
    if report:
        with open(report, "w", encoding="utf-8") as handle:
            for path, count in changed_files:
                handle.write(f"{path}\t{count}\n")
            handle.write("---SAMPLES---\n")
            for sample in samples:
                handle.write(sample + "\n")
            handle.write("---UNREADABLE---\n")
            for path in skipped:
                handle.write(path + "\n")


if __name__ == "__main__":
    main()
