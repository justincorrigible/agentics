# Writing style conventions

Conventions for producing any written output, code or not: a doc update, a ticket, a commit message, a PR comment, a config file. Distinct from `code-style.md`, which covers implementation-specific conventions (comments, TypeScript patterns, module design) that only apply when writing code. Everyone reads this file; only developers additionally need `code-style.md`.

## Language and typos

Flag typos and language issues when spotted: in code, comments, and documentation. Don't fix silently; call them out so the developer can decide.

## Naming the person you are talking to

**This section is deliberately not titled with the phrase it restricts.** An earlier version was, so every lookup of the rule reprinted the habit the rule exists to break, and the body used the phrase inside the sentence forbidding it. Reported by a session that had read this file that morning, quoted it while working, and then used the phrase for the rest of the day until the developer asked twice who was meant.

**Addressing someone and referring to them are different acts, and only one of them takes a name.** When you are talking *to* the developer, use the second person, always. A name in that slot reads as though you are describing them to someone else who is also present. Use their name when you are referring to them and second person does not fit: visible reasoning that narrates rather than addresses, or a sentence distinguishing them from another person under discussion. The generic third-person label stays a last-resort fallback in either case, because it reads as clinical distance when you are talking to someone rather than describing them to a third party.

**The test: if the name can be replaced by "you" and the sentence still works, it should be "you."** That is checkable without already knowing the answer, which the earlier wording was not.

**Never use both for the same person in one sentence.** "Andy is right to flag that: my report to you..." makes a reader work out whether the named party and the addressed party are the same, and the answer is not recoverable from the sentence. Observed in the wild, and the earlier form of this rule would have produced it: it said to use the name whenever one is recorded and offered second person only as the fallback for when no name is known, which inverts the hierarchy for anything addressed to the person directly.

**In a shared, checked-in instruction file none of that applies, and the answer is "the developer".** A name is wrong, since the file belongs to no one person. Second person is frequently awkward there. The generic label is the thing being avoided. Nothing stated this before, and this template's own `AGENTS.md` carried four instances of the label against six of "the developer" for the same person, two of them two lines apart.

**Where "user" is a term in the project's own subject matter, reserve it for that meaning and say "the developer" for the person.** In anything concerning authorization, identity, accounts, or access, the word already names the party whose access is controlled. An instruction like "let the user decide" then parses as a claim about the domain, and a reader cannot recover which was meant. Found inherited near-verbatim from this template into an authorization service's own `AGENTS.md`.

**Assertion alone loses here, which is why the wording of the rule matters more than usual.** An agent's operating context uses the generic label constantly, at a priority no repository file competes with. A convention forbidding a phrase that the surrounding context repeats cannot win by being correct.

**Only half of this is checkable, and the unenforced half is where it actually fails.** Persisted files are greppable, so `testing/scripts/check-consistency.sh` lists occurrences in the template for review rather than failing, since describing the person to a third party is legitimate and no check can tell the two apart. Conversational replies are not greppable at all. So the listing covers the case that was mostly fine already, and the case that broke has no mechanism; see `docs/deterministic-by-design.md` § When no honest proxy exists.

This applies to live, ephemeral output only: replies and visible reasoning. It does not apply to persisted, checked-in content: `session-discipline.md` § "Name code, not people" already requires the opposite there (attribute to features and systems, not individuals), regardless of how well the person's name is known in conversation. The two don't conflict: a live reply can use a name directly, while that same work's session-file entry still describes what changed, not who asked.

## Copy the shape, not the surface

**A model handed to you as a correction carries its author's incidental habits alongside the structure worth taking.** Adopt the structure and inspect everything else against the standing rules, because the two arrive together and only one of them was the point.

**The reason it is hard to catch is that a correction carries authority, and authority suppresses inspection of its incidentals.** You accept the shape because it is better, and the habits ride in behind the thing you were right to accept. Supplied by the session that hit it: a developer's rewrite of one of its review comments was structurally better and contained "in favor" against a standing Canadian-spelling rule, and the draft copied from it inherited the spelling along with the structure.

