"""
Writes English XML documentation for public members listed by doc-gaps.py.

Usage:
  python -I .scripts/doc-apply.py plan  <container root> <gaps.json> <plan.json> <manual-chunks-dir> [--chunk 40]
      classifies every gap: simple members (properties, fields, constants, enum values) get a name-derived summary in plan.json,
      methods, constructors, operators and types are written to <manual-chunks-dir>/chunk-NNN.json for an author (human or model).
  python -I .scripts/doc-apply.py apply <container root> <plan.json> [<manual result.json> ...]
      inserts the comments above each member (above its attributes) and skips members that already have documentation.
Manual result format: {"<relative file>": {"<line>": {"summary": "...", "params": {"name": "..."}, "returns": "...", "typeparams": {"T": "..."}}}}
"""
import json
import os
import re
import sys

WORDS = re.compile(r"[A-Z]+(?![a-z])|[A-Z]?[a-z]+|\d+")
TYPE_KEYWORDS = re.compile(r"\b(class|struct|interface|enum|record|delegate)\b")


def split_words(name):
    """Splits an identifier into lowercase words."""
    words = [w if (w.isupper() and len(w) > 1) else w.lower() for w in WORDS.findall(name.lstrip("_@"))]
    return " ".join(words) if words else name


def classify(member, line_text):
    """Returns (kind, name) where kind is type, method, property, field, const or enum."""
    stripped = line_text.strip()
    name = member.split("(")[0].split(".")[-1]
    if "(" in member:
        return "method", name
    if TYPE_KEYWORDS.search(stripped.split("=")[0].split("{")[0]) and not re.search(r"\bconst\b", stripped):
        return "type", name
    if re.match(r"^[A-Za-z_][A-Za-z_0-9]*\s*(=\s*[^,]+)?,?\s*(//.*)?$", stripped):
        return "enum", name
    if re.search(r"\bconst\b", stripped):
        return "const", name
    if re.search(r"\{\s*(get|set|init)", stripped) or "=>" in stripped or stripped.endswith(")") is False and re.search(r"\b\w+\s+\w+\s*$", stripped) and "{" in stripped:
        return "property", name
    if stripped.endswith("{") or stripped.endswith("}") or "get;" in stripped or "set;" in stripped:
        return "property", name
    return "field", name


def auto_summary(kind, name, line_text):
    """Returns a summary for simple members."""
    words = split_words(name)
    if kind == "property":
        settable = re.search(r"\b(set|init)\b\s*[;{]", line_text)
        return ("Gets or sets the " if settable else "Gets the ") + words + "."
    if kind == "const":
        return "The " + words + " constant."
    if kind == "enum":
        return "The " + words + " value."
    return "The " + words + "."


def indent_of(line):
    """Returns the leading whitespace of a line."""
    return line[: len(line) - len(line.lstrip(" \t"))]


def read(path):
    """Returns (bom, text, newline) of a UTF-8 file or None."""
    raw = open(path, "rb").read()
    try:
        text = raw.decode("utf-8-sig")
    except UnicodeDecodeError:
        return None
    return raw.startswith(b"\xef\xbb\xbf"), text, "\r\n" if "\r\n" in text else "\n"


def plan(root, gaps_path, plan_path, chunk_dir, chunk_size):
    """Splits the gaps into automatic docs and manual chunks."""
    gaps = json.load(open(gaps_path, encoding="utf-8"))
    auto, manual = {}, []
    for rel, entries in gaps.items():
        data = read(os.path.join(root, rel))
        if not data:
            continue
        lines = data[1].split("\n")
        for entry in entries:
            if entry["line"] - 1 >= len(lines):
                continue
            text = lines[entry["line"] - 1]
            kind, name = classify(entry["member"], text)
            if kind in ("property", "field", "const", "enum"):
                auto.setdefault(rel, {})[str(entry["line"])] = {"summary": auto_summary(kind, name, text)}
            else:
                manual.append({"file": rel, "line": entry["line"], "member": entry["member"], "kind": kind, "text": text.strip()[:200]})
    json.dump(auto, open(plan_path, "w", encoding="utf-8"), indent=0)
    os.makedirs(chunk_dir, exist_ok=True)
    by_file = {}
    for item in manual:
        by_file.setdefault(item["file"], []).append(item)
    chunk, count, index = {}, 0, 0
    for rel, items in by_file.items():
        chunk[rel] = items
        count += 1
        if count >= chunk_size:
            index += 1
            json.dump(chunk, open(os.path.join(chunk_dir, f"chunk-{index:03d}.json"), "w", encoding="utf-8"), indent=0)
            chunk, count = {}, 0
    if chunk:
        index += 1
        json.dump(chunk, open(os.path.join(chunk_dir, f"chunk-{index:03d}.json"), "w", encoding="utf-8"), indent=0)
    print(f"auto={sum(len(v) for v in auto.values())} manual={len(manual)} files={len(by_file)} chunks={index}")


def escape(text):
    """Escapes text for XML documentation."""
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def render(indent, doc, newline):
    """Renders the documentation block."""
    out = [f"{indent}/// <summary>", f"{indent}/// {escape(doc['summary'])}", f"{indent}/// </summary>"]
    for name, text in (doc.get("typeparams") or {}).items():
        out.append(f'{indent}/// <typeparam name="{name}">{escape(text)}</typeparam>')
    for name, text in (doc.get("params") or {}).items():
        out.append(f'{indent}/// <param name="{name}">{escape(text)}</param>')
    if doc.get("returns"):
        out.append(f"{indent}/// <returns>{escape(doc['returns'])}</returns>")
    return [line + newline for line in out]


def apply(root, sources):
    """Inserts documentation blocks into the files."""
    merged = {}
    for source in sources:
        for rel, per_line in json.load(open(source, encoding="utf-8")).items():
            merged.setdefault(rel, {}).update(per_line)
    inserted = skipped = 0
    for rel, per_line in merged.items():
        path = os.path.join(root, rel)
        data = read(path)
        if not data:
            continue
        bom, text, newline = data
        lines = text.split("\n")
        for line_no in sorted((int(k) for k in per_line), reverse=True):
            doc = per_line[str(line_no)]
            if not doc.get("summary") or line_no - 1 >= len(lines):
                skipped += 1
                continue
            at = line_no - 1
            while at > 0 and lines[at - 1].strip().startswith("[") and not lines[at - 1].strip().startswith("[//"):
                at -= 1
            if at > 0 and lines[at - 1].strip().startswith("///"):
                skipped += 1
                continue
            block = render(indent_of(lines[at]), doc, "\r" if newline == "\r\n" else "")
            lines[at:at] = [b.rstrip("\n") for b in block]
            inserted += 1
        open(path, "wb").write((b"\xef\xbb\xbf" if bom else b"") + "\n".join(lines).encode("utf-8"))
    print(f"inserted={inserted} skipped={skipped} files={len(merged)}")


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    mode, root = sys.argv[1], os.path.abspath(sys.argv[2])
    if mode == "plan":
        size = int(sys.argv[sys.argv.index("--chunk") + 1]) if "--chunk" in sys.argv else 40
        plan(root, sys.argv[3], sys.argv[4], sys.argv[5], size)
    else:
        apply(root, sys.argv[3:])


if __name__ == "__main__":
    main()
