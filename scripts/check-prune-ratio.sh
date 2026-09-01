#!/usr/bin/env bash
# Did a pruning pass happen? Not: is the corpus bloated.
#
# The release procedure requires a simplification pass. That requirement is prose, so it is
# subject to the same "read it and did not run it" failure the conventions keep recording, and
# it had never once been executed. This measures the fact rather than the judgement: whether any
# pre-existing file got smaller. What to cut is irreducibly a judgement; whether anything was
# cut is arithmetic.
#
# Measured in characters, not lines. These files write one paragraph per line, so deleting a
# paragraph and adding one both register as a single line, and a line count hides the very thing
# being measured. Found by running the first version against the batch it was built for: a merge
# that removed two sections and two duplicate schema blocks moved the line count by nine.
#
# The threshold is a budget derived from history rather than invented: releases 0.15.0 through
# 0.17.0 added 57k, 39k and 28k characters, and 0.18.0 removed 15k. 60k passes every release this
# repository has ever cut. Growing past it is allowed and has to be a decision: raise the number
# in a commit someone can see, rather than discovering later that nothing ever held.
#
# An earlier version exempted a batch when any single file shrank. That passed a 133k-character
# batch on one file being three characters smaller, which is the control-whose-failure-looks-like-
# success shape occurring inside the control built to prevent it.
#
# New files count toward the total. An earlier version reported them beside the number instead of
# in it, so moving a section out of an existing file into a new one scored as a pure deletion:
# the source shrank and the destination was invisible. The batch that introduced this script did
# exactly that three times and collected 18k characters of credit for content that never left.
# A genuine split now nets to zero, which is what a split actually is, and genuinely new content
# counts as the growth it is.
#
# Reports always. Exits non-zero on growth past the budget, so it is quiet during ordinary work
# and bites at release. `.githooks/commit-msg` runs it on a release subject, which
# is the layer that does not depend on anyone choosing to run it.
#
# It also splits the total by tier, because a character in a file every session reads costs more
# than one in a file read on a trigger, and the budget alone cannot see the difference. The
# always-read set is derived from the "Starting a session" row of `template/AGENTS.md` rather than
# listed here, so the dispatch table stays the single source of what that tier contains and this
# script keeps implementing a rule instead of becoming one. No weighting is applied: the budget's
# 60000 came from release history, and any multiplier for always-read characters would be invented
# rather than derived, so the split is reported and left for a person to weigh.
#
# It measures the working tree, not HEAD. An earlier version compared committed state only, so
# between releases, when this repository's own rules leave a batch uncommitted, it reported +0 and
# saw nothing. That is the advisory reading dead in exactly the window where it could still change
# a decision: while content is being added and could still be declined. At the release commit the
# two readings coincide, which is why the blindness went unnoticed.
#
# Usage: bash scripts/check-prune-ratio.sh [base-ref]   (default: origin/main)

set -uo pipefail
BASE="${1:-origin/main}"
GROWTH_THRESHOLD=60000

if ! git rev-parse --verify "$BASE" >/dev/null 2>&1; then
  echo "  skipped: no '$BASE' to compare against"
  exit 0
fi

python3 - "$BASE" "$GROWTH_THRESHOLD" <<'PY_EOF'
import re, subprocess, sys

base, threshold = sys.argv[1], int(sys.argv[2])

def run(*args):
    return subprocess.run(args, capture_output=True, text=True).stdout

changed = run("git", "diff", "--name-only", base, "--", "template/", "docs/").split()
existing = set(run("git", "ls-tree", "-r", "--name-only", base).split())

grew, shrunk, new = [], [], []
for path in changed:
    try:
        now = len(open(path).read())
    except OSError:
        now = 0
    if path in existing:
        was = len(run("git", "show", f"{base}:{path}"))
        (shrunk if now < was else grew).append((path, now - was))
    else:
        new.append((path, now))

grew += new
net = sum(delta for _, delta in grew + shrunk)
print(f"  {net:+d} characters net across {len(grew) + len(shrunk)} file(s) "
      f"({len(new)} new, {sum(d for _, d in new):+d})")

always = {"template/AGENTS.md", "template/CLAUDE.md"}
for line in run("git", "show", "HEAD:template/AGENTS.md").splitlines():
    if line.startswith("- Starting a session"):
        always |= {f"template/{m}" for m in re.findall(r"`(conventions/[\w.-]+\.md)`", line)}
hot = sum(d for path, d in grew + shrunk if path in always)
print(f"  of that, {hot:+d} in the always-read tier "
      f"({len(always)} file(s) every session loads, unweighted)")

if net > threshold:
    print(f"  FAIL: net growth of {net} characters across {len(grew)} file(s) exceeds the budget.")
    print(f"        Budget is {threshold}, derived from every prior release of this repository.")
    print("        Cut what is duplicated, superseded, or no longer earning its place, or raise")
    print("        the budget deliberately. Largest contributors:")
    for path, delta in sorted(grew, key=lambda x: -x[1])[:3]:
        print(f"        {delta:+8d}  {path}")
    sys.exit(1)

print(f"  ok: net growth is within the {threshold}-character budget")
if shrunk:
    print(f"       {len(shrunk)} file(s) net smaller, largest {min(d for _, d in shrunk):+d}")
PY_EOF
