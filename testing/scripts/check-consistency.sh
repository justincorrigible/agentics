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
  if [ $? -ne 0 ]; then echo "  FLAG: this check crashed and did not run. A review-tier check reports candidates without failing, so a crash looked identical to a clean pass until this line existed."; FAIL=1; fi
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
    # No output is the correct answer for a clean path: it leaves the normal permission flow in
    # charge. It is distinguished from malformed output, which is still an error.
    decide() { out=$(printf '%s' "$1" | eval "$hook_cmd" 2>/dev/null)
      if [ -z "$out" ]; then echo none; return; fi
      printf '%s' "$out" | python3 -c "
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
      'deny:{"tool_input":{"file_path":"/h/p/.env.local"}}' \
      'deny:{"tool_input":{"file_path":"/h/p/.env.example.bak"}}' \
      'none:{"tool_input":{"file_path":"/h/p/.env.schema"}}' \
      'none:{"tool_input":{"file_path":"/h/p/.env.example"}}' \
      'none:{"tool_input":{"file_path":"/h/p/README.md"}}' \
      'none:{"tool_input":{"command":"ls -la"}}' \
      'none:{"tool_input":{}}'; do
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
      echo "  The hook does not behave as documented. The denies prove it is live; a clean path must"
      echo "  produce no decision. An allow skips the permission prompt, so a guard that allows what it"
      echo "  does not block switches off the default prompts for every tool it does not cover."
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

echo "== Pattern fixture: every pattern decides its own cases correctly =="
# Runs before the patterns are used, because a pattern that cannot discriminate makes every
# result below it meaningless. CATCH and PASS are equally load-bearing: the attribution pattern
# shipped with an ignore-case flag that matched all seven lowercase PASS lines while finding
# nothing real, and it would have passed any make-it-fail-once test. See
# docs/deterministic-by-design.md § A check must be able to print failure.
python3 - <<'PYEOF'
import re, sys
sys.dont_write_bytecode = True   # a .pyc embeds an absolute path with the username
sys.path.insert(0, "testing/scripts")
from patterns import PATTERNS as _P          # single source; see patterns.py for why
PATTERNS = {k: [c for _, c in v] for k, v in _P.items()}
bad = 0
_texts = {}
for raw in open("testing/fixtures/prose-patterns.txt"):
    line = raw.rstrip("\n")
    if not line.strip() or line.lstrip().startswith("#"): continue
    pid, verdict, text = line.split(None, 2)
    _texts.setdefault(pid, []).append(text)
    if pid not in PATTERNS:
        print(f"  FLAG: fixture names unknown pattern {pid!r}"); bad += 1; continue
    hit = any(p.search(text) for p in PATTERNS[pid])
    # KEEP means "must be raised AND is correct as written": same expectation as CATCH for the
    # pattern, different meaning for the reader who clears it.
    if hit != (verdict in ("CATCH", "KEEP", "KNOWN")):
        want = "match" if verdict in ("CATCH", "KEEP", "KNOWN") else "not match"
        print(f"  FLAG: {pid} should {want}: {text[:88]}"); bad += 1
# Coverage, which is a different failure from drift and is not fixed by single-sourcing: a
# pattern with no case at all has nothing to go stale, and a green run asserts it is sound.
for _fam, _entries in _P.items():
    for _label, _pat in _entries:
        if not any(_pat.search(t) for t in _texts.get(_fam, [])):
            print(f"  FLAG: {_fam}/{_label} has no fixture case exercising it"); bad += 1
        elif not any(_pat.search(t) and sum(1 for _, q in _entries if q.search(t)) == 1
                     for t in _texts.get(_fam, [])):
            # Coverage by a case written for a neighbouring pattern is not coverage: the pattern
            # could be deleted outright and every check would still pass. Verified by deleting one.
            print(f"  FLAG: {_fam}/{_label} has no case exercising only it"); bad += 1
print("  ok: every fixture case decided correctly, every pattern covered" if not bad else
      f"  {bad} case(s) wrong; the patterns below cannot be trusted until these pass")
sys.exit(1 if bad else 0)
PYEOF
if [ $? -ne 0 ]; then FAIL=1; fi

echo "== Naming the agent: attribution that resolves to a peer =="
# Sibling of the check above and, unlike it, a real failure, because this half is cleanly
# greppable. The discriminator is whether the phrase resolves to someone a reader could go and
# ask: a proper noun does, a bare article does not. So "Reported by the Arranger session" fails
# and "Reported by a session that had read this file that morning" passes, the second being
# evidence about the conditions rather than credit. A handle rotates and a label is conferred
# per session, so the named form decays to nothing while inviting a reader to go and ask an
# agent that no longer exists. See AGENTS.md § Critical constraints.
# Quoted spans are masked: this rule's own statement quotes the form it forbids.
python3 - <<'PYEOF'
import re, pathlib, sys
# Case-sensitive by construction: capitalization IS the discriminator here, so an
# ignore-case flag would defeat the check while still printing plausible output. Only the
# verb is case-folded, via an inline group, never the proper noun.
sys.dont_write_bytecode = True   # a .pyc embeds an absolute path with the username
sys.path.insert(0, "testing/scripts")
from patterns import compiled
PATS = compiled("attribution")
hits = 0
for p in sorted(pathlib.Path("template").rglob("*.md")) + sorted(pathlib.Path("docs").rglob("*.md")):
    raw = p.read_text()
    # INVARIANT: same-width replacement, or the line numbers below drift.
    masked = re.sub(r'"[^"\n]{0,300}"', lambda m: " " * len(m.group(0)), raw)
    masked = re.sub(r"`[^`\n]*`", lambda m: " " * len(m.group(0)), masked)
    for pat in PATS:
        for m in pat.finditer(masked):
            print(f"  {p}:{raw[:m.start()].count(chr(10)) + 1}  {m.group(0)}")
            hits += 1
print("  ok: no attribution resolving to a named peer" if not hits else
      f"  {hits} instance(s); name what was established and how to check it, not who agreed")
sys.exit(1 if hits else 0)
PYEOF
if [ $? -ne 0 ]; then FAIL=1; fi

echo "== Derivational register (candidates, not failures) =="
# The idiom of mathematics and formal philosophy, which reads as ordinary English and inverts:
# "falls out of" gives a reader without it the opposite sense, and "turns on" reads as activates,
# which in a document about access enforcement is worse than meaningless. A design document is
# one step from writing about derivations, which is what makes this the easiest register to slip
# into and the hardest to see from inside.
# REVIEW TIER BY MEASUREMENT, not by caution. Of the instances found here, roughly a third were
# the register and the rest were ordinary English sharing a word: "worked around trivially" means
# easily, "cannot be reduced to one" means shortened. The discriminator is whether the phrase
# replaces a reason or summarizes a stated one, and that is not greppable: a trailing-clause test
# caught two of ten, because a reason given before the phrase is just as good and looks nothing
# alike. So this raises candidates and a reader decides them. See writing-style.md
# § Borrowing a register from a domain that is not the topic, which also covers the second
# form, legal and medical idiom in a design document, that no pattern here attempts because
# its words are ordinary English elsewhere and often the correct word in the same file.
python3 - <<'PYEOF'
import re, pathlib, sys
sys.dont_write_bytecode = True   # a .pyc embeds an absolute path with the username
sys.path.insert(0, "testing/scripts")
from patterns import PATTERNS
PATS = dict((lbl, pat) for lbl, pat in PATTERNS["register"])
files = sorted(pathlib.Path("template").rglob("*.md")) + sorted(pathlib.Path("docs").rglob("*.md"))
raised = 0
for p in files:
    raw = p.read_text()
    m = re.sub(r"`[^`\n]*`", lambda x: " " * len(x.group(0)), raw)
    m = re.sub(r'"[^"\n]{0,300}"', lambda x: " " * len(x.group(0)), m)
    for name, pat in PATS.items():
        for h in pat.finditer(m):
            print(f"  {p}:{raw[:h.start()].count(chr(10)) + 1}  [{name}]")
            raised += 1
# Attestation: a candidate-raising check cannot honestly report pass or fail, so it reports how
# many were raised and leaves the judgement visible as a judgement.
print(f"  {raised} candidate(s) raised; each needs a reader, and a cleared one is not a defect"
      if raised else "  none raised")
PYEOF
if [ $? -ne 0 ]; then echo "  FLAG: this check crashed and did not run. A review-tier check reports candidates without failing, so a crash looked identical to a clean pass until this line existed."; FAIL=1; fi

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

echo "== Prose checks over one extraction (review, not failures) =="
# Two checks, one extraction, deliberately in a single process over a single file list. They used
# to derive their own filters, and a peer found the consequence in their own corpus: one measured
# bullets and the other did not, so a claim that length did not correlate with abstraction was
# comparing a full-corpus number against a partial one. A difference between two checks is then
# indistinguishable from a difference in what they looked at. Sharing the extraction is also what
# keeps the three-state bullet handling from regressing, since there is one place it can be wrong.
#
# Scope is human-facing files only, for both. Length proxies the re-read test and back-reference
# proxies whether a reader can resolve a noun phrase without scrolling back, and both are costs a
# person pays. An agent reading a convention linearly already holds the referent, so pointing
# either check at `template/conventions/` measures a defect those files do not have.
if command -v python3 >/dev/null 2>&1; then
  python3 - <<'PYPROSE'
import re, glob

FILES = (['README.md', 'CONTRIBUTING.md', 'template/README.md', 'template/DEVELOPMENT.md',
          '.dev/roadmap.md', '.dev/tech-debt.md']
         + sorted(glob.glob('docs/*.md'))
         + sorted(glob.glob('.dev/docs/**/*.md', recursive=True)))

NOUNS = ("shape|thing|mechanism|premise|distinction|property|structure|"
         "seam|posture|residue|trade|gate|move|half")
BACKREF = re.compile(r"\bthe (" + NOUNS + r")\b", re.I)


def paragraphs(path):
    """Prose paragraphs, with block markers ending one and starting another.

    Three states, not two: a marker neither welds onto the paragraph above it nor gets
    discarded. Welding inflates and discarding undercounts, and only inflation announces
    itself, since a smaller number reads as a cleaner file. Both errors occurred within a day,
    in two implementations, and the undercounting one survived longer in each.
    """
    text = re.sub(r'```.*?```', '', open(path).read(), flags=re.S)
    # An indented block survives the fence strip and its lines start with a letter, so the
    # marker filter below does not catch them either.
    lines = [l for l in text.split('\n') if not re.match(r'^(    |\t)\S', l)]
    out, cur = [], []
    for line in lines + ['']:
        stripped = line.strip()
        is_block = stripped[:1] in '#-*|>' or bool(re.match(r'^\d+\.', stripped))
        if stripped and is_block and cur:
            out.append(' '.join(cur)); cur = []
        if stripped:
            cur.append(stripped)
        elif cur:
            out.append(' '.join(cur)); cur = []
    for para in out:
        if not para or para[:1] in '#|>':
            continue
        # Bullets carry prose and are where people compress, so measure them without the marker.
        para = re.sub(r'^([-*]|\d+\.)\s+', '', para)
        if para:
            yield para


total = over = 0
worst = []
refs = {}
near = []
for f in FILES:
    n = 0
    for para in paragraphs(f):
        clean = re.sub(r'`[^`]*`', '', para)
        for m in BACKREF.finditer(clean):
            n += 1
            depth = len(clean[:m.start()].split())
            if depth <= 10:
                near.append((f, depth, clean[m.start():m.start() + 44].strip()))
        for sent in re.split(r'(?<=[.!?:])\s+', para.replace('**', '')):
            sent = ' '.join(sent.split())
            words = len(sent.split())
            if words < 4:
                continue
            total += 1
            if words > 30:
                over += 1
                worst.append((words, f, sent))
    if n:
        refs[f] = n

print(f"  density: {over} of {total} sentences over 30 words")
for words, f, sent in sorted(worst, reverse=True)[:3]:
    print(f"    {words:4d}w  {f}")
    print(f"          {sent[:96]}...")
if len(worst) > 3:
    print(f"    ... and {len(worst)-3} more")

ref_total = sum(refs.values())
print(f"  back-reference: {ref_total} across {len(refs)} file(s), {len(near)} with little before them")
for f, n in sorted(refs.items(), key=lambda x: -x[1])[:3]:
    print(f"    {n:4d}  {f}")
# The ordering, not a verdict. A back-reference whose referent sits one clause away costs a
# scanning reader effort and nobody else; one whose referent is absent or plural is ambiguity and
# costs every reader. That is the distinction separating a candidate from a defect, and it is what
# the reporter of this check was applying by hand when sixteen of their fifty-six turned out real.
# Distance from the paragraph's start is a weak proxy for it and an honest one: a match with ten
# words in front of it has almost nothing to refer to, while a later match usually does.
for f, d, frag in sorted(near)[:3]:
    print(f"    {d:2d}w in   {f}: {frag}")
print("  Judge by where the referent is, not by the match: one clause away is effort and only a")
print("  scanning reader pays it; absent or plural is ambiguity and everyone does.")
PYPROSE
  if [ $? -ne 0 ]; then echo "  FLAG: this check crashed and did not run. A review-tier check reports candidates without failing, so a crash looked identical to a clean pass until this line existed."; FAIL=1; fi
else
  echo "  skipped (python3 not found)"
fi

echo "== Corrections whose referent may never have existed (candidates) =="
# `writing-style.md` names this grep and nothing ran it, which is the defect the rule is about
# arriving in the rule itself: a check that existed only as a description of a check. Reported by
# a peer who found the same shape in their own corpus, having written the grep into the rule that
# morning and never run it. Their build lesson applied here: the file defining a defect quotes it,
# so the rule's own documentation is excluded from itself or the first run is unreadable.
#
# Candidates, not defects. Verification needs `git log -S` on the claim being corrected and that
# cannot be mechanized per-hit, so this raises and a person decides. An empty git result is the
# finding rather than an inconclusive one, which is why the rule exists.
python3 - <<'PY_EOF'
import re, glob
# Matched on shape rather than on an enumerated vocabulary, after a peer found that listing the
# nouns that could follow "earlier" missed genuine instances phrased differently. Widening from
# six literal phrases to eleven surfaced three more here that had been sitting in the corpus.
PHRASES = (r"was recorded as|was described as|an earlier note|earlier reading|previously stated"
           r"|an earlier version|earlier text|previously recorded|an earlier draft"
           r"|this file previously|had previously")
pat = re.compile(PHRASES, re.I)
hits = []
for f in sorted(glob.glob("template/**/*.md", recursive=True)) + sorted(glob.glob("docs/*.md")):
    raw = open(f).read()
    # Line-based matching is blind to any phrase a hard wrap splits, silently and permanently.
    # Replacing single newlines one character for one character keeps every offset indexing the
    # raw text, so the line number below stays correct; counting newlines in the flattened text
    # would report paragraph indices instead, which looks plausible and is wrong.
    # INVARIANT: every transform below replaces one character with one character, which is the
    # only reason offsets still index `raw` and the line number computed afterwards is correct.
    # Adding a transform that changes length breaks that silently: nothing errors, the matches
    # stay plausible, and the line numbers drift. If one is ever needed, compute positions before
    # it runs rather than after, and do not rely on the ordering being free.
    flat = re.sub(r"\n(?!\s*\n)", " ", raw)
    # The shielding problem, answered generally rather than per pattern: a file documenting a
    # defect must quote it, and a quotation is not an instance. Blanking quoted spans rather than
    # excluding whole files halves the hits here and lets the rule's own file be scanned for real
    # ones. Same width substitution, so offsets survive.
    masked = re.sub(r"`[^`\n]*`", lambda m: " " * len(m.group(0)), flat)
    masked = re.sub(r'"[^"\n]{0,200}"', lambda m: " " * len(m.group(0)), masked)
    for m in pat.finditer(masked):
        line_no = raw[:m.start()].count("\n") + 1
        hits.append((f, line_no, " ".join(flat[max(0, m.start()-30):m.start()+90].split())))
if not hits:
    print("  none: no correction points at a claim that may not exist")
else:
    print(f"  {len(hits)} candidate(s). For each, grep the corpus for the claim being corrected and")
    print("  run `git log -S` on it. Nothing in either means the referent is phantom: state the")
    print("  fact positively and delete the correction.")
    for f, n, frag in hits[:6]:
        print(f"    {f}:{n}  ...{frag}...")
    if len(hits) > 6:
        print(f"    ... and {len(hits)-6} more")
PY_EOF
if [ $? -ne 0 ]; then echo "  FLAG: this check crashed and did not run. A review-tier check reports candidates without failing, so a crash looked identical to a clean pass until this line existed."; FAIL=1; fi

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

sys.dont_write_bytecode = True
sys.path.insert(0, "testing/scripts")
from patterns import PATTERNS          # single source: the fixture tests exactly these
DASH = PATTERNS["dashes"]

def strip_noncontent(line):
    line = re.sub(r"`[^`]*`", "C", line)       # inline code: a placeholder, so a connector after it stays visible
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
        for label, pat in DASH:
            if label == "em or en dash" and path in ALLOW_LITERAL:
                continue
            if pat.search(text):
                bad.append((path, n, label))

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
  echo "All checks passed over the files. That is a coverage statement and not a quality one: these patterns found nothing, and a defect no pattern here looks for is indistinguishable from its absence. Nothing observed a message either, so a convention with a file check should be assumed unenforced in conversation until something shows otherwise."
else
  echo "One or more checks flagged something above. Review before committing."
fi
exit "$FAIL"
