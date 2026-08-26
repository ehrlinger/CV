# Design: single-source package manifest for the CV sinks

**Date:** 2026-08-26
**Status:** Approved design, pending implementation plan
**Author:** John Ehrlinger (with Claude)

## Problem

The HVTI R package family is described by hand in three independent git
repositories, each in a different format:

| Repo | Remote | Sink | Format |
|---|---|---|---|
| `CV/` | `ehrlinger/CV` | `JohnEhrlinger-CV.qmd` §Software | Quarto prose entries |
| `ehrlinger/` | `ehrlinger/ehrlinger` (profile) | `README.md` | Two Markdown tables |
| `ehrlinger.github.io/` | `ehrlinger/ehrlinger.github.io` | `index.html` | HTML card grid |

These three live side by side in the `CV2026` folder, which is **not itself a
repository**. There is no shared build, no shared data file, and no check that
the three agree.

The cost is visible in the logs. The same logical edit has landed three times
by hand, twice in a row:

```
d654307 / d6b5d74 / 31f4bd6   fix: keep the installer out of the member list
6ab85bd / 0580196 / 136e37c   fix: reconcile the stated family count with the packages listed
```

Two further sinks have already drifted:

- `linkedin-update-checklist.md:27` still names `boostmtree` (renamed to
  `hvtiBoostmtree`) and lists 3 of the 9 family members.
- The Quarto book is called **HVTI Recipes** in `CV/JohnEhrlinger-CV.qmd` and
  `ehrlinger/README.md`, but **HVTI Graphics Recipes** on the site. Same
  artifact, two names, live today.

Meanwhile the authoritative membership list already exists and is already
tested: `hvtiR::members()` in `hvtiR/R/members.R` returns the 11 member
packages with their `owner/repo` mapping, including the two whose package name
differs from their repository (`hvtiRpropensity` → `ehrlinger/hvtiPropensityScores`,
`TemporalHazard` → `ehrlinger/temporal_hazard`). Every CV sink is a hand-copied
projection of that table.

## Path conventions in this document

This design spans four repositories. Paths are therefore written
`<repo>/<path-from-that-repo-root>`, where `<repo>` is the directory name each
one is checked out as inside `CV2026`:

| Prefix | Repository | Note |
|---|---|---|
| `CV/` | `ehrlinger/CV` | This repository. |
| `ehrlinger/` | `ehrlinger/ehrlinger` | The GitHub profile repo. |
| `ehrlinger.github.io/` | `ehrlinger/ehrlinger.github.io` | The user site. |
| `hvtiR/` | `ehrlinger/hvtiR` | The upstream registry. Formerly `ehrlinger/hvtiverse`; the repo was renamed to match the package it contains, and the old name still redirects. Some local checkouts are still in a `hvtiverse/` directory. |

Paths are prefixed rather than left bare because this design spans four
repositories: an unqualified `R/members.R` gives no clue which of them it lives
in.

An unprefixed path is relative to whichever repo that section is about, and is
used only where a section applies to every consumer repo alike (for example
`tools/render_packages.py`, which each of the three sinks gets its own copy of).

## Goal

One source of truth for *which* packages exist and *what each one is*, with
each repo rendering that source in its own house style. Adding a package to
`hvtiR::members()` should propagate to all three sinks without a human
retyping anything, and no sink should be able to silently disagree.

## Non-goals

- Merging the three repositories. GitHub *requires* the profile README to live
  in `ehrlinger/ehrlinger` and the user site in `ehrlinger.github.io`; they
  cannot be one repo.
- Syncing `quarto-prototypes/`. Out of scope — treated as dead prototypes.
- Generating publication, talk, or employment sections. Software only.
- Auto-merging. Every propagated change arrives as a PR for review.

## Decisions taken

| Question | Decision |
|---|---|
| Prose model | **One canonical blurb, three renderers.** Status / CRAN / role are manifest *fields*, not prose, so each renderer decorates the shared blurb in its own style. |
| Manifest home | **Published by `hvtiR` (`ehrlinger/hvtiR`).** The registry that already exists becomes the single upstream source. |
| Update trigger | **Scheduled PR bot per repo.** Weekly cron + `workflow_dispatch`; opens a PR, never pushes to `main`. |
| Generation scope | **The three repos only.** The NIH biosketch and LinkedIn checklist are fixed once by hand, not generated. |

---

## 1. Source of truth — `hvtiR`

`members()` is left **exactly as it is**. Its documented contract is two
character columns, it is exported, and `install_members()` / `status()` depend
on it. Adding presentation columns would break that contract for no gain.

