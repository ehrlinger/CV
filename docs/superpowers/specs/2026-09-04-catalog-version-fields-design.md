# Catalog version fields — design

**Date:** 2026-09-04
**Status:** Draft, one open decision (§6)
**Extends:** [2026-08-26 package manifest sync design](2026-08-26-package-manifest-sync-design.md)

## 1. What prompted this

On 2026-09-04 the family table in `Projects/CV and Professional Profile.md`
was audited against every repository's `DESCRIPTION`. **Six of ten version
rows were stale**, and *both* cells marked bold — the marking whose caption
promised a `DESCRIPTION`-backed reading — were wrong:

| Package | Note said | `main` said |
|---|---|---|
| `hvtiR` | 1.0.8 | 1.1.2 |
| `hvtiPlotR` | **2.7.10** | 2.7.12 |
| `hvtiRbootstrap` | 0.1.0 | 0.9.3 |
| `hvtiRlifetables` | 0.1.1 | 0.1.3 |
| `hvtiRtemplates` | 1.0.3 | 1.1.0 |
| `hvtiRutilities` | **1.1.4** | 1.1.9 |

The table had been verified on 2026-08-28. It went that stale in seven days.

## 2. The correction to the obvious design

The obvious extension is "add a `version` column to `catalog.csv` and render
it into the CV." **That is the wrong shape, for two reasons.**

**The CV barely consumes versions.** `JohnEhrlinger-CV.qmd` cites exactly two
version numbers in its whole Software section — `v3.5.2 on CRAN` and
`v1.1.0 on CRAN`. The nine family members carry no version, only
`; in active development.` A rendered version column would populate two cells.

**For those two cells, `main` is the wrong oracle.** Both CRAN packages run a
development `main` ahead of CRAN, under in-house HVTI testing before the next
cut (John, 2026-09-04). `ggRandomForests` is 4.0.0 on `main` against 3.5.2 on
CRAN — a full major digit. Rendering `main` into the CV would publish a major
version that is still under test.

So the deliverable is **not** a render input. It is a **drift check**: the
catalog holds versions so that something can *fail* when the recorded value
and the live value disagree, keeping the internal tracking note honest. The
CV render is a separate, much smaller consumer.

## 3. Fields

Three new columns on the catalog, replacing the single `version` a naive
design would add:

| Field | Meaning | Oracle |
|---|---|---|
| `cran_version` | What the public can install. Empty for non-CRAN packages. | `https://crandb.r-pkg.org/<pkg>` → `.Version` |
| `dev_version` | What `main` carries. | `git show origin/main:DESCRIPTION` → `Version:` |
| `dev_ahead` | `expected` \| `unexpected`. Whether `dev_version` > `cran_version` is intended. | Hand-set; the only hand-maintained field of the three |

`dev_ahead` exists because **a gap and a rot are indistinguishable by
inspection.** `hvtiRbootstrap` at 0.1.0-vs-0.9.3 was rot. `TemporalHazard` at
1.1.0-vs-1.2.9 is policy. Both read as "the record is behind the repo," and no
oracle can tell them apart — intent is not a fact any lookup returns. Without
this field the check either flags the deliberate gaps every run until someone
silences it, or stays quiet about real rot.

## 4. Oracle rules

These are the rules the audit had to learn the hard way. They belong in the
implementation, not in a reviewer's memory.

1. **Read `origin/main`, never the working tree.** On audit day **six of
   eleven clones sat on feature branches** whose `DESCRIPTION` ran ahead of
   what was released. `ggBoostedTrees` read 0.0.6 on its branch against 0.0.5
   on `main`. A `grep ^Version DESCRIPTION` sweep across local clones would
   have recorded unreleased numbers.
2. **Never read a repomap.** `Claude/repomaps/` is a *cache* of a
   `DESCRIPTION`, refreshed on a 15-minute timer against whatever clone is
   indexed — which for `hvtiRpropensity` was the pre-rename one, stuck at
   0.1.1. The bold convention that failed in §1 was "verified via repomap."
   Repomaps are fine for orientation and wrong for provenance.
3. **CRAN is its own oracle.** `crandb.r-pkg.org` returns `Version` and
   `Date/Publication`. Do not infer the CRAN version from a `DESCRIPTION`, a
   git tag, or a `NEWS.md` heading.
4. **Record when, not just what.** Every version fact carries the timestamp it
   was read at. A freshness claim without a date is false within a week at the
   current merge rate — which is precisely how §1 happened.

## 5. The check

A `testthat` test alongside the existing catalog tests in
`hvtiR/tests/testthat/test-catalog.R`:

```
test_that("catalog versions match their oracles", {
  skip_on_cran()
  skip_if_offline()
  # dev_version == origin/main DESCRIPTION for every row with a repo
  # cran_version == crandb Version for every row with a non-empty cran field
  # dev_ahead == "expected" wherever dev_version > cran_version
  #   -> a NEW unexplained gap fails; a KNOWN one does not
})
```

It is network-dependent and therefore `skip_on_cran()` +
`skip_if_offline()` — it is a maintenance check, not a package correctness
check, and must never block a CRAN submission of `hvtiR` itself.

## 6. OPEN DECISION — where the check runs

This is the trade-off flagged before drafting, and it is yours to settle.

**Option A — scheduled CI (recommended).** A weekly GitHub Actions job in
`hvtiR` runs the check and opens an issue listing every row that drifted.
*For:* catches drift without anyone remembering to look, which is the actual
failure mode — the table was audited 2026-08-28 and nobody looked again until
prompted. *Against:* one more workflow to maintain; needs network in CI.

**Option B — on-demand only.** The test exists but runs when someone runs it,
e.g. as part of the existing release gate. *For:* nothing new to maintain,
no scheduled network calls. *Against:* it is exactly the "someone remembers"
model that produced six stale rows.

**Option C — render-time.** The CV build resolves versions live.
*Against:* couples the CV build to network and to eleven clones, to populate
two cells whose correct source is CRAN. **Not recommended** — see §2.

## 7. Explicitly out of scope

- Changing what the CV lists. The published surfaces were *ahead* of the
  tracking note on audit day: the CV, the profile README and
  `ehrlinger.github.io` all already listed `ggBoostedTrees`, and none listed
  the retired `hvtiBoostmtree`. The rot was internal.
- Automating the `blurb`, `status`, `family` or `role` fields — settled by the
  2026-08-26 design and unchanged here.
