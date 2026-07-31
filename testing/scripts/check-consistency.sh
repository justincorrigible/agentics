#!/usr/bin/env bash
# Consistency checks for agentics. See testing/consistency-checks.md.
# Not a test suite: catches drift a read-through misses, nothing more.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

FAIL=0

section() { printf '\n== %s ==\n' "$1"; }

# 1. Agent-neutrality: every ~/.claude or "Claude Code" hit anywhere in template/ needs a human/agent
#    judgment call (a Claude/other-agent parenthetical, or a genuinely Claude-only reason). This
#    script surfaces candidates; it does not and cannot clear any of them. Not restricted to *.md:
#    a non-markdown file (e.g. .claude/settings.json) is exactly the kind of hit worth seeing too.
section "Agent-neutrality (review every line below)"
hits=$(grep -rn '~/\.claude\|Claude Code' template/ 2>/dev/null || true)
if [ -n "$hits" ]; then
  echo "$hits" | sed 's/^/  /'
else
  echo "  (no hits)"
fi

# 2. Orphaned convention files: every template/conventions/*.md has a dispatch line in AGENTS.md's
#    "When to read what" table specifically (not just a mention anywhere in the file), and a row in
#    README.md's file table.
section "Orphaned convention files"
ORPHAN_FAIL=0
dispatch_table="$(awk '/^## When to read what$/{f=1;next} f&&/^## /{exit} f' template/AGENTS.md)"
for f in template/conventions/*.md; do
  name="$(basename "$f")"
  in_agents=0; in_readme=0
  printf '%s\n' "$dispatch_table" | grep -q "$name" && in_agents=1
  grep -q "$name" template/README.md && in_readme=1
  if [ "$in_agents" -eq 0 ] || [ "$in_readme" -eq 0 ]; then
    echo "  FLAG: $name missing from: $( [ "$in_agents" -eq 0 ] && printf 'AGENTS.md dispatch table ' )$( [ "$in_readme" -eq 0 ] && printf 'README.md file table' )"
    ORPHAN_FAIL=1
    FAIL=1
  fi
done
[ "$ORPHAN_FAIL" -eq 0 ] && echo "  ok"

# 3. Personal info in the diff (staged + unstaged changes, plus untracked new files:
#    a session file is untracked from creation until first staged, and is exactly
#    where a name is most likely to leak, so it can't be skipped here).
section "Personal info in changed files"
CHANGED=$(git diff --name-only HEAD 2>/dev/null; git diff --cached --name-only 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)
CHANGED=$(printf '%s\n' "$CHANGED" | sort -u | grep -v '^$' || true)
WHOAMI="$(whoami 2>/dev/null || true)"
GIT_NAME="$(git config user.name 2>/dev/null || true)"
GIT_EMAIL="$(git config user.email 2>/dev/null || true)"
PERSONAL_FAIL=0
if [ -n "$CHANGED" ]; then
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    for needle in "$WHOAMI" "$GIT_NAME" "$GIT_EMAIL"; do
      [ -n "$needle" ] || continue
      if grep -qF -- "$needle" "$f" 2>/dev/null; then
        echo "  FLAG: $f contains '$needle'"
        PERSONAL_FAIL=1
        FAIL=1
      fi
    done
  done <<< "$CHANGED"
fi
[ "$PERSONAL_FAIL" -eq 0 ] && echo "  ok (checked $(printf '%s\n' "$CHANGED" | grep -c . || echo 0) changed file(s))"

# 4. Root vs template AGENTS.md. These two sections get different treatment on purpose, confirmed
#    by actually running this check against real content. "Interaction parameters" is meant to be
#    near-identical: general collaboration principles apply the same way to agentics-the-repo as
#    to any adopter. It gets a real content diff, since a bullet-count match can still hide real
#    wording drift. That happened once: "baked in" vs "baked into code", same count, different
#    text. The one known intentional difference there is template's CHANGELOG pointer: it says
#    "agentics' CHANGELOG.md" since it's copied elsewhere, while root's doesn't need the prefix
#    since it's the same repo. That difference is normalized away before comparing. "Critical
#    constraints" is meant to genuinely diverge. Root's is repo-specific: agentics has no library
#    code to isolate from the environment, but does need "we're the upstream source, keep this
#    public-safe." Template's is generic-adopter: it needs the environment-isolation rule a real
#    project's library code needs. A strict diff there would just be permanent, unfixable noise,
#    so it keeps the looser bullet-count heads-up: still worth reading both side by side on a
#    mismatch, not asserting they match.
section "Root/template AGENTS.md section drift"
extract_section() {
  # $1 = file, $2 = heading
  awk -v h="$2" '
    $0 ~ "^## "h"$" { found=1; next }
    found && /^## / { exit }
    found { print }
  ' "$1"
}
count_bullets() {
  printf '%s\n' "$1" | grep -c '^- '
}

root_txt="$(extract_section AGENTS.md "Interaction parameters")"
tmpl_txt="$(extract_section template/AGENTS.md "Interaction parameters")"
tmpl_txt="${tmpl_txt//agentics\' /}"
drift="$(diff <(printf '%s\n' "$root_txt") <(printf '%s\n' "$tmpl_txt") || true)"
if [ -n "$drift" ]; then
  echo "  FLAG: \"Interaction parameters\" content differs beyond the known agentics'-CHANGELOG-pointer difference:"
  printf '%s\n' "$drift" | sed 's/^/    /'
  FAIL=1
else
  echo "  ok: \"Interaction parameters\" content matches"
fi

root_n=$(count_bullets "$(extract_section AGENTS.md "Critical constraints")")
tmpl_n=$(count_bullets "$(extract_section template/AGENTS.md "Critical constraints")")
if [ "$root_n" != "$tmpl_n" ]; then
  echo "  FLAG: \"Critical constraints\" has $root_n bullet(s) in root AGENTS.md, $tmpl_n in template/AGENTS.md: read both side by side (content is expected to diverge here, repo-specific vs. generic-adopter; a count mismatch is still worth a look)"
  FAIL=1
else
  echo "  ok: \"Critical constraints\" ($root_n bullets each; content expected to diverge here, not compared)"
fi

# 5. Bare-relative-path safeguard: the disambiguating sentence in template/AGENTS.md's dispatch
#    table (conventions/*.md paths are live pointers, not local copies) is exactly what closed the
#    global-guideline-material-never-in-project incident. Silently losing that sentence in a future
#    edit would silently reopen it. This is a narrow regression guard, not a general bare-path
#    detector: it only catches this one sentence going missing, see docs/deterministic-by-design.md
#    for why a narrow mechanical check beats a fuzzy one here.
section "Dispatch-table disambiguation safeguard"
if printf '%s\n' "$dispatch_table" | grep -qi "live pointer"; then
  echo "  ok"
else
  echo "  FLAG: template/AGENTS.md's \"When to read what\" no longer states its conventions/*.md paths are live pointers, not local copies. This is the exact ambiguity behind CHANGELOG.md § global-guideline-material-never-in-project; restore the disambiguating note before shipping"
  FAIL=1
fi

# 6. Near-duplicate testing/regression-checklist.md entries (heads-up only, not a hard fail: this
#    is a heuristic, word-overlap check, not a semantic one). Two concurrent sessions once added
#    two separate entries for the same non-mutational loop-example incident. This catches that
#    shape without needing to know in advance what the next duplicate will be about.
section "Near-duplicate regression-checklist entries (heads-up only)"
if command -v python3 >/dev/null 2>&1; then
  python3 - "$REPO_ROOT/testing/regression-checklist.md" <<'PYEOF'
import re, sys

path = sys.argv[1]
text = open(path).read()
entries = re.findall(r'^### (\S+)\n(.*?)(?=\n### |\Z)', text, re.S | re.M)

STOP = {
    "this", "that", "with", "from", "have", "been", "were", "which", "their",
    "would", "could", "should", "about", "there", "these", "those", "being",
    "into", "than", "when", "then", "some", "each", "over", "only", "same",
    "does", "doesn", "aren", "cannot", "exist", "existing", "before", "after",
}

def words(s):
    ws = re.findall(r"[a-z]{4,}", s.lower())
    return {w for w in ws if w not in STOP}

flagged = False
for i in range(len(entries)):
    slug_a, body_a = entries[i]
    wa = words(body_a)
    for j in range(i + 1, len(entries)):
        slug_b, body_b = entries[j]
        wb = words(body_b)
        if not wa or not wb:
            continue
        overlap = len(wa & wb) / min(len(wa), len(wb))
        if overlap > 0.55:
            print(f"  FLAG: '{slug_a}' and '{slug_b}' share {overlap:.0%} of their distinctive words: read both, they may be the same incident")
            flagged = True

if not flagged:
    print("  ok")
PYEOF
else
  echo "  skipped (python3 not found)"
fi

echo
if [ "$FAIL" -eq 0 ]; then
  echo "All checks passed."
else
  echo "One or more checks flagged something above. Review before committing."
fi
exit "$FAIL"
