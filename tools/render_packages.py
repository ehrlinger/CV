"""Render the Software section of JohnEhrlinger-CV.qmd from hvtiR's manifest.

Fourth and last sink, after the profile README and the personal site. This one
owns Quarto prose: four labelled groups of wrapped paragraphs, and CRAN entries
that carry a live version number and link to CRAN rather than to GitHub.

Standard library only -- no pip install step on the runner.
"""
from __future__ import annotations

import argparse
import json
import sys
import textwrap
import time
import urllib.request
from pathlib import Path

MANIFEST_URL = "https://ehrlinger.github.io/hvtiR/members.json"
CRANDB_URL = "https://crandb.r-pkg.org/{}"
CRAN_PAGE = "https://CRAN.R-project.org/package={}"
INSTALLER_URL = "https://github.com/ehrlinger/hvtiR"
MARKER_BEGIN = "<!-- BEGIN:packages -->"
MARKER_END = "<!-- END:packages -->"
WRAP = 90
# crandb answers 403 to the default Python-urllib User-Agent, so identify
# ourselves. Discovered the hard way: the lookup failed silently and the CV
# rendered without any version numbers at all.
USER_AGENT = "ehrlinger-cv-sync (+https://github.com/ehrlinger/CV)"

_WORDS = (
    "zero", "one", "two", "three", "four", "five", "six", "seven", "eight",
    "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen",
    "sixteen", "seventeen", "eighteen", "nineteen", "twenty",
)


class NetworkError(RuntimeError):
    """The manifest could not be fetched. Distinct from a malformed manifest."""


def number_word(n: int) -> str:
    return _WORDS[n] if 0 <= n < len(_WORDS) else str(n)


def _join(names: list[str]) -> str:
    tagged = [f"*{n}*" for n in names]
    if len(tagged) <= 1:
        return "".join(tagged)
    return f"{', '.join(tagged[:-1])} and {tagged[-1]}"


def _wrap(text: str) -> str:
    # break_long_words/on_hyphens off so a long URL is never split, which
    # would silently produce a dead link in the rendered PDF.
    return textwrap.fill(
        text, width=WRAP, break_long_words=False, break_on_hyphens=False
    )


def _entry(pkg: dict, versions: dict) -> str:
    text = pkg["blurb"].replace(" -- ", " — ")

    if pkg["cran"]:
        version = versions.get(pkg["cran"])
        # No version rather than a fabricated one: the entry still reads
        # correctly, and a wrong number on a CV is worse than none.
        text += f" v{version} on CRAN." if version else " On CRAN."
        url = CRAN_PAGE.format(pkg["cran"])
    else:
        url = pkg["url"]

    if pkg["family"] == "book":
        text += " Quarto book, CC BY 4.0."
    if pkg["status"] == "wip":
        # The CV writes this as a trailing clause, not a new sentence.
        text = text.rstrip().removesuffix(".") + "; in active development."
    if pkg["role"]:
        text += f" ({pkg['role']})"

    return _wrap(f"*{pkg['package']}* — {text} <{url}>")


def _group(title: str, entries: list[str]) -> list[str]:
    if not entries:
        return []
    return [f"**{title}**", "", *[e for pair in ((x, "") for x in entries) for e in pair]]


