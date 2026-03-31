#!/usr/bin/env python3
"""
Produces Typst-safe copies of .bib files by:
  1. Removing \myname{...} wrappers  →  plain author name
  2. Wrapping bare month values      →  month={Jun} instead of month=Jun

Usage:  python3 clean-bib-for-typst.py
Output: typst-*.bib files alongside the originals
"""

import re
from pathlib import Path

BIB_FILES = [
    "cv-primary.bib",
    "submitted.bib",
    "inprep.bib",
    "technotes.bib",
    "talks.bib",
]

def clean(text: str) -> str:
    # 1. Strip \myname{...} → just the contents
    text = re.sub(r'\\myname\{([^}]*)\}', r'\1', text)

    # 2. Remove % comment lines — Typst's BibTeX parser does not support
    #    % comments inside @entry{} blocks (unlike biber which is lenient)
    lines = []
    for line in text.splitlines():
        if re.match(r'^\s*%', line):
            continue   # drop the line entirely
        lines.append(line)
    text = '\n'.join(lines)

    # 3. Fix bare month= values: month=Jun → month={Jun}
    text = re.sub(
        r'(\bmonth\s*=\s*)([A-Za-z]+)(\s*[,}])',
        r'\1{\2}\3',
        text
    )

    # 4. Remove LaTeX math in titles: {$L_2$} → L_2 (Typst can't parse $...$)
    text = re.sub(r'\{\$([^$]*)\$\}', r'\1', text)

    return text

merged = []
for bib in BIB_FILES:
    src = Path(bib)
    if not src.exists():
        print(f"  skipping {bib} (not found)")
        continue
    merged.append(clean(src.read_text(encoding="utf-8")))
    print(f"  cleaned {bib}")

out = Path("typst-all.bib")
out.write_text("\n\n".join(merged), encoding="utf-8")
print(f"  wrote {out} (merged)")
print("Done.")