Presentation metadata goes in a sibling data file:

```
hvtiR/inst/extdata/catalog.csv
```

### Schema

| Column | Type | Values | Notes |
|---|---|---|---|
| `package` | chr | — | Display name. For `family == "member"`, must equal a `members()$package`. |
| `repo` | chr | `owner/repo` or empty | Must equal the matching `members()$repo` where applicable. Empty for the book. |
| `family` | chr | `member` \| `standalone` \| `book` | Governs which section a renderer places it in. |
| `blurb` | chr | non-empty | The one canonical description. **No status or CRAN text.** |
| `cran` | chr | CRAN package name or empty | Presence drives the CRAN badge/link/sentence. |
| `status` | chr | `stable` \| `wip` | Drives the in-development marker. |
| `role` | chr | badge label or empty | Free-text role badge for cases not derivable from other fields. Only `hazard` uses it today (`Maintainer`). |
| `homepage` | chr | URL or empty | Overrides the derived GitHub URL (used by the book). |

`family` is what lets the catalog carry entries that can never come from
`members()`: `hazard` (SAS/C, not an R package) and the Quarto book — both
appear in all three sinks today.

### Why status and CRAN must be fields

The same fact is rendered three different ways. Keeping it in prose is exactly
what forces three hand-edits:

| Manifest | CV renders | README renders | Site renders |
|---|---|---|---|
| `status: wip` | `; in active development.` | `(in active development)` | `<span class="pkg-role">WIP</span>` |
| `cran: TemporalHazard` | `v1.1.0 on CRAN.` | `— [on CRAN](…)` | `<span class="pkg-role">CRAN</span>` |
| `family: book` | `Quarto book, CC BY 4.0.` | `(Quarto book, CC BY 4.0)` | `<span class="pkg-role">Book</span>` |
| `role: Maintainer` | `(Maintainer)` | `(Maintainer)` | `<span class="pkg-role">Maintainer</span>` |

With these extracted, one shared `blurb` genuinely serves all three.

### Proposed initial contents

Reconciled from the three current variants. `hvtiRtables` and `hvtiRtemplates`
carry no in-development marker in any sink today, so they are `stable`; the
four marked WIP agree across all three sinks already.

| package | family | status | cran | blurb |
|---|---|---|---|---|
| ggRandomForests | member | stable | ggRandomForests | Visual exploration of random forest models — graphical analysis of survival, regression, and classification forests. |
| TemporalHazard | member | stable | TemporalHazard | R port of the C computational core underlying the Cleveland Clinic Hazard SAS module. |
| hvtiBoostmtree | member | stable | | Boosted multivariate trees for longitudinal data; an extended fork of boostmtree. |
| hvtiPlotR | member | stable | | HVTI-standard publication graphics for reproducible clinical research figures. |
| hvtiRbootstrap | member | wip | | Bootstrap model building — fit across many replicates and report how often each variable survives selection; an R port of the bootreg, SUMBOOT and cluster SAS macros. |
| hvtiRdatasets | member | wip | | Analysis-ready clinical datasets for HVTI CORR studies, verified against the legacy SAS datasets they replace. |
| hvtiRlifetables | member | wip | | Age-, sex- and race-matched US reference survival; replaces the usmatchd SAS macro by evaluating a stored three-phase parametric hazard fit rather than interpolating a life table. |
| hvtiRpropensity | member | wip | | Propensity score estimation, matching and IPTW with standardized balance diagnostics, for cardiac surgery comparative-effectiveness research. |
| hvtiRtables | member | stable | | Manuscript-compliant Word tables from gtsummary objects, following HVTI CORR table construction standards, with a JTCVS submission mode. |
| hvtiRtemplates | member | stable | | Versioned analysis job templates and the analysis-prefix taxonomy the CORR group organizes jobs by, so a study binds to a versioned template rather than to a copy. |
| hvtiRutilities | member | stable | | Utility functions supporting reproducible HVTI research workflows. |
| hazard | standalone | stable | | SAS and C implementation of multi-phase hazard analysis for time-to-event decomposition. |
| HVTI Recipes | book | stable | | Catalog of publication-ready figures, tables, and datasets for clinical outcomes research — Kaplan-Meier, propensity balance, CONSORT, random-forest visualizations — each paired with reproducible code. |