def render_block(manifest: dict, versions: dict) -> str:
    pkgs = manifest["packages"]
    counts = manifest["counts"]

    cran_members = [p for p in pkgs if p["family"] == "member" and p["cran"]]
    github_only = [p for p in pkgs if p["family"] == "member" and not p["cran"]]
    standalone = [p for p in pkgs if p["family"] == "standalone"]
    book = [p for p in pkgs if p["family"] == "book"]

    members = len(cran_members) + len(github_only)
    if counts.get("members") != members:
        raise ValueError(
            f"manifest counts.members is {counts.get('members')} but it lists {members} members"
        )
    if counts.get("members_github_only") != len(github_only):
        raise ValueError(
            f"manifest counts.members_github_only is {counts.get('members_github_only')} "
            f"but it lists {len(github_only)}"
        )
    known = {p["package"] for p in cran_members}
    unknown = [n for n in manifest["cran_member_names"] if n not in known]
    if unknown:
        raise ValueError(
            f"manifest cran_member_names lists {', '.join(unknown)}, "
            "which is not a member carrying a cran field"
        )

    names = manifest["cran_member_names"]
    lead = (
        f"{number_word(counts['members']).capitalize()} member packages — "
        f"the {number_word(counts['members_github_only'])} below, plus {_join(names)} "
        "above — resolved from public GitHub repositories and installed, updated and "
        "version-checked as a unit by *hvtiR*, a one-command installer and environment "
        f"diagnostic. <{INSTALLER_URL}>"
        if names else
        f"{number_word(counts['members']).capitalize()} member packages, listed below, "
        "resolved from public GitHub repositories and installed, updated and "
        "version-checked as a unit by *hvtiR*, a one-command installer and environment "
        f"diagnostic. <{INSTALLER_URL}>"
    )

    lines: list[str] = []
    lines += _group("R Packages (CRAN)", [_entry(p, versions) for p in cran_members])
    if github_only:
        lines += ["**HVTI R Package Family**", "", _wrap(lead), ""]
        lines += [e for pair in ((_entry(p, versions), "") for p in github_only) for e in pair]
    lines += _group("Open-Source Documentation", [_entry(p, versions) for p in book])
    lines += _group("SAS/C Software", [_entry(p, versions) for p in standalone])

    while lines and lines[-1] == "":
        lines.pop()
    return "\n".join(lines)


def _ordered(manifest: dict) -> list[dict]:
    pkgs = manifest["packages"]
    return (
        [p for p in pkgs if p["family"] == "member" and p["cran"]]
        + [p for p in pkgs if p["family"] == "standalone"]
        + sorted((p for p in pkgs if p["family"] == "member" and not p["cran"]),
                 key=lambda p: p["package"].lower())
        + [p for p in pkgs if p["family"] == "book"]
    )


def _decorated_blurb(pkg: dict) -> str:
    text = pkg["blurb"].replace(" -- ", " — ")
    if pkg["family"] == "book":
        text += " Quarto book, CC BY 4.0."
    if pkg["status"] == "wip":
        text = text.rstrip().removesuffix(".") + "; in active development."
    if pkg["role"]:
        text += f" ({pkg['role']})"
    return text


def render_checklist_block(manifest: dict) -> str:
    """Rows for the LinkedIn checklist: an unchecked box per published item."""
    rows = []
    for pkg in _ordered(manifest):
        path = pkg["url"].replace("https://", "").rstrip("/")
        if pkg["family"] == "book":
            path = pkg["url"].replace("https://", "")
        rows.append(f"- [ ] **{pkg['package']}** — {path}\n  > {_decorated_blurb(pkg)}")
    return "\n\n".join(rows)


def render_summary_line(manifest: dict) -> str:
    """The one-line \"open-source software\" summary pasted into a profile."""
    pkgs = manifest["packages"]
    cran = [p["package"] for p in pkgs if p["family"] == "member" and p["cran"]]
    fam = sorted((p["package"] for p in pkgs if p["family"] == "member" and not p["cran"]),
                 key=str.lower)
    sas = [p["package"] for p in pkgs if p["family"] == "standalone"]
    parts = []
    if cran:
        parts.append(f"{' · '.join(cran)} (CRAN)")
    parts.append(f"the {number_word(len(fam))}-package hvtiR family ({', '.join(fam)})")
    if sas:
        parts.append(f"{' · '.join(sas)} (SAS/C)")
    return "Open-source software: " + " · ".join(parts)