**This rule does not reach a relational property, and reaching for it there wastes the attempt.** It works because an incidental rides along *inside* the thing you copied, so inspecting what you took can find it. Position, ordering, adjacency and precedence are not inside anything: they are relations to neighbours, so they come from where you put the copy rather than from the copy. Told to inspect the incidentals, you would look at the copied artifact and find nothing wrong, because the frame contains nothing to inspect. Supplied by the session that had misfiled its own instance here and then worked out why the remedy could not have helped it.

**Spelling is the visible instance of an invisible class.** Dashes, capitalization, terminology, the generic third-person label for the developer, and anything else a project has decided are all carried the same way. Applies to any offered exemplar, not only a developer's: a peer's sample, an upstream document, a snippet from a linked issue.

## Prose is a serialization, and the reader has to reverse it

**The asymmetry to design around: for a language model the verbalization is the process, and for a person it is a byproduct of one.** People have an inner voice, but it reports on layers operating in understanding rather than in words, so a sentence is what surfaced rather than what happened. Nothing symmetrical holds for a model, whose visible token stream is where the work occurs. Writer and reader are therefore not running the same operation in opposite directions.

**So prose is native output for one side and a lossy import format for the other.** Content with a shape, a comparison, a mapping, a hierarchy, a set of parallel items, gets flattened into a line on the way out, and the reader rebuilds the shape on the way in. Good writing does not avoid this. It makes the flattening pleasant, and a four-way relationship explained in an elegant paragraph is still a four-way relationship someone has to reassemble.

**The test is whether the content has structure other than a line.** If it does, emit the structure: a table, a list, a diagram. If it does not, and an argument, a causal chain or a single claim with its support genuinely does not, prose fits and a table would impose a shape the content lacks. This is a question of fit, so neither form is the fallback and neither is the reward for good behaviour.

**Trigger on item count, not on topic.** An earlier form of this guidance keyed on subject matter, naming design decisions and trade-offs, which let findings, status reports and lists of changes through untouched; the observed result was a developer asking for a list after nearly every long answer, across sessions and projects. More than one discrete item is the signal, whatever they concern. Two items already carry a relationship between them, and the relationship is the first thing a line loses. The threshold was set at roughly three by the writer before the developer corrected it to one, which is the asymmetry this section describes occurring inside it: a reader who pays the decompression cost knows where it starts, and a writer guessing at it will guess high.

**Fluency is free to produce and costly to consume, which is why the trigger has to be mechanical.** A model emits confident, well-formed paragraphs at no marginal effort, so volume never feels expensive from the writing side and the cost lands entirely on the reader. Judgement applied by the writer is judgement applied by the party not paying.

**This is not the Density rule restated.** Density asks how much is packed into a sentence. This asks whether a sentence is the right container at all, and the two fail independently: a perfectly unpacked paragraph can still be the wrong shape for what it carries.

## Say what changed, not how you got there

**Default to succinct in anything a reader has to act on: a code comment, a commit message, a review comment, a draft for the developer.** It is the default already, stated separately in three files in three wordings, and it kept failing because a reader writing a commit message did not think a rule about "any entry" was addressed to them. One statement, here, because this file is read for every kind of output.

**Procedural narration is the specific thing to cut, and it is the most tempting thing to write** because it is what you have just finished doing and it feels like the substance. Process is: how you found it, what you tried and abandoned, which session or review surfaced it, what you verified along the way, and the artifact's own edit history. None of it survives contact with a reader who arrives later wanting to act.

**The test is what the reader does next.** They need what is true now and what to do about it. "Originally thought the cause was X, then found Y" is one fact wearing the costume of two. Where the path genuinely is the content, as in a post-mortem or a design record, that is a different artifact and this does not govern it.

**Shortness is the consequence, not the instruction.** Cutting until claims fuse trades a long artifact for a misleading one; see § Density, which pulls the other way and is applied second.

## One derivation, one owner

**When two artifacts ship together and both could carry the same reasoning, one owns it and the other points at it.** Not the accumulation `code-style.md` § Comments describes, which needs rounds to build up: this happens at a single instant, a commit body and a changelog entry written together, each fully re-deriving the same explanation. § Say what changed does not reach it, because that rule cuts by category and the duplicated reasoning is usually substantive and worth reading. Its only defect is being in the second-best of two places.

