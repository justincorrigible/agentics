#!/usr/bin/env bash
# Ownership registry status and integrity report for an agent index.
#
# Called by conventions/agent-index.md § Registering and changing ownership before an agent
# writes an entry, and usable on its own by a developer wanting the current picture.
# Reports; never edits.
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
import os, re, sys

path = sys.argv[1]
text = open(path).read()

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
        cur = {'label': key.group(2).strip(), 'f': {}}
        entries.append(cur)
        continue
    field = re.match(r'\s+([a-z_]+):\s*(.*)$', line)
    if field and cur is not None:
        cur['f'][field.group(1)] = field.group(2).strip()

if not entries:
    print("  ok: Members section present, no entries yet")
    sys.exit(0)

LEGACY = {'id', 'focus', 'updated', 'project', 'scope'}
REQUIRED = {'owns', 'expert', 'workspace'}

errors, notes, owners, path_errors = [], [], [], []

print(f"REGISTRY STATUS  ({path})\n")
print(f"  {'label':<32}{'owns':<34}{'conferred':<11}{'schema'}")
print(f"  {'-'*31} {'-'*33} {'-'*10} {'-'*12}")

for e in entries:
    label, f = e['label'], e['f']
    if not label:
        errors.append("an entry has no label")
        continue

    stale = LEGACY & set(f)
    schema = 'pre-registry' if stale else 'current'
    conferred = 'yes' if 'assigned' in f else 'no'
    owns_raw = f.get('owns', '')
    shown = owns_raw if owns_raw else '(none recorded)'
    print(f"  {label[:31]:<32}{shown[:33]:<34}{conferred:<11}{schema}")

    if stale:
        errors.append(f"{label}: pre-registry field(s) {', '.join(sorted(stale))}; needs migrating")
    for missing in sorted(REQUIRED - set(f)):
        errors.append(f"{label}: missing required field '{missing}'")

    for p in (x.strip().rstrip('/') for x in owns_raw.split(',') if x.strip()):
        if p.startswith('/') or p.startswith('~') or re.match(r'^[A-Za-z]:', p):
            errors.append(f"{label}: absolute path in owns ({p}); paths are org-relative")
            path_errors.append(p)
        owners.append((p, label))


cur_n = sum(1 for e in entries if not (LEGACY & set(e['f'])))
conf_n = sum(1 for e in entries if 'assigned' in e['f'])
print(f"\n  {len(entries)} entries: {cur_n} on the current schema, {len(entries)-cur_n} pre-registry")
print(f"  {conf_n} developer-conferred, {len(entries)-conf_n} provisional")

seen = {}
for p, label in owners:
    k = p.lower()
    if k in seen and seen[k][1] != label:
        prev_p, prev_l = seen[k]
        same = "" if prev_p == p else f" (written '{prev_p}' and '{p}')"
        errors.append(f"path '{p}' claimed by both {prev_l} and {label}{same}")
    seen[k] = (p, label)