def splice(document: str, block: str, name: str = "packages") -> str:
    """Replace one named region, leaving every other region untouched."""
    begin, end_marker = f"<!-- BEGIN:{name} -->", f"<!-- END:{name} -->"
    start = document.find(begin)
    if start < 0:
        raise ValueError(f"{begin} not found; cannot splice")
    end = document.find(end_marker, start)
    if end < 0:
        raise ValueError(f"{end_marker} not found after {begin}; cannot splice")
    return f"{document[: start + len(begin)]}\n{block}\n{document[end:]}"


def _fetch_text(url: str, timeout: int = 30) -> str:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=timeout) as resp:
        if resp.status != 200:
            raise OSError(f"{url} returned HTTP {resp.status}")
        return resp.read().decode()


fetch_text = _fetch_text


def _retrying_fetch(url: str, attempts: int):
    last = None
    for attempt in range(1, attempts + 1):
        try:
            return fetch_text(url, timeout=30)
        except Exception as exc:
            last = exc
            if attempt < attempts:
                time.sleep(2 ** (attempt - 1))
    raise NetworkError(f"could not fetch {url} after {attempts} attempts: {last}")


def cran_versions(names: list[str], attempts: int = 3) -> dict:
    """Current CRAN version per package.

    A lookup failure omits that package rather than aborting: the CV reads
    correctly without a version number, and blocking the whole render on a
    second external service would make the CV hostage to crandb's uptime.
    """
    out = {}
    for name in names:
        try:
            body = _retrying_fetch(CRANDB_URL.format(name), attempts)
            version = json.loads(body).get("Version")
        except (NetworkError, ValueError) as exc:
            # Visible, not silent: an unnoticed failure here once rendered the
            # whole section with no version numbers and looked like success.
            print(f"warning: no CRAN version for {name}: {exc}", file=sys.stderr)
            continue
        if version:
            out[name] = version
    return out


def load_manifest(source: str, attempts: int = 3) -> dict:
    if source.startswith(("http://", "https://")):
        manifest = json.loads(_retrying_fetch(source, attempts))
    else:
        manifest = json.loads(Path(source).read_text())

    for key in ("packages", "counts", "cran_member_names"):
        if key not in manifest:
            raise ValueError(f"manifest is missing required key: {key}")
    if not manifest["packages"]:
        raise ValueError("manifest lists no packages; refusing to publish an empty section")
    return manifest


def targets(root: Path) -> list:
    """Every generated region, as (path, region name, renderer).

    The CV and the checklist share a manifest but not a shape: one is Quarto
    prose, the other a working task list with an unchecked box per item.
    """
    return [
        (root / "JohnEhrlinger-CV.qmd", "packages",
         lambda m, v: render_block(m, v)),
        (root / "linkedin-update-checklist.md", "packages",
         lambda m, v: render_checklist_block(m)),
        (root / "linkedin-update-checklist.md", "summary",
         lambda m, v: "> " + render_summary_line(m)),
    ]


def main(argv=None) -> int:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", default=MANIFEST_URL)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--no-cran", action="store_true",
                        help="skip crandb lookups; entries render without versions")
    args = parser.parse_args(argv)

    try:
        manifest = load_manifest(args.manifest)
    except NetworkError as exc:
        if args.check:
            print(f"skipping check: {exc}", file=sys.stderr)
            return 0
        print(f"error: {exc}", file=sys.stderr)
        return 1

    versions = {} if args.no_cran else cran_versions(manifest["cran_member_names"])

    # Group by file so a file with several regions is written once, and a
    # partial failure never leaves it half-rendered.
    pending: dict = {}
    for path, name, render in targets(root):
        text = pending.get(path, path.read_text())
        pending[path] = splice(text, render(manifest, versions), name=name)

    stale = [p for p, text in pending.items() if text != p.read_text()]

    if args.check:
        if stale:
            for p in stale:
                print(f"{p} is out of date with {args.manifest}", file=sys.stderr)
            return 1
        print(f"{len(pending)} file(s) up to date")
        return 0

    if not stale:
        print(f"{len(pending)} file(s) already up to date")
        return 0
    for p in stale:
        p.write_text(pending[p])
        print(f"updated {p}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