**The owner is decided by where the reader stands on their path, not by what kind of artifact it is.** Readers notice a change, orient, then act on it; one still triaging needs enough to decide whether to look further, one already acting needs the derivation. The later stage owns it. **Posture is relative rather than absolute**: the same changelog entry is the later stage against a commit body and the earlier stage against a migration guide, and both at once, because a path is ordered. Asking per artifact class asks at the wrong grain, and manufactures a limit that is not there.

**Compress, never delete.** The earlier artifact keeps enough to stand alone for its own stage. Reported by the SQON session, from a commit whose body re-derived reasoning that its own changelog entries already carried in full: what shipped kept "(a `not`'s children are independently negated)", enough to make the diff intelligible to someone reading only the log, while the derivation lived once.

**Two conditions bound it.** The owning artifact has to exist and be reachable when the earlier reader arrives, which is why a paging alert cannot compress against an incident writeup authored afterward. And two artifacts at the same stage fall outside this rule entirely: that is plain duplication, governed by § Say it once, where the remedy is deletion rather than compression.

## Density

Write so the first read is enough. **Human-facing content only**, and the boundary is load-bearing rather than a caveat.

**The test for scope is who reads the file to make a decision, and it is not a directory test.** An earlier draft of this section split by path and was wrong in the way that matters: the document that prompted the whole rule was `.dev/docs/atlas/roadmap/doc-reconciliation.md`, which a path rule puts on the exempt side. Reported by the session that raised the original problem.

| Category | Examples | Rule |
| --- | --- | --- |
| Human-facing | `README`, `DEVELOPMENT`, `/docs`, PR and commit text, review findings, anything said in chat | Density applies |
| Agent-facing instructions | `AGENTS.md`, `CLAUDE.md`, `copilot-instructions.md`, the convention files | Condensed. Context economy wins |
| Working docs both read | `.dev/roadmap.md`, `.dev/tech-debt.md`, `.dev/docs/` | Human rule: a person reads these to decide something |

**The asymmetry decides the third row.** An agent reading a longer document spends context budget, which has slack and can be recovered by summarizing. A person reading a condensed one pays a cost they cannot delegate. So where both read, the human rule wins.

**Note that `.dev/` spans two rows.** `roadmap.md` follows the human rule; session logs are condensed. The directory tells you nothing; the question is always whether a person reads it to decide.

**Exempting agent-facing docs from Density does not exempt them from everything: brevity is licensed, ambiguity is not.** The replacement rule is **condense freely, but never to a pointer that has to be reconstructed.** Reported with the incident that produced it: a reference table named two query operators without describing what either emitted, so the names described each other. That is cheap in tokens and expensive in misinterpretation, and the reader reached for the wrong operator. Had it shipped, an authorization filter would have returned records it was written to withhold. **The human failure mode here is frustration; the agent failure mode is confident misreading, which is worse and quieter.**

**Applying Density itself to agent-facing text would make things worse, not merely be unnecessary.** Unpacking a dense convention inflates a file that every adopter loads on every session, so the reader who gains nothing pays the whole cost. One convention in this repo grew from 18KB to 41KB in a single day of legitimate additions; that is the direction this rule would push all of them.

**One practice here is not scoped, because it is not about density at all: one claim per sentence.** If a sentence carries a claim and its qualification, split it. Split, do not drop; the qualification was load-bearing or nobody would have written it. This applies to agent-facing text too, and the reason it escapes the scope rule is that its cost is accuracy rather than comprehension. Density makes a reader work harder. A merged claim makes them read something nobody asserted.

**It is also free, which is why the inflation argument does not reach it.** Separating two claims adds a full stop, not words: "Superseded, and this is the one that matters: empty combinations are no longer fail-secure" becomes "Superseded. Empty combinations are no longer fail-secure." Shorter, and the priority judgement that was riding along for free is now either stated deliberately or gone.