if owners:
    print("\nOWNERSHIP RESOLUTION  (longest matching prefix wins)")
    for p, label in sorted(owners):
        parents = [q for q, _ in owners if q.lower() != p.lower() and p.lower().startswith(q.lower() + '/')]
        marker = "within " + max(parents, key=len) if parents else "top level"
        print(f"  {'  ' * len(parents)}{p}  ->  {label}   ({marker})")

    # Family heads are DECLARED in `main`, not inferred from a broad `owns`. Inferring them was
    # this script's original behaviour and it went wrong the moment `main` shipped: an entry was
    # narrowed from `iMicroSeq` to `iMicroSeq/portal-ui` and its headship moved to `main`, after
    # which the inference found no root, printed nothing, and reported INTEGRITY ok. A peer read
    # that output and concluded the family had lost its owner, which is the natural reading of
    # silence. A bare top-level `owns` with no `main` beside it is now the thing worth flagging,
    # since post-`main` it is most likely the conflation `main` exists to undo.
    heads = sorted({(e['f']['main'].strip().rstrip('/'), e['label'])
                    for e in entries if e['f'].get('main', '').strip()})
    roots = sorted({(p, l) for p, l in owners if '/' not in p})
    # Comparisons below are case-folded; casing is preserved for display only.
    if path_errors:
        # Every claim below rests on exact path comparison, so with a malformed path present a
        # carve-out can read as a separate root and the counts below would be confidently wrong.
        # A wrong answer in the section a reader opens to check is worse than no answer.
        print("\n  Family-root claims suppressed: path errors above make these counts unreliable.")
    else:
        if heads:
            print("\n  Family heads, declared in `main`:")
            for m, label in heads:
                carved = [q for q, _ in owners if q.lower().startswith(m.lower() + '/')]
                inner = [x for x, _ in heads if x.lower() != m.lower() and x.lower().startswith(m.lower() + '/')]
                print(f"    {label} holds '{m}'")
                verb = 'entry carves' if len(carved) == 1 else 'entries carve'
                print(f"      {len(carved)} owned {verb} out of it; anything else there is the head's")
                if inner:
                    print(f"      nested head(s) below it: {', '.join(inner)}")
        else:
            print("\n  No family heads declared. Nothing holds a space; unowned paths resolve to nobody.")
        unheaded = [(p, l) for p, l in roots if not any(m.lower() == p.lower() for m, _ in heads)]
        if unheaded:
            print("\n  Top-level `owns` with no matching `main`, worth confirming is intended:")
            for p, label in unheaded:
                print(f"    {label} owns the whole of '{p}' without declaring headship of it.")
                print(f"      Either the conflation `main` exists to undo, or an accurate claim "
                      f"about a space with one owner.")
                print(f"      Nothing here distinguishes them: only that owner or the developer can say.")
else:
    print("\nOWNERSHIP RESOLUTION")
    print("  Nothing resolvable: no entry records an `owns` path.")

# Peer status is decided by workspace, so two spellings of one name split a workspace in two
# and each half stops reading as peers of the other. Folded for comparison only: no casing is
# canonical across workspaces, and an earlier heuristic that picked one flagged a correct entry.
ws = {}
for e in entries:
    v = e['f'].get('workspace', '').strip()
    if v:
        ws.setdefault(v.lower(), set()).add(v)
for _, spellings in sorted(ws.items()):
    if len(spellings) > 1:
        notes.append("one workspace is written " + str(len(spellings)) + " ways: "
                     + ", ".join(sorted(spellings))
                     + "; its members are peers regardless, align at the owners' discretion")

# Which entry, if any, claims the directory this was run from. The match is on the last path
# segment, because nothing else works: `owns` uses informal org shorthand (`softeng/agentics`
# for a repo whose remote is `oicr-softeng/agentics`), so deriving an entry from a git remote
# fails, and matching a full local path would require absolute paths this file forbids. A
# basename match collides where two orgs share a repo name, and that is acceptable: the output
# is orientation, not authorization, which is the standard already applied to a self-reported
# label. Good enough to tell a session it is standing in someone else's project; never good
# enough to tell it who it is.
here = os.path.basename(os.getcwd().rstrip('/'))
claims = [(o, l) for o, l in owners if o.rstrip('/').split('/')[-1].lower() == here.lower()]
heads_here = [(m, l) for m, l in (heads if 'heads' in dir() else [])
              if m.rstrip('/').split('/')[-1].lower() == here.lower()]
print(f"\nTHIS DIRECTORY  ('{here}')")
if claims or heads_here:
    for o, l in claims:
        print(f"  claimed by {l}, which owns '{o}'")
    for m, l in heads_here:
        print(f"  held by {l} as a family head over '{m}'")
    print("  Standing here is not being them. A label is held only if the developer conferred")
    print("  it in this session; if they did not, you are a task thread in someone's project.")
else:
    print("  No entry claims a path ending in this name.")
    print("  That is not evidence you own it: the registry holds owners and most work is not.")

