"""
Normalizes NuGet package csproj files (not *.Tests, not Runner*):
  - removes <Optimize>false</Optimize> (packages must be published optimized)
  - removes junk <PackageReleaseNotes> (build notes copied from commit messages)
  - adds GenerateDocumentationFile, SourceLink and a readme (PackageReadmeFile) when missing
Usage: python -I .scripts/fix-package-csproj.py <root> [--apply]
"""
import glob
import os
import re
import sys


def readme_text(name, description, frameworks):
    """Returns the generated readme.md content for a package."""
    lines = [f"# {name}", ""]
    if description:
        lines += [description.strip(), ""]
    lines += ["## Install", "", "```", f"dotnet add package {name}", "```", ""]
    if frameworks:
        lines += ["## Target frameworks", ""] + [f"- {fw}" for fw in frameworks] + [""]
    lines += ["## License", "", "MIT", ""]
    return "\n".join(lines)


def process(path, apply):
    """Returns a list of change tags for the csproj and rewrites it when apply is set."""
    raw = open(path, "rb").read()
    bom = raw.startswith(b"\xef\xbb\xbf")
    try:
        text = (raw[3:] if bom else raw).decode("utf-8")
    except UnicodeDecodeError:
        return []
    original = text
    changes = []
    eol = "\r\n" if "\r\n" in text else "\n"
    folder = os.path.dirname(path)
    name = os.path.splitext(os.path.basename(path))[0]

    new = re.sub(r"[ \t]*<Optimize>false</Optimize>\r?\n", "", text)
    if new != text:
        changes.append("optimize")
        text = new
    new = re.sub(r"[ \t]*<PackageReleaseNotes>.*?</PackageReleaseNotes>\r?\n", "", text, flags=re.S)
    if new != text:
        changes.append("releaseNotes")
        text = new

    if "<IsPackable>true" in text or "<PackageLicenseExpression>" in text:
        if "<GenerateDocumentationFile>true" not in text:
            text = text.replace("</PropertyGroup>", f"  <GenerateDocumentationFile>true</GenerateDocumentationFile>{eol}  </PropertyGroup>", 1)
            changes.append("docfile")
        if "SourceLink" not in text:
            text = text.replace("</Project>", f'  <ItemGroup>{eol}    <PackageReference Include="Microsoft.SourceLink.GitHub" Version="10.0.102" PrivateAssets="all" />{eol}  </ItemGroup>{eol}</Project>', 1)
            changes.append("sourcelink")
        if "PackageReadmeFile" not in text:
            existing = [f for f in os.listdir(folder) if f.lower() == "readme.md"]
            readme = existing[0] if existing else "readme.md"
            if not existing:
                description = (re.search(r"<Description>(.*?)</Description>", text, re.S) or [None, ""])[1]
                frameworks = (re.search(r"<TargetFrameworks?>(.*?)</TargetFrameworks?>", text) or [None, ""])[1].split(";")
                if apply:
                    open(os.path.join(folder, readme), "w", encoding="utf-8", newline="\n").write(readme_text(name, description, [f for f in frameworks if f]))
                changes.append("readmeCreated")
            text = text.replace("</PropertyGroup>", f"  <PackageReadmeFile>{readme}</PackageReadmeFile>{eol}  </PropertyGroup>", 1)
            if f'Include="{readme}"' not in text:
                text = text.replace("</Project>", f'  <ItemGroup>{eol}    <None Include="{readme}" Pack="True" PackagePath="." />{eol}  </ItemGroup>{eol}</Project>', 1)
            changes.append("readmeFile")

    if text != original and apply:
        open(path, "wb").write((b"\xef\xbb\xbf" if bom else b"") + text.encode("utf-8"))
    return changes


def main():
    root = sys.argv[1]
    apply = "--apply" in sys.argv
    totals = {}
    for path in glob.glob(os.path.join(root, "*", "*", "*.csproj")):
        base = os.path.basename(path)
        if ".Tests" in base or base.startswith("Runner") or ".Net48" in base:
            continue
        for tag in process(path, apply):
            totals[tag] = totals.get(tag, 0) + 1
    print(totals, "apply=" + str(apply))


if __name__ == "__main__":
    main()
