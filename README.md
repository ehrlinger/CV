# John Ehrlinger — CV Repository

Source files for John Ehrlinger's curriculum vitae and NIH biographical sketch.

## Files

| File | Description |
|---|---|
| `JohnEhrlinger-CV.tex` | LaTeX source — canonical CV |
| `JohnEhrlinger-CV.md` | Markdown version — mirrors the LaTeX content |
| `JohnEhrlinger-Biosketch-NIH.md` | NIH Biographical Sketch (Markdown) |
| `JohnEhrlinger-Biosketch-NIH.tex` | NIH Biographical Sketch (LaTeX, nihbiosketch.cls) |
| `cv-primary.bib` | Primary publications (BibTeX) |
| `submitted.bib` | Manuscripts under revision (BibTeX) |
| `inprep.bib` | Manuscripts in preparation (BibTeX) |
| `technotes.bib` | Technical notes / arXiv preprints (BibTeX) |
| `talks.bib` | Conference presentations (BibTeX) |

## Building the CV PDF

Requires a LaTeX distribution with `biber` (e.g., TeX Live or MacTeX).

```bash
pdflatex JohnEhrlinger-CV
biber    JohnEhrlinger-CV
pdflatex JohnEhrlinger-CV
pdflatex JohnEhrlinger-CV
```

Or with `latexmk`:

```bash
latexmk -pdf JohnEhrlinger-CV
```

## Building the NIH Biosketch PDF

The biosketch uses Paul Magwene's `nihbiosketch.cls`. Download it once:

```bash
curl -fsSL \
  https://raw.githubusercontent.com/pmagwene/latex-nihbiosketch/master/nihbiosketch.cls \
  -o nihbiosketch.cls
```

Then compile:

```bash
pdflatex JohnEhrlinger-Biosketch-NIH
```

## GitHub Setup (first time)

```bash
cd /path/to/CV2026
git init

# Stage source files (excluding HANDOFF.md and .claude/ — see .gitignore)
git add JohnEhrlinger-CV.tex JohnEhrlinger-CV.md
git add JohnEhrlinger-Biosketch-NIH.md JohnEhrlinger-Biosketch-NIH.tex
git add cv-primary.bib submitted.bib inprep.bib pending.bib technotes.bib talks.bib
git add _header.tex nihbiosketch.cls README.md index.md .gitignore
git add .github/

git commit -m "Initial commit: CV and NIH biosketch source files"
git remote add origin https://github.com/ehrlinger/CV2026.git
git branch -M main
git push -u origin main
```

## GitHub Actions (auto-build)

On every push to `main`, the workflow in `.github/workflows/build-cv.yml` will:

1. Compile `JohnEhrlinger-CV.tex` → PDF (pdflatex + biber)
2. Compile `JohnEhrlinger-Biosketch-NIH.tex` → PDF
3. Upload both PDFs as build artifacts (retained 90 days)
4. Deploy the PDF and `index.md` to the `gh-pages` branch

## GitHub Pages (ehrlinger.github.io/CV2026)

After the first successful Actions run:

1. Go to **Settings → Pages** in the CV2026 repo
2. Set Source to **Deploy from branch → gh-pages → / (root)**
3. The CV landing page will be live at `https://ehrlinger.github.io/CV2026`

To link from your main `ehrlinger.github.io` page, add:

```markdown
[CV](https://ehrlinger.github.io/CV2026)
```

## Keeping formats in sync

The `.md` and `.tex` files mirror each other. When updating one, update the other:

- **Professional Experience** — update both `.tex` and `.md`
- **Publications** — primary source is `cv-primary.bib`; update `\nocite` in `.tex` and the Publications section of `.md`
- **In Preparation / In Revision** — update `inprep.bib` / `submitted.bib` and mirror in `.md`
- **NIH Biosketch** — maintained in both `.md` and `.tex`; Personal Statement should be tailored per grant before submission

## Notes

- `eRA Commons User Name` in the biosketch is marked `⚠️ [FILL IN BEFORE SUBMISSION]`
- `nihbiosketch.cls` is not committed to the repo — the Actions workflow downloads it at build time
- PDFs are excluded from version control by default (`.gitignore`); the Actions workflow generates them