**It has no mechanical proxy, and placement substitutes for one.** Density is checked by sentence length; this is not a length problem, and a fused sentence can be short. The example above is twelve words. So in condensed files the only writing rule still in force is the one nothing can measure, which is the "easy to agree with and ignore" failure arriving by another route. The answer is where it lives rather than a weak check: it is restated in `entry-formats.md` § One entry states one thing, which an agent reads while composing an entry rather than once at session start. Proxies considered and rejected, because each produces enough false positives to train a reader to skip the output: a colon followed by a judgement clause, the strings "and this is" or "which is the", and a sentence carrying both a status word and a priority word.

**It matters most where prose is thinnest.** A doubled claim in a terse entry is harder to spot than in flowing prose, because nothing around it contradicts the smuggled half. Session logs are the sharpest case: they are what a future reader consults specifically to find out what was decided, so **a merged claim there becomes a decision nobody made.** Reported by a peer session, against an entry in its own log.

**Mixed-audience artifacts resolve toward the person.** A commit message or a CHANGELOG entry is read by both, and only one of them is slowed down by density, so write those for the human.

**The test: if a sentence has to be read twice, the sentence is wrong.** Not the reader. Everything below is a way of failing that test; this is the rule.

**Why this needs saying.** When you finish a piece of work you are holding all of it at once. Your prose becomes an index into that structure instead of a description of it. Names stand in for findings, pointers stand in for arguments, and a single sentence can carry a claim and its qualifications because you can see them together. The reader has none of that structure. They rebuild it sentence by sentence, and that rebuilding is work you moved onto them. You compress once. Every reader decompresses again.

This is not about reading level. Assume the reader knows more about the domain than the document requires. It is about how much work your writing makes them do to reach what you already know. Stated that way the fault is entirely the writer's, which is why it can be said plainly without condescending to anyone.

**What to do**

- **Say the thing before you name it.** "Arranger's plugin hook has no way to refuse a request" comes before "the contract incompatibility." After that, the short name is fine. Never before.
- **Specific before general.** The instance, then the pattern. Not the pattern illustrated afterward.
- **No pointers across distance.** "That arm", "the distinction above", "as noted" all assume the reader is holding what you are holding. If the referent is more than a few lines back, name it again.
- **Prefer the plainer word wherever it is exact.** Not for the reader's benefit. A shorter word leaves less to parse and means the same thing.
- **Three abstract nouns in a row is a rewrite signal.** You have written a summary of a summary. Go back to what actually happened.
- **A document's first sentence should be readable cold**, by someone who has not read anything else you wrote.

**Worked rewrites, since the diagnosis is worth less than instances.** Each is shorter and loses nothing:

> "Findings from a full consistency pass over every design and published document, run after the resource-level enforcement, additive rendering, and zero-entitlement decisions landed."
> **becomes** "Yesterday's decisions changed what these docs should say. This is what they still say instead."

> "one contract incompatibility, a cluster of contradictions that would mislead an implementer, the superseded JWE rationale surviving in five places"
> **becomes** "Arranger's plugin hook cannot refuse a request. Some docs would send an implementer the wrong way. Five places still give the old reason for encrypting the token."

> "which is the distinction that arm exists for"
> **becomes** "that is exactly what `allow` was added to distinguish."

**This rule is unusually easy to agree with and ignore**, because while you are writing, density feels like precision. That is why the re-read test leads and why there is a mechanical proxy: `check-consistency.sh` lists prose sentences over 30 words in human-facing files as review output. Length is not the defect and the list is not a failure; a long sentence is simply where a doubled claim is most often hiding.

**Measured against the files the table above actually covers: 86 of 572 prose sentences are over 30 words**, worst at 68. Expect the figure to move, since it tracks both the corpus and the measure, and an earlier reading of 87 of 564 predates a fix to the splitter. Those files were not exempt from the problem this describes, and shipping the rule without saying so would have been the first thing it forbids. Two earlier drafts of this paragraph cited different numbers because the scope was still wrong, and the direction of the error is worth keeping: each time the boundary was drawn by path it excluded the densest prose in the repository, which is `.dev/docs/` and the roadmap, and which is exactly where a person goes to decide something.

