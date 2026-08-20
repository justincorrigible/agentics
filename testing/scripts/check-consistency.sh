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

# .dev/ travels to other users too and had never been scanned here: an assumption stack three
# deep (Claude Code specifically, a Unix-style ~ home, and GNU-vs-BSD tooling in scripts).
# Environment-specific findings are legitimate in the atlas; asserting them without saying which
# environment is the defect. Listed by file rather than by line, since the judgment is per file.
devhits=$(grep -rn '~/\.claude\|Claude Code\|ListAgents\|SendMessage' .dev/ 2>/dev/null || true)
if [ -n "$devhits" ]; then
  echo
  echo "  -- .dev/ (review: is the environment declared, or asserted as universal?) --"
  echo "$devhits" | awk -F: '{c[$1]++} END {for (f in c) printf "  %-54s %s\n", f, c[f]}' | sort
  echo "  An atlas file recording tool-specific findings declares its scope once at the top."
  echo "  Per-line hedging of an empirical observation is dishonest; a scope header is not."
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
# Second known-and-expected difference: convention paths are bare in the template (they resolve
# against agentics' template/ directory from an adopting project) and prefixed in root (this repo
# holds the files under template/). Normalize so only real content drift is reported.
root_txt="${root_txt//template\/conventions\//conventions/}"
drift="$(diff <(printf '%s\n' "$root_txt") <(printf '%s\n' "$tmpl_txt") || true)"
if [ -n "$drift" ]; then
  echo "  FLAG: \"Interaction parameters\" content differs beyond the known path-prefix and agentics'-CHANGELOG-pointer differences:"
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

# 6. No AI-tool attribution in commit messages: session-discipline.md explicitly overrides an
#    agent's own default commit template for this. Checks commits not yet pushed to the configured
#    upstream (or just HEAD if no upstream is tracked), since a pushed commit is history to fix
#    separately, not something this pre-commit-style check can catch usefully.
section "No AI-tool attribution in commit messages"
upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
if [ -n "$upstream" ]; then
  attr_hits=$(git log --format='%H %s%n%b' "$upstream"..HEAD 2>/dev/null | grep -niE 'co-authored-by|generated (with|by) claude|written by claude' || true)
else
  attr_hits=$(git log --format='%H %s%n%b' -1 2>/dev/null | grep -niE 'co-authored-by|generated (with|by) claude|written by claude' || true)
fi
if [ -n "$attr_hits" ]; then
  echo "  FLAG: commit message(s) contain AI-tool attribution, remove before pushing:"
  echo "$attr_hits" | sed 's/^/    /'
  FAIL=1
else
  echo "  ok"
fi

