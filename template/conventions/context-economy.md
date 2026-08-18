# Context economy

How to decide what instruction text costs too much, and what to do about it. Read this when instruction files have grown enough that reading them is itself a noticeable cost, or before restructuring any of them.

This is a procedure, not a philosophy. It is written to be followed step by step and to produce the same answer regardless of who or what runs it, because the judgement it replaces is the expensive part.

## The one thing to understand first

**Cost is bytes times how often they are read, never bytes alone.** A 50KB file read on a narrow trigger a few times a month is cheap. A 5KB file read unconditionally at every session start is expensive. Rank every candidate fix by frequency-weighted cost, and you will usually find the biggest win is not in the biggest file.

So the first question about any block of text is never "is this too long?" It is **"what event causes this to be read?"**

## Step 1: measure, never estimate

Estimates are wrong in this domain, reliably and in both directions. Get real numbers before forming any opinion.

- `wc -c` every instruction file, not just the ones that feel big.
- Break the largest files into sections and get per-section byte counts and percentages. A file is rarely uniformly expensive; usually one or two sections dominate.
- Compute the **unconditional read set**: follow the session-start checklist literally and add up every file it mandates. That total is the number that matters most.
- Record the numbers. A later step will compare against them, and "it feels smaller now" is not a result.

## Step 2: classify every section by its trigger

For each section, answer one question: **what event causes an agent to read this?**

- **Unconditional**: read at every session start, no condition.
- **Conditional but frequent**: fires on something that happens most sessions (writing code, committing).
- **Narrow**: fires on a specific, recognizable event (a troubleshooting symptom, a release, an upgrade).
- **Reference**: consulted at the moment of producing a specific artifact (an entry format, a template).

**A section whose trigger differs from the trigger of the file it lives in is the split candidate.** That mismatch is the whole signal. It means every agent paying for that file is paying for content it was not there to read, and, just as bad, the agent who actually needs that content has no trigger pointing at it.

Two real examples of the mismatch, both found by this exact test: a section on checking for upstream updates living inside a file about where conventions belong, while being read at every session start from a different file entirely; and troubleshooting guidance for "the agent cannot see my file" living inside the session-start file, where nobody troubleshooting would think to look.

## Step 3: pick the fix, in this order of preference

1. **Relocate to the trigger.** Move the section into its own file and dispatch it from the event that actually needs it. This is the default and the only one that improves both cost and correctness: the content gets cheaper *and* more likely to fire when it matters.
2. **Merge.** Two small files that share one dispatch row and are always read together should be one file. This saves a dispatch destination and a reader's attention, not many bytes.
3. **Archive.** Historical records (a changelog's older releases, closed session logs) that no procedure reads can move out of the active file. Check first that nothing actually reads them.
4. **Rewrite for density.** Last resort, and a genuinely separate pass from the others. See § What not to do before attempting this.

## Step 4: do not break it while fixing it

A split that leaves dangling pointers has made things worse, not better. These are not optional.

- **Leave an entry point behind.** Keep the original file with a short pointer to the new location. An adopter whose copied dispatch table predates your split still resolves the old path and gets forwarded, so the change degrades gracefully instead of breaking them. This is usually what lets a split ship as non-breaking.
- **Repoint every live reference, and verify by grep, not by memory.** Search for the old section name and the old file path across the whole repo. Fix live files; leave already-released changelog entries and historical session logs alone, since those record what was true at the time.
- **Wire the new file in.** A new convention file needs a dispatch line and a row in the file table (see `CONTRIBUTING.md` § Proposing changes). A file that exists but is reachable from nothing is worse than no file.
- **Re-run the mechanical checks.** If a check now fails because of a legitimate, intended difference your change introduced, fix the check to model that difference explicitly, then confirm by reintroducing a real fault that it still fails. Do not weaken a check to make it pass.

## Step 5: report both reading models, honestly

An agent told to read "`file.md` § Section" may read only that section or may read the whole file. You usually cannot tell which. So state the result both ways:

- **Conservative**: the agent reads only the cited section. A split saves little here, sometimes slightly negative once a new file's header is counted.
- **Realistic**: the agent reads the whole cited file. This is where a split pays.

Reporting only the favourable number is the easiest way to overstate this work, and the numbers are cheap to compute both ways. If a correctness fix in the same batch *added* bytes, say so separately rather than netting it against the saving and reporting one number.

## What not to do

- **Never delete a rule to save tokens.** Cost is a reason to relocate content, never to drop it. If a rule genuinely no longer applies, remove it for that reason and say so; do not let a size target make that decision.
- **Never compress away the reasoning that lets an agent judge an unlisted case.** A rule plus its "why" handles cases the rule does not enumerate; a bare rule does not. Strip the incident narrative (that belongs in the changelog) rather than the reasoning.
- **Do not split by topic.** Topic is how a human would file it; trigger is what determines cost and whether it fires. Splitting by topic produces tidy files that are read at exactly the wrong times.
- **Do not move safety-critical content out of an always-read file unless a mechanical backstop already exists.** If a rule's violation is silent and hard to reverse, relocating it trades a token cost for a correctness risk. Build the backstop first (a hook, a script check), then relocate. If you cannot, leave it and log the decision.
- **Watch for the growth loop.** The most common cause of bloat is this: a rule does not fire, and the fix is a reinforcing paragraph added to the file whose size caused it not to fire. That makes the next miss more likely, not less. When you catch yourself adding emphasis to an already-large always-read file, the real fix is almost always a trigger closer to the moment of use, or a mechanical check, not more words.

## When to run this

Not continuously; that is its own waste. Run it when a measurement threshold is crossed rather than on a feeling, for example when the unconditional read set grows past a budget the project has set for itself, or when any single always-read file doubles. Setting that budget as a mechanical check is better than remembering to look.