Columns omitted from this summary table for width: `repo` (from `members()`,
or empty for the book), `homepage` (the book's Quarto URL), and `role` — which
is `Maintainer` for `hazard` and empty for every other row.

**This table resolves the HVTI Recipes / HVTI Graphics Recipes name split in
favour of "HVTI Recipes".**

### Validation at the source

A `testthat` test in `hvtiR/tests/testthat/test-catalog.R` asserts:

1. Rows with `family == "member"` are **exactly** `members()$package` — no
   extras, none missing.
2. Their `repo` values match `members()$repo` exactly.
3. Every row has a non-empty `blurb`.
4. `family` and `status` values are within their allowed sets.
5. `package` values are unique.

This is the drift guard at the source: adding a package to `members()` without
cataloguing it fails `R CMD check` before anything downstream ever sees it.

Reading uses `utils::read.csv()` — already in `Imports`. **No new R dependency.**

---

## 2. Published artifact

The existing `hvtiR/.github/workflows/pkgdown.yaml` gains one step that
converts `hvtiR/inst/extdata/catalog.csv` to `members.json` and includes it in the gh-pages
payload. The conversion is a stdlib-only Python script (`csv` + `json`) run on
the runner, so no R package dependency is added for JSON writing.

Published at:

```
https://ehrlinger.github.io/hvtiR/members.json
```

The path is `/hvtiR/` because pkgdown publishes under the package name (see
`DESCRIPTION` `URL:`). Repo and package now share that name.

### `members.json` schema

```json
{
  "generated_from": "hvtiR 1.0.1",
  "counts": {
    "members": 11,
    "members_on_cran": 2,
    "members_github_only": 9
  },
  "cran_member_names": ["ggRandomForests", "TemporalHazard"],
  "packages": [
    {
      "package": "hvtiPlotR",
      "repo": "ehrlinger/hvtiPlotR",
      "url": "https://github.com/ehrlinger/hvtiPlotR",
      "family": "member",
      "blurb": "HVTI-standard publication graphics for reproducible clinical research figures.",
      "cran": null,
      "status": "stable"
    }
  ]
}
```

`counts` and `cran_member_names` are **derived, never authored**. They exist so
that the sentence

> "eleven member packages, the nine below plus `ggRandomForests` and
> `TemporalHazard` above"

which appears verbatim in all three sinks is *computed*. That exact sentence is
what commit `6ab85bd` had to hand-fix in three places.

One plain HTTPS GET, no auth, no GitHub API rate limit, no PAT anywhere.

---

## 3. Renderers — one per repo, vendored

Each repo gets `tools/render_packages.py`: Python 3, standard library only
(`json`, `re`, `urllib.request`, `argparse`). Python is already established in
`CV/` (`clean-bib-for-typst.py`) and needs no runner setup.

### Marker convention

One convention covers all three formats, because HTML comments survive
Quarto → PDF, Markdown → GitHub, and raw HTML alike:

```html
<!-- BEGIN:packages -->
… generated content …
<!-- END:packages -->
```

Content outside the markers is never touched.

### Why vendored, not fetched

Publishing the renderer next to the manifest would mean three CI jobs
executing remote code on every scheduled run. A vendored copy keeps each repo
self-contained and independently buildable, which was the reason for choosing
the loose-coupling approach. Only the ~40-line format function differs per
repo; the fetch-validate-splice half (~40 lines) is shared boilerplate. The
thing that actually drifted was content, not code.

### Per-repo output

**`CV/JohnEhrlinger-CV.qmd`** — Quarto prose, grouped `**R Packages (CRAN)**` /
`**HVTI R Package Family**` / `**Open-Source Documentation**` / `**SAS/C Software**`,
matching the current §Software structure. Emits the computed family-count
sentence. CRAN version numbers come from the `cran` field plus a CRAN lookup at
render time (see Open Questions).

**`ehrlinger/README.md`** — two Markdown tables (standalone + book first, then
the family), with the family blurb paragraph and computed counts between them.

**`ehrlinger.github.io/index.html`** — `<div class="pkg">` cards inside
`<div class="pkg-grid">`, with `<span class="pkg-role">` badges for `CRAN`,
`WIP`, `Book`, and `Maintainer`. Em-dashes are emitted as `&mdash;` to match
the file's existing convention.

### Modes

```
render_packages.py            # rewrite the sink in place
render_packages.py --check    # regenerate in memory, exit 1 on drift, write nothing
```

---

## 4. Update flow

Each repo gets `.github/workflows/sync-packages.yml`:

```yaml
on:
  schedule: [{cron: '0 6 * * 1'}]   # Monday 06:00 UTC
  workflow_dispatch:
```

Steps:

1. Checkout.
2. Fetch `members.json`. **Fail the job on any non-200 or malformed body.**
3. Run `tools/render_packages.py`.
4. `git diff --quiet` → clean: exit 0, no PR.
5. Changed: `peter-evans/create-pull-request` opens or updates a single branch,
   `chore/sync-packages`.

You review and merge. Nothing reaches `main` unreviewed: every change to a
published sink arrives as a pull request, never as a direct push. Reusing one
branch means repeated runs update the existing PR rather than opening a second.

`ehrlinger/` and `ehrlinger.github.io/` get their first workflows; `CV/` gets a
second alongside `build-cv.yml`.

---

## 5. Failure modes — all loud

| Failure | Behaviour |
|---|---|
| `members.json` fetch fails (404, network, timeout) | Job **fails**. Never regenerate from a stale, empty, or partial manifest. |
| `members.json` parses but fails schema validation | Job **fails** naming the offending field. |
| Markers missing or unbalanced in a sink | Exit non-zero naming the file and the marker expected. |
| Member in `members()` absent from `catalog.csv` | Caught upstream by `test-catalog.R` — never publishes. |
| Hand-edit inside the markers | `--check` in that repo's CI fails the build. |
| Nothing changed | Exit 0 silently, no PR, no noise. |

No failure mode silently produces a smaller or emptier package list. That is
the one outcome to avoid, because it would look like a successful sync.

---

## 6. Testing

**`hvtiR` (upstream)**
- `hvtiR/tests/testthat/test-catalog.R` — the five assertions in §1.
- A test that the CSV → JSON converter round-trips the catalog and that
  `counts` match a hand-computed expectation for a fixture.

**Each renderer**
- Golden-file test: a fixture `members.json` in, an expected block out. Three
  fixtures — one nominal, one with a new member added, one with a member
  removed — so the count arithmetic is exercised, not just the happy path.

**Each repo**
- `render_packages.py --check` wired into CI. For `CV/` it bolts onto the
  existing `build-cv.yml`; the other two get it in `sync-packages.yml` on
  `push` and `pull_request`.

---

## 7. One-time fixes, no automation

Per the scope decision, these are corrected by hand and not generated:

- **`linkedin-update-checklist.md:27`** — `boostmtree` → `hvtiBoostmtree`, and
  expand from 3 to all 9 GitHub-only members.
  *Caveat:* this file is untracked by any repo, sitting loose in `CV2026`, so
  **no CI can ever check it**. It will drift again. The alternative is moving
  it into `CV/` so `--check` can cover it. Left as the author's call.
- **`CV/JohnEhrlinger-Biosketch-NIH.md`** — carries no member list, only
  generic `hvtiR` / `ggRandomForests` references. Nothing to generate. Verify
  the references still read correctly after the catalog lands; add the computed
  count sentence only if it is wanted there at all.
- **The book name split** — the site's "HVTI Graphics Recipes" becomes
  "HVTI Recipes" when the site block is first generated.

---

## 8. Build order

1. `hvtiR`: `catalog.csv` + `test-catalog.R` + CSV→JSON converter + `pkgdown.yaml` step.
   *Verify:* `members.json` is live at the published URL.
2. `ehrlinger/README.md`: renderer, markers, workflow.
   *Verify:* a deliberate catalog change produces the expected PR.
3. `ehrlinger.github.io/index.html`: renderer, markers, workflow.
4. `CV/JohnEhrlinger-CV.qmd`: renderer, markers, workflow, plus `--check` in
   `build-cv.yml`.
   *Verify:* the rendered PDF and Markdown CV are unchanged apart from the
   intended reconciliations.
5. One-time fixes from §7.

Step 1 is a hard prerequisite for 2–4. Steps 2, 3, and 4 are independent of
each other. The README goes first because it is the simplest format and the
fastest way to prove the whole pipeline end to end.

---

## 9. Open questions

1. **CRAN version numbers in the CV.** The CV currently states `v3.5.2 on CRAN`
   and `v1.1.0 on CRAN`. Those go stale on every CRAN release. Options: query
   `https://crandb.r-pkg.org/<pkg>` at render time (network dependency in the
   sync job, but always correct); carry a `cran_version` field in the catalog
   (hand-maintained, drifts); or drop version numbers from the CV entirely and
   just link to CRAN. **Recommendation: query at render time** — the job
   already requires network for `members.json`, so it adds no new failure class.
2. **Spec location.** This document lives in `CV/` because `CV2026` is not a
   repository and `CV/` is the primary consumer and not an R package (so no
   `.Rbuildignore` concerns). If the work is better tracked upstream, it could
   move to the `ehrlinger/hvtiR` repo, which would need a `.Rbuildignore`
   entry so the spec does not ship inside the `hvtiR` tarball.
