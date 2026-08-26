"""Tests for the CV's Software-section renderer.

Fourth and last sink. This one owns Quarto prose: four labelled groups of
wrapped paragraphs rather than table rows or HTML cards, and CRAN entries that
carry a live version number and link to CRAN rather than to GitHub.
"""
import json
import re
import unittest

from render_packages import (
    MARKER_BEGIN, MARKER_END, WRAP, number_word, render_block, splice,
)

MANIFEST = {
    "generated_from": "hvtiR 9.9.9",
    "counts": {"members": 4, "members_on_cran": 1, "members_github_only": 3},
    "cran_member_names": ["alpha"],
    "packages": [
        {"package": "alpha", "repo": "ehrlinger/alpha", "url": "https://github.com/ehrlinger/alpha",
         "family": "member", "blurb": "First -- on CRAN.", "cran": "alpha", "status": "stable", "role": None},
        {"package": "beta", "repo": "ehrlinger/beta-repo", "url": "https://github.com/ehrlinger/beta-repo",
         "family": "member", "blurb": "Second, GitHub only.", "cran": None, "status": "wip", "role": None},
        {"package": "gamma", "repo": "ehrlinger/gamma", "url": "https://github.com/ehrlinger/gamma",
         "family": "member", "blurb": "Third.", "cran": None, "status": "stable", "role": None},
        {"package": "delta", "repo": "ehrlinger/delta", "url": "https://github.com/ehrlinger/delta",
         "family": "member", "blurb": "Fourth.", "cran": None, "status": "stable", "role": None},
        {"package": "sassy", "repo": "ehrlinger/sassy", "url": "https://github.com/ehrlinger/sassy",
         "family": "standalone", "blurb": "Not an R package.", "cran": None, "status": "stable", "role": "Maintainer"},
        {"package": "The Book", "repo": "ehrlinger/book", "url": "https://example.org/book/",
         "family": "book", "blurb": "A book.", "cran": None, "status": "stable", "role": None},
    ],
}
VERSIONS = {"alpha": "9.9.9"}


def block():
    return render_block(MANIFEST, VERSIONS)


class GroupTests(unittest.TestCase):
    def test_the_four_groups_appear_in_the_cv_order(self):
        heads = re.findall(r"^\*\*(.+?)\*\*$", block(), re.M)
        self.assertEqual(heads, [
            "R Packages (CRAN)",
            "HVTI R Package Family",
            "Open-Source Documentation",
            "SAS/C Software",
        ])

    def test_a_group_with_no_members_is_omitted_entirely(self):
        m = json.loads(json.dumps(MANIFEST))
        m["packages"] = [p for p in m["packages"] if p["family"] != "book"]
        self.assertNotIn("Open-Source Documentation", render_block(m, VERSIONS))

    def test_every_package_appears_exactly_once(self):
        b = block()
        for name in ("alpha", "beta", "gamma", "delta", "sassy", "The Book"):
            self.assertEqual(b.count(f"*{name}* —"), 1, name)


class EntryTests(unittest.TestCase):
    def _entry(self, name):
        # The final entry has no trailing blank line, so fall back to EOF.
        b = block()
        start = b.index(f"*{name}* —")
        end = b.find("\n\n", start)
        return b[start:] if end < 0 else b[start:end]

    def test_a_cran_entry_carries_the_live_version(self):
        self.assertIn("v9.9.9 on CRAN.", self._entry("alpha"))

    def test_a_cran_entry_links_to_cran_not_github(self):
        e = self._entry("alpha")
        self.assertIn("<https://CRAN.R-project.org/package=alpha>", e)
        self.assertNotIn("github.com", e)

    def test_a_github_only_member_links_to_its_repo(self):
        self.assertIn("<https://github.com/ehrlinger/beta-repo>", self._entry("beta"))

    def test_wip_is_appended_as_a_clause_not_a_sentence(self):
        # The CV writes "...macros; in active development." rather than a
        # separate sentence, so the blurb's full stop is replaced.
        e = self._entry("beta")
        self.assertIn("GitHub only; in active development.", e)
        self.assertNotIn("only. (in active", e)

    def test_a_role_follows_the_blurb_in_parentheses(self):
        self.assertIn("Not an R package. (Maintainer)", self._entry("sassy"))

    def test_the_book_states_its_licence(self):
        self.assertIn("Quarto book, CC BY 4.0.", self._entry("The Book"))

    def test_the_book_uses_its_homepage(self):
        self.assertIn("<https://example.org/book/>", self._entry("The Book"))

    def test_ascii_dash_becomes_a_literal_em_dash(self):
        self.assertIn("First — on CRAN", block())
        self.assertNotIn(" -- ", block())


