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

# 3. Personal info in the diff (staged + unstaged changes only).
section "Personal info in changed files"
CHANGED=$(git diff --name-only HEAD 2>/dev/null; git diff --cached --name-only 2>/dev/null)
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

# 4. Root vs template AGENTS.md: rough bullet-count heads-up for sections known to drift.
section "Root/template AGENTS.md section drift (heads-up only)"
count_section() {
  # $1 = file, $2 = heading
  awk -v h="$2" '
    $0 ~ "^## "h"$" { found=1; next }
    found && /^## / { exit }
    found && /^- / { n++ }
    END { print n+0 }
  ' "$1"
}
for heading in "Interaction parameters" "Critical constraints"; do
  root_n=$(count_section AGENTS.md "$heading")
  tmpl_n=$(count_section template/AGENTS.md "$heading")
  if [ "$root_n" != "$tmpl_n" ]; then
    echo "  FLAG: \"$heading\" has $root_n bullet(s) in root AGENTS.md, $tmpl_n in template/AGENTS.md: read both side by side"
    FAIL=1
  else
    echo "  ok: \"$heading\" ($root_n bullets each)"
  fi
done

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

echo
if [ "$FAIL" -eq 0 ]; then
  echo "All checks passed."
else
  echo "One or more checks flagged something above. Review before committing."
fi
exit "$FAIL"