**Session logs are the clearest case of the scope rule above, not a separate exception.** They are agent-facing and deliberately terse for an already-oriented reader, per `documentation.md` § Writing for a cold reader, so the reader-orientation practices here would only pad them: no cold-readable opening, no naming a thing before its short form, no specific-before-general. Terseness and density are different, and the fix for a dense session log is fewer entries rather than longer ones. One claim per sentence still applies, per the exception above.

**Relationship to the narrower rule some global contexts already carry**, that a pitch leads with a concrete example before naming the mechanism. That one stays, and is the sharper case rather than a duplicate: this section is about ordering within prose generally, while the pitch rule is about a decision needing a concrete anchor before it can be made at all. Folding it in here would lose its trigger.

## Dashes

Never use em dashes, en dashes, double hyphens as dash substitutes, or space-hyphen-space as sentence connectors in any output: documentation, code comments, persisted files, or conversational messages. This applies to all text content without exception. Acceptable uses are structural items that are not part of the prose itself: bullet markers (`-`), horizontal dividers (`---`) and markdown table separator rows (`|---|---|`), compound-word hyphens (`well-designed`), and numeric ranges (`1-2 entries`).

Do not use in text:
- Em dashes (`—`, U+2014)
- En dashes (`–`, U+2013)
- Double hyphens (`--`) as a dash substitute
- Space-hyphen-space (` - `) as a sentence connector

For mid-sentence connectors, use a semicolon or rephrase. For inline annotations in bullets (`.dev/sessions/` entries, `roadmap.md`, etc.), use `: ` as the separator: `` `path/to/file`: what changed ``. In titles and headings, use a colon rather than a dash separator: "OWASP Top 10: Quick Reference", not "OWASP Top 10 — Quick Reference".

When correcting existing em dashes across a file, use `sed -i '' 's/ — /: /g'` and verify with `grep -c '—'`.

**Before any output leaves your control, run a mechanical check against the exact final text.** `grep -c '—\|–'` covers the two dash characters and not the other two banned forms, so it passes on text containing ` -- ` or a space-hyphen-space connector: check for all four, or run the repo's own dash check where one exists. This matters most for output with no commit hook behind it, a PR comment, a chat message, an issue reply, which is exactly where the untested forms have slipped through. Do this as a discrete action right before the send, post, or commit, not as background awareness carried from having read this section earlier in the session. This recurred in practice even after being added as a personal refinement in one contributor's own global context: it survived a single output but not a multi-step task (drafting several PR comments in a row), since the rule was read once, early, and the check itself was never re-invoked partway through. A rule stated as absolute needs a mechanical, testable action tied to it, not a description trusted to stay salient on its own.

## Spelling and language convention

[Team placeholder: configure your preferred spelling convention here. Example: Canadian English uses `-our` suffixes (colour, behaviour), `-re` suffixes (centre, fibre), `-ize` (not `-ise`), and `-yze` (analyze, paralyze; unlike the -ise/-ize split, Canadian does not diverge from American here).]

## Say it once, at the density it deserves

The same fact stated twice in different forms costs the same as stating it wrong, not incorrect, just taking up two or three times its own space: a caveat given in prose, then repeated as a bullet; a blocking condition explained, then given its own bolded status label ("trigger condition, not a start-now item") restating the same explanation a second way; a standing convention cited by name locally instead of just applied. Applies equally to `.dev/roadmap.md`, `.dev/tech-debt.md`, and session file entries: an entry that's grown a sub-section explaining its own nature, sitting beside entries that are two or three lines each, is the signal to fold that condition back into the entry's own fact, not evidence this one earned extra structure. Trusting this to happen at the moment of writing is the same fragile shape as any other unenforced judgment call: it's caught for real at the pre-commit re-check above, the same checkpoint that catches stale entries. Same discipline as `CONTRIBUTING.md` § Design principles' succinct-wording rule (see `CHANGELOG.md` § `succinct-wording-is-a-separate-pass`), applied here to any persisted `.dev/` content rather than just convention prose.