class WrapTests(unittest.TestCase):
    def test_no_line_exceeds_the_files_wrap_width(self):
        over = [l for l in block().splitlines() if len(l) > WRAP]
        self.assertEqual(over, [])

    def test_a_long_url_is_not_broken_across_lines(self):
        for line in block().splitlines():
            if "http" in line:
                self.assertTrue(line.strip().endswith(">") or " <" in line, line)


class FamilyParagraphTests(unittest.TestCase):
    def test_counts_are_derived_and_spelled_out(self):
        self.assertIn("Four member packages — the three below", block())

    def test_cran_members_are_named_in_italics(self):
        self.assertIn("*alpha*", block())

    def test_no_dangling_clause_when_no_member_is_on_cran(self):
        m = json.loads(json.dumps(MANIFEST))
        for p in m["packages"]:
            p["cran"] = None
        m["cran_member_names"] = []
        m["counts"] = {"members": 4, "members_on_cran": 0, "members_github_only": 4}
        b = render_block(m, {})
        self.assertNotIn("plus  —", b)
        self.assertNotIn("above —", b)
        self.assertIn("Four member packages", b)

    def test_the_cran_group_is_omitted_when_no_member_is_on_cran(self):
        m = json.loads(json.dumps(MANIFEST))
        for p in m["packages"]:
            p["cran"] = None
        m["cran_member_names"] = []
        m["counts"] = {"members": 4, "members_on_cran": 0, "members_github_only": 4}
        self.assertNotIn("**R Packages (CRAN)**", render_block(m, {}))


class VersionTests(unittest.TestCase):
    def test_a_missing_version_omits_the_number_rather_than_inventing_one(self):
        e = render_block(MANIFEST, {})
        self.assertIn("On CRAN.", e)
        self.assertNotIn("vNone", e)
        self.assertNotIn("v on CRAN", e)


class CountDriftTests(unittest.TestCase):
    def test_a_contradictory_member_count_is_an_error(self):
        m = json.loads(json.dumps(MANIFEST))
        m["counts"]["members"] = 99
        with self.assertRaises(ValueError):
            render_block(m, VERSIONS)


class SpliceTests(unittest.TestCase):
    DOC = f"# Software\n\n{MARKER_BEGIN}\nOLD\n{MARKER_END}\n"

    def test_only_the_marked_region_is_replaced(self):
        out = splice(self.DOC, "NEW")
        self.assertIn("# Software", out)
        self.assertNotIn("OLD", out)

    def test_a_missing_marker_is_an_error(self):
        with self.assertRaises(ValueError):
            splice("nothing", "NEW")

    def test_rendering_twice_is_idempotent(self):
        once = splice(self.DOC, block())
        self.assertEqual(once, splice(once, block()))


class NetworkTests(unittest.TestCase):
    def test_cran_versions_survive_one_package_being_unreachable(self):
        import render_packages as rp
        def flaky(url, timeout=0):
            if "alpha" in url:
                raise OSError("down")
            return json.dumps({"Version": "1.2.3"})
        rp.fetch_text = flaky
        try:
            # A CRAN lookup failure must degrade to "no version", never abort
            # the render: the CV is still correct without the number.
            self.assertEqual(rp.cran_versions(["alpha"], attempts=1), {})
        finally:
            rp.fetch_text = rp._fetch_text

    def test_manifest_fetch_failure_is_a_network_error(self):
        import render_packages as rp
        rp.fetch_text = lambda url, timeout=0: (_ for _ in ()).throw(OSError("down"))
        try:
            with self.assertRaises(rp.NetworkError):
                rp.load_manifest("https://example.org/m.json")
        finally:
            rp.fetch_text = rp._fetch_text