# 7. Near-duplicate testing/regression-checklist.md entries (heads-up only, not a hard fail: this
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
echo "== Credential hook actually fires (payload contract, not just patterns) =="
if command -v python3 >/dev/null 2>&1; then
  hook_cmd=$(python3 -c "
import json,sys
try:
    d=json.load(open('template/.claude/settings.json'))
    print(d['hooks']['PreToolUse'][0]['hooks'][0]['command'])
except Exception as e:
    sys.exit(1)
" 2>/dev/null)
  if [ -z "$hook_cmd" ]; then
    echo "  FLAG: could not extract the PreToolUse hook command from template/.claude/settings.json"
    FAIL=1
  else
    decide() { printf '%s' "$1" | eval "$hook_cmd" 2>/dev/null | python3 -c "
import json,sys
try:
    print(json.load(sys.stdin)['hookSpecificOutput']['permissionDecision'])
except Exception:
    print('ERROR')
" 2>/dev/null; }
    hook_bad=0
    # Each payload uses the key shape a real tool sends, so a key-name regression is caught.
    for probe in \
      'deny:{"tool_input":{"file_path":"/h/p/.env"}}' \
      'deny:{"tool_input":{"file_path":"/h/.ssh/id_rsa"}}' \
      'deny:{"tool_input":{"notebook_path":"/h/p/.env"}}' \
      'deny:{"tool_input":{"command":"cat /h/p/.env"}}' \
      'allow:{"tool_input":{"file_path":"/h/p/README.md"}}' \
      'allow:{"tool_input":{}}'; do
      want=${probe%%:*}
      payload=${probe#*:}
      got=$(decide "$payload")
      if [ "$got" != "$want" ]; then
        echo "  FLAG: expected $want, got $got for $payload"
        hook_bad=1
      fi
    done
    if [ "$hook_bad" -eq 0 ]; then
      echo "  ok"
    else
      echo "  The hook does not behave as documented. A hook that returns allow is indistinguishable"
      echo "  from no hook at all: see CHANGELOG.md § credential-hook-never-fired."
      FAIL=1
    fi
  fi
else
  echo "  skipped (python3 not found)"
fi

echo
echo "== Schema field drift between a convention and its bootstrap copy =="
if command -v python3 >/dev/null 2>&1; then
  python3 - <<'PYEOF'
import re, sys, os

# Files that restate the same schema block. A field added to one and not the other has
# shipped three times; see CHANGELOG.md § schema-propagation-missed-a-third-time.
PAIRS = [("template/conventions/agent-index.md", "template/global-context/agent-index.md")]

def fields(path):
    """Field names from every fenced block that looks like a `- key:` record."""
    try:
        text = open(path).read()
    except OSError:
        return None
    out = []
    for block in re.findall(r"```\n(.*?)```", text, re.S):
        names = re.findall(r"^\s*([a-z_]+):", block, re.M)
        if names:
            out.append(names)
    return out

bad = False
for canonical, copy in PAIRS:
    a, b = fields(canonical), fields(copy)
    if a is None or b is None:
        print(f"  FLAG: could not read {canonical} or {copy}")
        bad = True
        continue
    for i, block_a in enumerate(a):
        if i >= len(b):
            break
        missing = [f for f in block_a if f not in b[i]]
        extra = [f for f in b[i] if f not in block_a]
        if missing:
            print(f"  FLAG: {copy} block {i+1} is missing {missing} declared in {canonical}")
            bad = True
        if extra:
            print(f"  FLAG: {copy} block {i+1} declares {extra} absent from {canonical}")
            bad = True
if not bad:
    print("  ok")
sys.exit(1 if bad else 0)
PYEOF
  if [ $? -ne 0 ]; then FAIL=1; fi
else
  echo "  skipped (python3 not found)"
fi

echo
echo "== Naming the person: generic label in template files (review, not a failure) =="
# Legitimate where the person is described to a third party, wrong where a shared instruction
# file addresses or names them, and no check can separate those. Lists rather than fails. The
# half that actually fails is conversational and ungreppable. See writing-style.md.
if grep -rn "the user" template/ >/dev/null 2>&1; then
  grep -rn "the user" template/ | cut -c1-150 | sed "s/^/  /"
  echo "  (\"the developer\" in a shared instruction file; a name or \"you\" in a live reply)"
else
  echo "  ok"
fi

echo "== Session filenames: zeroed time components (review, not a failure) =="
# A partly padded timestamp survives a glance and a T000000 check. Seconds land on 00 about once
# in sixty naturally, so this is a note rather than a failure. See session-discipline.md.
# All-zeros is a declared backfill placeholder that session-discipline.md tells readers not to
# "fix", and the never-rename rule forbids the only remedy a report would suggest, so it is
# excluded. Partial padding is the discriminator: a real-looking HHMM with zeroed seconds is the
# signature of reaching for a plausible value rather than a clock.
padded=$(ls .dev/sessions/ 2>/dev/null | grep -E 'T[0-9]{4}00\.md$' | grep -v 'T000000\.md$' || true)
if [ -n "$padded" ]; then
  echo "$padded" | sed 's/^/  zeroed seconds: /'
  echo "  (legitimate about 1 in 60 times; confirm it was read from a clock)"
else
  echo "  ok: no zeroed seconds in .dev/sessions/"
fi

echo "== Release gate: did a pruning pass run? (advisory here, enforced at the release commit) =="
# Shown rather than enforced, because this runs constantly during a session and a check that
# fails the ordinary loop trains readers to skip it. Compulsion belongs at the commit, where a
# hook fires without anyone choosing to run it. See CONTRIBUTING.md § Publishing a release.
if bash scripts/check-prune-ratio.sh 2>/dev/null; then :; else
  echo "  (advisory only: this run is not failed by the above)"
fi

echo "== Prose density in human-facing files (review, not a failure) =="
# Length is not the defect. A long sentence is where a doubled claim usually hides, so this is
# a proxy for the re-read test in writing-style.md § Density, which cannot be checked directly.
if command -v python3 >/dev/null 2>&1; then
  python3 - <<'PYDENSITY'
import re, glob
worst = []
tot = 0
# Human-facing files only: density costs a person and saves an agent, so unpacking a convention
# would inflate a file every adopter loads every session. See writing-style.md § Density.
# Not a directory test: .dev/ spans both sides. roadmap and tech-debt are read by a person to
# decide something, so the human rule applies; session logs are condensed and excluded. The
# document that prompted this rule lived in .dev/docs/, which an earlier path list exempted.
files = (['README.md', 'CONTRIBUTING.md', 'template/README.md', 'template/DEVELOPMENT.md',
          '.dev/roadmap.md', '.dev/tech-debt.md']
         + sorted(glob.glob('docs/*.md'))
         + sorted(glob.glob('.dev/docs/**/*.md', recursive=True)))
for f in files:
    t = re.sub(r'```.*?```', '', open(f).read(), flags=re.S)
    for line in t.split('\n'):
        line = line.strip()
        if not line or line[:1] in '#-*|>' or re.match(r'^\d+\.', line):
            continue
        # Bold emphasis closing after a full stop hides the boundary from the splitter, so
        # '...resolvable.** Agentics...' measured as one sentence. Same false-merge class as a
        # bullet list with no terminal punctuation, found by the maximum rather than by reading.
        for sent in re.split(r'(?<=[.!?:])\s+', line.replace('**', '')):
            sent = ' '.join(sent.split())
            n = len(sent.split())
            if n < 4:
                continue
            tot += 1
            if n > 30:
                worst.append((n, f, sent))
mx = max((n for n, _, _ in worst), default=0)
# The extreme is where a splitter artifact announces itself; the count never shows it, and
# the summary line is the part that gets quoted elsewhere. See deterministic-by-design.md.
print(f"  {len(worst)} of {tot} prose sentences over 30 words, worst {mx}w")
for n, f, sent in sorted(worst, reverse=True)[:5]:
    print(f"    {n:>3}w  {f}")
    print(f"         {sent[:96]}...")
if len(worst) > 5:
    print(f"    ... and {len(worst)-5} more")
PYDENSITY
else
  echo "  skipped (python3 not found)"
fi

echo "== A script with a shebang is executable =="
# A shebang promises direct invocation; without the bit, `./script` gives permission denied.
# Shipped that way once because every local test used `bash script`, the form already written down.
notexec=0
for f in scripts/*.sh testing/scripts/*.sh; do
  [ -f "$f" ] || continue
  if head -1 "$f" | grep -q '^#!' && [ ! -x "$f" ]; then
    echo "  FLAG: $f has a shebang but is not executable (chmod +x)"
    notexec=1
  fi
done
if [ "$notexec" -eq 0 ]; then echo "  ok"; else FAIL=1; fi

echo "== Every global-context file carries a version tag =="
# A deployed copy in a global context is outside upstream-check.md's reach, so the tag is the
# only way it can announce its own staleness. See CHANGELOG.md § deployed-global-context-cannot-know-it-is-stale.
missing=0
for f in template/global-context/*.md; do
  if ! head -1 "$f" | grep -q 'agentics-template-version'; then
    echo "  FLAG: $f has no version tag on line 1"
    missing=1
  fi
done
if [ "$missing" -eq 0 ]; then echo "  ok"; else FAIL=1; fi

echo "== Dash rule: all four banned forms, not just the two the prose check greps =="
if command -v python3 >/dev/null 2>&1; then
  python3 - <<'PYEOF'
import re, sys, glob

# writing-style.md bans four things. The check it mandates greps for two of them, so the
# other two accumulated unnoticed in shipped files; see CHANGELOG.md § dash-check-narrower-than-rule.
# Files that define the rule must contain the characters to ban them.
ALLOW_LITERAL = {"template/conventions/writing-style.md", "template/conventions/entry-formats.md"}

def strip_noncontent(line):
    line = re.sub(r"`[^`]*`", "", line)        # inline code
    line = re.sub(r"<!--.*?-->", "", line)     # html comments
    return line

bad = []
for path in sorted(set(glob.glob("template/**/*.md", recursive=True) + glob.glob("docs/*.md")
                       + ["README.md", "CONTRIBUTING.md", "AGENTS.md", "CLAUDE.md"])):
    try:
        raw = open(path).read()
    except OSError:
        continue
    fenced = False
    for n, line in enumerate(raw.split("\n"), 1):
        if line.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if fenced or line.lstrip().startswith("|--") or set(line.strip()) <= {"|", "-", ":", " "}:
            continue
        text = strip_noncontent(line)
        if path not in ALLOW_LITERAL and re.search(r"[\u2014\u2013]", text):
            bad.append((path, n, "em or en dash"))
        if re.search(r"[a-zA-Z,)\"] -- [a-zA-Z(]", text):
            bad.append((path, n, "double hyphen as a dash"))
        if re.search(r"[a-zA-Z,)\"] - [a-zA-Z(]", text):
            bad.append((path, n, "space-hyphen-space connector"))

for path, n, what in bad:
    print(f"  FLAG: {path}:{n}: {what}")
if not bad:
    print("  ok")
sys.exit(1 if bad else 0)
PYEOF
  if [ $? -ne 0 ]; then FAIL=1; fi
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
