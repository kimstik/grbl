#!/usr/bin/env python3
"""check_contracts_numbering.py - CONTRACTS.md numbering/cross-reference guard.

Why this exists: parallel agents authoring grbl/platform/CONTRACTS.md at the
same time each read the current highest "## N." heading and pick "the next
number" - when more than one agent is doing this at once they all compute the
same N, and the integrator has to renumber by hand at merge time (this has
happened four times: section 20 collided three ways, section 21 twice).
Renumbering silently breaks anyone else's "#N"/"section N" cross-reference
into whatever moved into that slot. See CONTRACTS.md's top-of-file box for
the authoring rule this guard enforces: numbering is the integrator's job;
authors cite each other by a permanent slug anchor, not by number.

This script fails (exit 1) if grbl/platform/CONTRACTS.md has:
  1. Duplicate "## N." section numbers.
  2. Non-sequential "## N." section numbers (gaps, or out of ascending order).
  3. A section heading with no matching `<a id="slug"></a>` anchor directly
     above it, or two sections sharing the same slug.
  4. A markdown link of the form `[...](#slug)` (or `(CONTRACTS.md#slug)` /
     `(../CONTRACTS.md#slug)` from sibling docs elsewhere in the repo) whose
     slug has no matching anchor anywhere in CONTRACTS.md - a cross-reference
     whose target does not exist.

It does NOT try to verify that a link's visible section *number* (e.g. the
"20" in "[section 20](#slug)") still matches the number the slug currently
resolves to - that class of drift is exactly what slugs are supposed to make
harmless (the anchor is what's load-bearing; the number is a human hint that
may lag one renumbering behind and is caught by review, not this script).

Usage:
  check_contracts_numbering.py [--contracts PATH] [--repo-root PATH]
  check_contracts_numbering.py --selftest
"""

import argparse
import os
import re
import sys

HEADING_RE = re.compile(r'^## (\d+)\.\s')
ANCHOR_RE = re.compile(r'^<a id="([a-z0-9][a-z0-9-]*)"></a>\s*$')
# Links into this same file: [text](#slug)
LOCAL_LINK_RE = re.compile(r'\[[^\]]*\]\(#([a-z0-9][a-z0-9-]*)\)')
# Links from a sibling doc into CONTRACTS.md: [text](CONTRACTS.md#slug) or
# [text](../CONTRACTS.md#slug) (any number of ../ hops).
CROSS_LINK_RE = re.compile(
    r'\[[^\]]*\]\((?:\.\./)*CONTRACTS\.md#([a-z0-9][a-z0-9-]*)\)')


def parse_contracts(text):
    """Return (headings, anchors, errors).

    headings: list of (line_no, number:int)
    anchors:  list of (line_no, slug:str) that sit directly above a heading
    errors:   list of str, problems found while parsing structure (not links)
    """
    lines = text.split("\n")
    headings = []
    anchors = []
    errors = []
    pending_anchor = None  # (line_no, slug) seen on the immediately-prior line

    for i, line in enumerate(lines, start=1):
        a = ANCHOR_RE.match(line)
        if a:
            pending_anchor = (i, a.group(1))
            continue
        h = HEADING_RE.match(line)
        if h:
            num = int(h.group(1))
            headings.append((i, num))
            if pending_anchor is None:
                errors.append(
                    "line {}: '## {}.' heading has no <a id=\"...\"> anchor "
                    "on the line directly above it".format(i, num))
            else:
                anchors.append((pending_anchor[0], pending_anchor[1]))
            pending_anchor = None
            continue
        # Any other non-blank line clears a dangling anchor (anchor must be
        # immediately followed by its heading, not floating free).
        if line.strip() != "":
            pending_anchor = None

    return headings, anchors, errors


def check_numbering(headings):
    errors = []
    seen = {}
    for line_no, num in headings:
        if num in seen:
            errors.append(
                "duplicate section number {}: line {} and line {}".format(
                    num, seen[num], line_no))
        else:
            seen[num] = line_no
    ordered_nums = [n for _, n in headings]
    expected = list(range(ordered_nums[0], ordered_nums[0] + len(ordered_nums))) if ordered_nums else []
    if ordered_nums != expected:
        errors.append(
            "section numbers are not sequential in file order: found {}, "
            "expected {}".format(ordered_nums, expected))
    return errors


def check_anchors(anchors):
    errors = []
    seen = {}
    for line_no, slug in anchors:
        if slug in seen:
            errors.append(
                "duplicate slug '{}': line {} and line {}".format(
                    slug, seen[slug], line_no))
        else:
            seen[slug] = line_no
    return errors, set(seen)


def find_dangling_links(text, valid_slugs, source_label):
    errors = []
    for m in LOCAL_LINK_RE.finditer(text):
        slug = m.group(1)
        if slug not in valid_slugs:
            line_no = text[:m.start()].count("\n") + 1
            errors.append(
                "{}:{}: link to '#{}' has no matching anchor in CONTRACTS.md"
                .format(source_label, line_no, slug))
    return errors