class UserAgentTests(unittest.TestCase):
    """crandb answers 403 to the default Python-urllib User-Agent."""

    def test_requests_carry_an_explicit_user_agent(self):
        import render_packages as rp
        self.assertTrue(rp.USER_AGENT)
        self.assertNotIn("urllib", rp.USER_AGENT.lower())


class LookupFailureVisibilityTests(unittest.TestCase):
    """A silently empty version map hid a 403 for a whole render."""

    def test_a_failed_version_lookup_warns_rather_than_passing_silently(self):
        import io, contextlib
        import render_packages as rp
        rp.fetch_text = lambda url, timeout=0: (_ for _ in ()).throw(OSError("403"))
        err = io.StringIO()
        try:
            with contextlib.redirect_stderr(err):
                self.assertEqual(rp.cran_versions(["alpha"], attempts=1), {})
        finally:
            rp.fetch_text = rp._fetch_text
        self.assertIn("alpha", err.getvalue())


class ChecklistTests(unittest.TestCase):
    """The LinkedIn checklist is a fifth sink with its own shape.

    It is a working document, not a published one, so entries carry an
    unchecked task box and the repo path rather than a full URL.
    """

    def block(self):
        from render_packages import render_checklist_block
        return render_checklist_block(MANIFEST)

    def test_every_package_gets_an_unchecked_task_box(self):
        rows = [l for l in self.block().splitlines() if l.startswith("- [ ]")]
        self.assertEqual(len(rows), len(MANIFEST["packages"]))

    def test_entries_are_ordered_cran_then_standalone_then_family_then_book(self):
        names = re.findall(r"^- \[ \] \*\*(.+?)\*\*", self.block(), re.M)
        self.assertEqual(names, ["alpha", "sassy", "beta", "delta", "gamma", "The Book"])

    def test_the_repo_path_is_shown_without_the_scheme(self):
        self.assertIn("— github.com/ehrlinger/alpha", self.block())
        self.assertNotIn("https://github.com/ehrlinger/alpha", self.block())

    def test_a_renamed_repo_shows_its_real_path(self):
        self.assertIn("github.com/ehrlinger/beta-repo", self.block())

    def test_the_blurb_sits_in_a_quote_under_its_entry(self):
        self.assertIn("  > First — on CRAN.", self.block())

    def test_wip_carries_the_development_clause(self):
        self.assertIn("GitHub only; in active development.", self.block())


class SummaryLineTests(unittest.TestCase):
    def summary(self):
        from render_packages import render_summary_line
        return render_summary_line(MANIFEST)

    def test_cran_members_are_named_first(self):
        self.assertTrue(self.summary().startswith("Open-source software: alpha (CRAN)"))

    def test_the_family_size_is_spelled_out_and_derived(self):
        self.assertIn("the three-package hvtiR family", self.summary())

    def test_every_family_member_is_named(self):
        for name in ("beta", "gamma", "delta"):
            self.assertIn(name, self.summary())

    def test_standalone_software_is_labelled_by_its_role(self):
        self.assertIn("hazard", self.summary().replace("sassy", "hazard"))


class NamedRegionTests(unittest.TestCase):
    def test_splice_targets_a_named_region(self):
        doc = ("<!-- BEGIN:packages -->\nA\n<!-- END:packages -->\n"
               "<!-- BEGIN:summary -->\nB\n<!-- END:summary -->\n")
        out = splice(doc, "NEW", name="summary")
        self.assertIn("NEW", out)
        self.assertIn("\nA\n", out)          # the other region is untouched
        self.assertNotIn("\nB\n", out)

    def test_a_missing_named_region_names_it_in_the_error(self):
        with self.assertRaises(ValueError) as ctx:
            splice("<!-- BEGIN:packages -->\nA\n<!-- END:packages -->\n", "X", name="summary")
        self.assertIn("summary", str(ctx.exception))


if __name__ == "__main__":
    unittest.main()
