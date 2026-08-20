#!/usr/bin/env bash
# Ownership registry integrity check for an agent index.
#
# Called by conventions/agent-index.md § Registering and changing ownership, before an agent
# writes a new entry. Reports; never edits.
#
# Usage: bash scripts/check-agent-index.sh [path-to-agent-index.md]
#        defaults to ~/.claude/agent-index.md

set -uo pipefail
TARGET="${1:-$HOME/.claude/agent-index.md}"

if [ ! -f "$TARGET" ]; then
  echo "No agent index at $TARGET"
  echo "That is a valid state: the index is an optional accelerant, not a dependency."
  exit 0
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "skipped (python3 not found)"
  exit 0
fi

python3 - "$TARGET" <<'PYEOF'
import re, sys, os

path = sys.argv[1]
text = open(path).read()

# Members runs from its heading to the next one at the same level.
m = re.search(r'^## Members\b.*?\n(.*?)(?=^## |\Z)', text, re.S | re.M)
if not m:
    print("  FLAG: no '## Members' section found; is this an agent index?")
    sys.exit(1)

# Fenced blocks hold the schema template, whose empty `label:` would otherwise parse as an
# entry with no name. Drop them before reading entries.
members = re.sub(r'```.*?```', '', m.group(1), flags=re.S)

entries, cur = [], None
for line in members.splitlines():
    key = re.match(r'\s*-\s+([a-z_]+):\s*(.*)$', line)
    if key and key.group(1) == 'label':
        cur = {'label': key.group(2).strip(), '_fields': {}}
        entries.append(cur)
        continue
    field = re.match(r'\s+([a-z_]+):\s*(.*)$', line)
    if field and cur is not None:
        cur['_fields'][field.group(1)] = field.group(2).strip()

if not entries:
    print("  ok: Members section present, no entries yet")
    sys.exit(0)

errors, notes = [], []

# Fields the ownership-registry schema replaced. A leftover one means the entry predates the
# rewrite and still carries a runtime handle or a value that decays.
LEGACY = {'id', 'focus', 'updated', 'project', 'scope'}
REQUIRED = {'owns', 'expert', 'window'}

owners = []  # (path, label)
for e in entries:
    label, f = e['label'], e['_fields']
    if not label:
        errors.append("an entry has no label")
        continue

    stale = LEGACY & set(f)
    if stale:
        errors.append(f"{label}: pre-registry field(s) {', '.join(sorted(stale))}; entry needs migrating")

    for missing in sorted(REQUIRED - set(f)):
        errors.append(f"{label}: missing required field '{missing}'")

    if 'assigned' not in f:
        notes.append(f"{label}: no 'assigned' value, so this entry is provisional rather than conferred")

    for p in (x.strip().rstrip('/') for x in f.get('owns', '').split(',') if x.strip()):
        if p.startswith('/') or p.startswith('~') or re.match(r'^[A-Za-z]:', p):
            errors.append(f"{label}: absolute path in owns ({p}); paths are org-relative")
        owners.append((p, label))

# Identical path claimed twice is the only hard collision. Containment is legal by design.
seen = {}
for p, label in owners:
    if p in seen and seen[p] != label:
        errors.append(f"path '{p}' claimed by both {seen[p]} and {label}")
    seen[p] = label

if errors:
    for e in errors:
        print(f"  FLAG: {e}")
else:
    print(f"  ok: {len(entries)} entries, {len(owners)} owned paths, no collisions")

for n in notes:
    print(f"  note: {n}")

# Resolution tree: what longest-prefix matching actually yields, so nesting is eyeballable.
if owners:
    print("\n  ownership resolution (longest prefix wins):")
    for p, label in sorted(owners):
        parents = [q for q, _ in owners if q != p and p.startswith(q + '/')]
        depth = len(parents)
        marker = "within " + max(parents, key=len) if parents else "top level"
        print(f"    {'  ' * depth}{p}  ->  {label}   ({marker})")

sys.exit(1 if errors else 0)
PYEOF