# The board carries two shapes. A request wants an owner to act and its poster clears it; a
# notice reports a change already made and its recipient clears it, since only they know they
# have read it. Nothing pushes either to anyone, so counting them here is the only nudge.
BOARD_KINDS = {'for', 'fyi', 'sync'}
b = re.search(r'^## Requests\b.*?\n(.*?)(?=^## |\Z)', text, re.S | re.M)
items = []
if b:
    body = re.sub(r'```.*?```', '', b.group(1), flags=re.S)
    it = None
    for line in body.splitlines():
        k = re.match(r'\s*-\s+([a-z_]+):\s*(.*)$', line)
        if k:
            kind = k.group(1)
            if kind not in BOARD_KINDS:
                # Not skipped: an unrecognized shape must break the parse loudly. Matching only
                # known kinds meant a `sync:` entry started no item, so its indented fields folded
                # into the entry above and its `from:` overwrote that entry's, producing a listing
                # that named a real label genuinely posting to a real owner. Silent, plausible, and
                # exit 0. Erroring here catches the next shape before it ships rather than after.
                errors.append(f"board entry of unknown kind '{kind}:' (known: "
                              + ", ".join(sorted(BOARD_KINDS)) + "); its fields would otherwise "
                              "fold into the entry above and overwrite them")
                it = None
                continue
            it = {'kind': kind, 'who': k.group(2).strip(), 'f': {}}
            items.append(it)
            continue
        f = re.match(r'\s+([a-z_]+):\s*(.*)$', line)
        if f and it is not None:
            it['f'][f.group(1)] = f.group(2).strip()

reqs = [i for i in items if i['kind'] == 'for']
fyis = [i for i in items if i['kind'] == 'fyi']
syncs = [i for i in items if i['kind'] == 'sync']
if items:
    print("\nBOARD")
    if reqs:
        print(f"  {len(reqs)} request(s) open, cleared by whoever 'from' names:")
        for i in reqs:
            print(f"    {i['who']}  <-  {i['f'].get('from','?')}  ({i['f'].get('re','no subject')})")
    if fyis:
        print(f"  {len(fyis)} notice(s) unread, cleared by the recipient:")
        for i in fyis:
            print(f"    {i['who']}  <-  {i['f'].get('from','?')}  ({i['f'].get('re','no subject')}"
                  f", by {i['f'].get('by','UNSTATED AUTHORITY')})")
    if syncs:
        print(f"  {len(syncs)} sync notice(s), superseded by the next sync of the same path:")
        for i in syncs:
            print(f"    {i['who']}  ->  {i['f'].get('to','VERSION UNSTATED')}"
                  f"  (from {i['f'].get('from','?')})")
        seen_paths = {}
        for i in syncs:
            k = i['who'].lower().rstrip('/')
            if k in seen_paths:
                errors.append(f"two sync notices for '{i['who']}'; one per path, "
                              "the later replacing the earlier")
            seen_paths[k] = i
    for i in fyis:
        if 'heard' in i['f']:
            errors.append(f"notice for {i['who']} carries 'heard'; a notice needs no answer")
        if not i['f'].get('by'):
            errors.append(f"notice for {i['who']} states no authority in 'by'")
    for i in items:
        posted = i['f'].get('posted', '')
        if not posted:
            errors.append(f"board item for {i['who']} has no 'posted' date")
        # The board's only staleness signal is this field, and a zeroed time is a guess that
        # reads as a real reading. Flagged rather than failed: a genuine midnight post exists.
        elif 'T00:00' in posted:
            notes.append(f"board item for {i['who']} posted at {posted}; a zeroed time is "
                         "usually a placeholder, and it ages the entry falsely")
        if i['f'].get('via') and not i['f'].get('from'):
            errors.append(f"board item for {i['who']} has 'via' but no 'from'; "
                          "'from' names who holds the need and who clears it")

print("\nINTEGRITY")
if errors:
    for e in errors:
        print(f"  FLAG: {e}")
else:
    print(f"  ok: no collisions, no absolute paths, no pre-registry fields")
for n in notes:
    print(f"  note: {n}")

# The limits are part of the report. A reader who mistakes this for the whole picture will
# believe the registry is a census, which is the error the convention warns about.
print("""
NOT KNOWABLE FROM THIS FILE, AND NOT A GAP IN IT
  - Whether any session currently holds each label. Conferral happens in a session and is
    recorded nowhere, so a listed entry does not mean someone is holding it right now.
  - Whether a session that holds a label knows that it does. Only that session can say.
  - Which live sessions exist. This script cannot see a session listing, and the registry
    deliberately excludes task threads, so it is never a census of anything.
  Each of these resolves only by asking. That is a property of the design, not a shortfall
  here: identity is conferred rather than derived, so no file can answer these.""")

sys.exit(1 if errors else 0)
PYEOF