# Directories that sit alongside/under the repo tree but are NOT the tracked
# source repo: excluded from the cross-file scan entirely. ".claude/" is a
# live scratch area (parallel agent worktrees under .claude/worktrees/<id>/,
# each a full independent checkout of grbl/platform/*.md) - a real incident
# had the checker fail on `.claude/worktrees/<id>/grbl/platform/PLAN.md`
# linking to a CONTRACTS.md#slug that only existed in that in-progress
# agent's own not-yet-merged branch, not in the CONTRACTS.md this run parsed.
# That agent's work was never broken; the checker was scanning content that
# isn't part of the repo being validated. See --selftest's
# "excluded scratch dir" case for the regression test.
EXCLUDED_SCAN_DIRS = {".git", ".claude"}


def find_cross_repo_dangling_links(repo_root, valid_slugs, contracts_path):
    """Scan every other *.md file in the repo for links into CONTRACTS.md
    and verify their slug exists. Best-effort: only checked when repo_root
    is given (skipped entirely in --selftest, which has no repo tree).
    Returns (errors, links_checked_count)."""
    errors = []
    checked = 0
    for dirpath, dirnames, filenames in os.walk(repo_root):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDED_SCAN_DIRS]
        for fn in filenames:
            if not fn.endswith(".md"):
                continue
            path = os.path.join(dirpath, fn)
            if os.path.abspath(path) == os.path.abspath(contracts_path):
                continue
            try:
                with open(path, encoding="utf-8") as f:
                    text = f.read()
            except OSError:
                continue
            for m in CROSS_LINK_RE.finditer(text):
                checked += 1
                slug = m.group(1)
                if slug not in valid_slugs:
                    line_no = text[:m.start()].count("\n") + 1
                    rel = os.path.relpath(path, repo_root)
                    errors.append(
                        "{}:{}: link to 'CONTRACTS.md#{}' has no matching "
                        "anchor in CONTRACTS.md".format(rel, line_no, slug))
    return errors, checked


def run_check(contracts_path, repo_root):
    with open(contracts_path, encoding="utf-8") as f:
        text = f.read()

    headings, anchors, structure_errors = parse_contracts(text)
    numbering_errors = check_numbering(headings)
    anchor_errors, valid_slugs = check_anchors(anchors)
    link_errors = find_dangling_links(
        text, valid_slugs, os.path.basename(contracts_path))

    cross_errors, cross_checked = [], 0
    if repo_root:
        cross_errors, cross_checked = find_cross_repo_dangling_links(
            repo_root, valid_slugs, contracts_path)

    all_errors = (structure_errors + numbering_errors + anchor_errors +
                  link_errors + cross_errors)

    if all_errors:
        print("check_contracts_numbering: FAIL - {} problem(s) in {}:"
              .format(len(all_errors), contracts_path))
        for e in all_errors:
            print("  - " + e)
        return 1

    print("check_contracts_numbering: OK - {} section(s), {} slug(s), "
          "{} cross-file link(s) checked, all consistent."
          .format(len(headings), len(valid_slugs), cross_checked))
    return 0


# --- selftest ----------------------------------------------------------------
# Style matches ci/warn_ratchet.py / tools/assert_no_double.sh --selftest:
# build synthetic CONTRACTS.md-shaped text for each failure class (the exact
# shape of the four-times-bitten bug: duplicate numbers) plus one clean
# control case, and drive the same run_check() entry point a real invocation
# uses so the selftest can't silently drift from what --check actually does.

GOOD_DOC = """# Fixture

<a id="alpha"></a>
## 0. Alpha

See [beta](#beta) for details.

<a id="beta"></a>
## 1. Beta

Back-reference to [alpha](#alpha).

<a id="gamma"></a>
## 2. Gamma
"""

DUPLICATE_NUMBER_DOC = """# Fixture

<a id="alpha"></a>
## 0. Alpha

<a id="beta"></a>
## 1. Beta

<a id="gamma"></a>
## 1. Gamma (collided with Beta - the exact §20-three-ways bug)
"""

NONSEQUENTIAL_DOC = """# Fixture

<a id="alpha"></a>
## 0. Alpha

<a id="beta"></a>
## 1. Beta

<a id="gamma"></a>
## 3. Gamma (skipped 2)
"""

DANGLING_LINK_DOC = """# Fixture

<a id="alpha"></a>
## 0. Alpha

See [gamma](#gamma) - gamma was never authored / renamed away.

<a id="beta"></a>
## 1. Beta
"""

MISSING_ANCHOR_DOC = """# Fixture

<a id="alpha"></a>
## 0. Alpha

## 1. Beta (forgot the anchor line above this heading)
"""

DUPLICATE_SLUG_DOC = """# Fixture

<a id="alpha"></a>
## 0. Alpha

<a id="alpha"></a>
## 1. Beta (copy-pasted the wrong anchor)
"""


def _write_and_check(tmpdir, name, content):
    path = os.path.join(tmpdir, name)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    return run_check(path, repo_root=None)


def selftest():
    import tempfile

    checks = 0

    def check(cond, what):
        nonlocal checks
        checks += 1
        if not cond:
            print("selftest: FAIL - " + what)
            sys.exit(1)

    with tempfile.TemporaryDirectory() as d:
        check(_write_and_check(d, "good.md", GOOD_DOC) == 0,
              "clean fixture (unique sequential numbers, matched anchors, "
              "valid links) must PASS")

        check(_write_and_check(d, "dup.md", DUPLICATE_NUMBER_DOC) == 1,
              "duplicate section number must FAIL "
              "(this is the exact §20/§21 collision bug)")

        check(_write_and_check(d, "gap.md", NONSEQUENTIAL_DOC) == 1,
              "non-sequential section numbers must FAIL")

        check(_write_and_check(d, "dangling.md", DANGLING_LINK_DOC) == 1,
              "link to a nonexistent slug must FAIL")

        check(_write_and_check(d, "noanchor.md", MISSING_ANCHOR_DOC) == 1,
              "heading with no anchor above it must FAIL")

        check(_write_and_check(d, "dupslug.md", DUPLICATE_SLUG_DOC) == 1,
              "two sections sharing one slug must FAIL")

        # Regression test for the live incident: check_contracts_numbering
        # was scanning .claude/worktrees/<agent-id>/ - a parallel agent's own
        # in-progress, not-yet-merged checkout - and failing on a dangling
        # CONTRACTS.md#slug link that only that agent's branch would ever
        # resolve. A file inside an excluded scratch dir with a deliberately
        # dead link must NOT fail the check; the same dead link in a normal
        # tracked-looking directory must still be caught.
        with tempfile.TemporaryDirectory() as repo:
            contracts_path = os.path.join(repo, "CONTRACTS.md")
            with open(contracts_path, "w", encoding="utf-8") as f:
                f.write(GOOD_DOC)

            excluded_dir = os.path.join(
                repo, ".claude", "worktrees", "agent-a95cc0325b1e280b4",
                "grbl", "platform")
            os.makedirs(excluded_dir)
            with open(os.path.join(excluded_dir, "PLAN.md"), "w",
                      encoding="utf-8") as f:
                f.write(
                    "See CONTRACTS.md\n"
                    "[link](CONTRACTS.md#cross-arch-dedup-byte-invariance) "
                    "for details.\n")

            check(run_check(contracts_path, repo_root=repo) == 0,
                  "a dead CONTRACTS.md#slug link inside an excluded scratch "
                  "dir (.claude/worktrees/...) must NOT fail the check")

            tracked_dir = os.path.join(repo, "doc")
            os.makedirs(tracked_dir)
            with open(os.path.join(tracked_dir, "REAL.md"), "w",
                      encoding="utf-8") as f:
                f.write(
                    "See CONTRACTS.md\n"
                    "[link](CONTRACTS.md#this-slug-was-never-authored) "
                    "for details.\n")

            check(run_check(contracts_path, repo_root=repo) == 1,
                  "the SAME class of dead link in a real tracked directory "
                  "must still FAIL - excluding .claude/ must not blind the "
                  "checker to genuine dangling links")

        # Negative test requested by the task: prove the specific injected
        # duplicate (two sections both claiming to be "20") is caught, with
        # the actual FAIL output visible, not just an exit code.
        bad_path = os.path.join(d, "injected_dup20.md")
        injected = GOOD_DOC.replace(
            '<a id="gamma"></a>\n## 2. Gamma',
            '<a id="gamma"></a>\n## 1. Gamma (injected duplicate of Beta)')
        with open(bad_path, "w", encoding="utf-8") as f:
            f.write(injected)
        rc = run_check(bad_path, repo_root=None)
        check(rc == 1, "injected duplicate-of-1 fixture must FAIL")

    print("selftest: PASS ({} checks)".format(checks))
    return 0


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    default_contracts = os.path.normpath(os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        "..", "grbl", "platform", "CONTRACTS.md"))
    default_root = os.path.normpath(os.path.join(
        os.path.dirname(os.path.abspath(__file__)), ".."))
    p.add_argument("--contracts", default=default_contracts,
                   help="path to CONTRACTS.md (default: repo's "
                        "grbl/platform/CONTRACTS.md)")
    p.add_argument("--repo-root", default=default_root,
                   help="repo root to scan for cross-file "
                        "(CONTRACTS.md#slug) links (default: autodetected)")
    p.add_argument("--no-cross-repo", action="store_true",
                   help="skip scanning the rest of the repo for dangling "
                        "cross-file links (CONTRACTS.md-only check)")
    p.add_argument("--selftest", action="store_true", help="run unit checks")
    a = p.parse_args(argv)

    if a.selftest:
        return selftest()

    repo_root = None if a.no_cross_repo else a.repo_root
    return run_check(a.contracts, repo_root)


if __name__ == "__main__":
    sys.exit(main())
