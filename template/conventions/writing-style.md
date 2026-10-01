# Writing style conventions

Conventions for producing any written output, code or not: a doc update, a ticket, a commit message, a PR comment, a config file. Distinct from `code-style.md`, which covers implementation-specific conventions (comments, TypeScript patterns, module design) that only apply when writing code. Everyone reads this file; only developers additionally need `code-style.md`.

## Language and typos

Flag typos and language issues when spotted: in code, comments, and documentation. Don't fix silently; call them out so the developer can decide.

## Naming the person you are talking to

**This section is deliberately not titled with the phrase it restricts.** An earlier version was, so every lookup of the rule reprinted the habit it exists to break, and the body used the phrase inside the sentence forbidding it. Reported by a session that had read this file that morning, quoted it while working, and then used the phrase for the rest of the day until the developer asked twice who was meant.

**Addressing someone and referring to them are different acts, and only one of them takes a name.** When you are talking *to* the developer, use the second person, always. A name in that slot reads as though you are describing them to someone else who is also present. Use their name when you are referring to them and second person does not fit: visible reasoning that narrates rather than addresses, or a sentence distinguishing them from another person under discussion. The generic third-person label stays a last-resort fallback in either case, because it reads as clinical distance when you are talking to someone rather than describing them to a third party.

**The test: if the name can be replaced by "you" and the sentence still works, it should be "you."** That is checkable without already knowing the answer; the earlier wording was not.

**Never use both for the same person in one sentence.** "Sam is right to flag that: my report to you..." makes a reader work out whether the named party and the addressed party are the same, and the answer is not recoverable from the sentence. Observed in the wild, and the earlier form of this rule would have produced it: it said to use the name whenever one is recorded and offered second person only as the fallback for when no name is known, which inverts the hierarchy for anything addressed to the person directly.

**In a shared, checked-in instruction file none of that applies, and the answer is "the developer".** A name is wrong, since the file belongs to no one person. Second person is frequently awkward there. The generic label is the thing being avoided. Nothing stated this before, and this template's own `AGENTS.md` carried four instances of the label against six of "the developer" for the same person, two of them two lines apart.

**Where "user" is a term in the project's own subject matter, reserve it for that meaning and say "the developer" for the person.** In anything concerning authorization, identity, accounts, or access, the word already names the party whose access is controlled. An instruction like "let the user decide" then parses as a claim about the domain, and a reader cannot recover which was meant. Found inherited near-verbatim from this template into an authorization service's own `AGENTS.md`.

**Assertion alone loses here, which is why the wording of the rule matters more than usual.** An agent's operating context uses the generic label constantly, at a priority that outranks every repository file. A convention forbidding a phrase that the surrounding context repeats cannot win by being correct.

**Only half of this is checkable, and the unenforced half is where it actually fails.** Persisted files are greppable, so `testing/scripts/check-consistency.sh` lists occurrences in the template for review rather than failing, since describing the person to a third party is legitimate and no check can tell the two apart. Conversational replies are not greppable at all. So the listing covers the case that was mostly fine already, and the case that broke has no mechanism; see `docs/deterministic-by-design.md` § When no honest proxy exists.

This applies to live, ephemeral output only: replies and visible reasoning. It does not apply to persisted, checked-in content: `AGENTS.md` § Critical constraints ("Name code, not people") already requires the opposite there (attribute to features and systems, not individuals), regardless of how well the person's name is known in conversation. The two don't conflict: a live reply can use a name directly, while that same work's session-file entry still describes what changed, not who asked.

## Copy the shape, not the surface

**A model handed to you as a correction carries its author's incidental habits alongside the structure worth taking.** Adopt the structure and inspect everything else against the standing rules, because the two arrive together and only one of them was the point.

**The tell: run the mechanical checks on the result of a copy, not on your own writing only.** An incidental rides in on the authority of the structure, so the dash count, the spelling pass and the property ordering apply to adopted text exactly as they do to written text, and the moment of adoption is the moment they are least likely to be run. A non-zero dash count in a passage you did not compose is the observable form of this defect.

**The reason it is hard to catch is that a correction carries authority, and authority suppresses inspection of its incidentals.** You accept the shape because it is better, and the habits ride in behind the thing you were right to accept. Supplied by the session that hit it: a developer's rewrite of one of its review comments was structurally better and contained "in favor" against a standing Canadian-spelling rule, and the draft copied from it inherited the spelling along with the structure.

**This rule does not reach a relational property, and reaching for it there wastes the attempt.** It works because an incidental rides along *inside* the thing you copied, so inspecting what you took can find it. Position, ordering, adjacency and precedence are not inside anything: they are relations to neighbours, so they come from where you put the copy rather than from the copy. Told to inspect the incidentals, you would look at the copied artifact and find nothing wrong, because the frame contains nothing to inspect. Supplied by the session that had misfiled its own instance here and then worked out why the remedy could not have helped it.

**Spelling is the visible instance of an invisible class.** Dashes, capitalization, terminology, the generic third-person label for the developer, and any other project decision are all carried the same way. Applies to any offered exemplar, not only a developer's: a peer's sample, an upstream document, a snippet from a linked issue.

## Prose is a serialization, and the reader has to reverse it

**The asymmetry to design around: for a language model the verbalization is the process, and for a person it is a byproduct of one.** People have an inner voice, but it reports on layers operating in understanding rather than in words, so a sentence is what surfaced rather than what happened. Nothing symmetrical holds for a model, whose visible token stream is where the work occurs. Writer and reader are therefore not running the same operation in opposite directions.

**So prose is native output for one side and a lossy import format for the other.** Content with a shape, a comparison, a mapping, a hierarchy, a set of parallel items, gets flattened into a line on the way out, and the reader rebuilds the shape on the way in. Good writing does not avoid this. It makes the flattening pleasant, and a four-way relationship explained in an elegant paragraph is still a four-way relationship to reassemble.

**The test is whether the content has structure other than a line.** If it does, emit the structure: a table, a list, a diagram. If it does not, and an argument, a causal chain or a single claim with its support genuinely does not, prose fits and a table would impose a shape the content lacks. This is a question of fit, so neither form is the fallback and neither is the reward for good behaviour.

**Trigger on item count, not on topic.** An earlier form of this guidance keyed on subject matter, naming design decisions and trade-offs, which let findings, status reports and lists of changes through untouched; the observed result was a developer asking for a list after nearly every long answer, across sessions and projects. More than one discrete item is the signal, whatever they concern. Two items already carry a relationship between them, and a line loses that relationship first. The threshold was set at roughly three by the writer before the developer corrected it to one, which is this section's asymmetry occurring inside it: a reader who pays the decompression cost knows where it starts, and a writer guessing at it will guess high.

**Fluency is free to produce and costly to consume, which is why the trigger has to be mechanical.** A model emits confident, well-formed paragraphs at no marginal effort, so volume never feels expensive from the writing side and the cost lands entirely on the reader. Judgement applied by the writer is judgement applied by the party not paying.

**This is not the Density rule restated.** Density asks how much is packed into a sentence. This asks whether a sentence is the right container at all, and the two fail independently: a perfectly unpacked paragraph can still be the wrong shape for what it carries.

## Say what changed, not how you got there

**Default to succinct in anything actionable: a code comment, a commit message, a review comment, a draft for the developer, or any document, including design documents, roadmaps and indexes.** It is the default already, stated separately in three files in three wordings, and it kept failing because a reader writing a commit message did not think a rule about "any entry" was addressed to them. One statement, here, because this file is read for every kind of output.

**Procedural narration is the specific thing to cut, and it is the most tempting thing to write** because it is what you have just finished doing and it feels like the substance. Process is: how you found it, what you tried and abandoned, which session or review surfaced it, the *act* of verifying, and the artifact's own edit history. **"What you verified" is the act, not the fact it established**, and the two read alike in this list while pulling opposite ways: that you checked the docs is process, while what the docs say is usually the finding's premise. When the list and the test above disagree, the test wins. None of it survives contact with a reader who arrives later wanting to act.

**Naming who agreed is attribution and it goes; naming what a claim rests on may be either.** The developer's instruction is the shape of it: refrain from "agreed with X session" or from dates like "corrected on 2026-08-30", and where something is genuinely needed, "in accordance with Usher's model design" is better. **Reference the thing, never the conversation.** Three constructs look alike here and only some should go, which is the distinction that stops one sweep under-removing and the next over-removing:

- **Attribution** credits an edit or names who concurred. It goes.
- **Sourcing** names where a claim came from. It goes once the claim is verified where it now sits.
- **A confidence declaration** records that a claim is *not* verified here, as in "read from their document rather than their code". **It stays.** Deleting one silently promotes second-hand to first-hand, and a sweep hunting attributions will find it looks identical.

**A correction whose referent never existed is worse than the noise it was trying to remove.** "An earlier note implied X", "this was recorded as Y", "an earlier version of this rule said Z", where the document never said it. The referent is a turn in a conversation: the error was made there, corrected there, and the correction then written into the file as though the file had held it. **No reader can resolve it**, because the superseded claim exists nowhere in the corpus or its history. The mechanism is that a correction arrives in conversation while the file is what gets edited in response, so the file feels like where it belongs; the developer's correction and the document's history are different records, and a reader can open only one of them.

**Two properties make this survive diligence, and the second is why it needs a rule.** A file's own history frequently cannot supply the referent, because the correction often arrives in the same commit that creates or first touches the text, so looking at what the file used to say returns nothing. And **a `git log -S` on a phantom claim returns the same empty result as an unverifiable one**, which reads as "cannot confirm" and gets moved past. That emptiness is the finding, and nothing about it says so, so the diligent act produces something indistinguishable from a dead end.

**A release discipline that amends until publication guarantees this for same-batch revisions.** Where intermediate states are never committed, a rule revised twice within one batch has only its final form in history, so "an earlier version said" written about that revision points at something that will never exist. Confirmed here: a tie-breaking rule carries that phrasing, and the diff that introduced it shows the correction on **both** sides, with the rule being corrected appearing in no commit at all.

**The check is mechanical, which most of this file's rules are not.** Grep for `was recorded as`, `was described as`, `an earlier note`, `earlier reading`, `previously stated`, `an earlier version`. For each hit, grep the corpus for the claim being corrected and run `git log -S` on it. Nothing in either means the referent is phantom: **state the fact positively and delete the correction**, and where the superseded claim genuinely matters, cite where it lives rather than gesturing at it. Grep locates and verification decides, and the reporter's own judgement was wrong on a third of their hits before they ran the verification.

**For dates, ask whether it stamps the world or the document.** "Checked against the running cluster on 2026-08-14" records when something was observed and stays. "Corrected on 2026-08-30" is the artifact's own edit history and goes.

**This outranks tidiness because attribution lands on the stalest content.** A line saying another session agreed reads as settled, so nobody re-reads it. Reported from a sweep across five files where the defects clustered in sections marked Resolved or carrying a session attribution: one was a contract table whose three prescriptions were all downstream of a premise since corrected, agreed to by a session working from that same wrong premise. The attribution is what kept anyone from looking.

**The test is what the reader does next.** They need what is true now and what to do about it. "Originally thought the cause was X, then found Y" is one fact wearing the costume of two. **The exemption is a scope test, not a permission, and it asks what the reader came for.** Where someone came for the sequence of events, the sequence is the content: a changelog, a post-mortem, a runbook, a migration guide, a tutorial. Where they came for the current state, it is not: a design document, API documentation, a README, a code comment. An earlier version of this clause exempted "a design record", which contradicted the scope sentence above naming design documents, and a session landed in the gap between the two within hours of reading both.

**Keep the because, drop the used-to-think.** The noise and the value usually arrive in the same sentence, so a rule that says delete the history takes the reason out with it. "An earlier version of this section said a startup check would cover it. That was wrong, because Y" carries one fact a reader needs, which is that a startup check does not cover the case. That the document once claimed otherwise is in git. Three outcomes rather than one, because a blanket cut strips real content: **keep** decision rationale, since why a tool was not adopted explains the design's shape and is not process narration; **restate** a warning wearing revision history as clothing, so that "we thought X would work" becomes "X does not work, because Y" and the hazard survives without the frame; **cut** pure edit history.

**The self-referential clause is the most recognizable tell.** A passage ending "which is the failure this document's own review discipline warns about" is the document talking to itself in front of the reader. If you want one thing to scan for, scan for the document referring to its own process.

**In a code comment the same thing looks different enough to slip past a rule written about prose.** It appears as "we used to do X but that broke, so now we do Y", or "changed this to fix #123". The current-state form is "Y, because X breaks when Z", which also stops decaying the moment the referenced ticket system moves.

**This bites harder in documentation than in an entry.** An entry is read once, near the moment it describes. A design document is read by someone deciding how to build against it, much later, and every sentence of revision history is one they must read and discard before reaching the content. A published document's audience has no relationship to the project's editing history at all: one such file currently tells external readers what a previous draft of itself said.

**Shortness is the consequence, not the instruction.** Cutting until claims fuse trades a long artifact for a misleading one; see § Density, which pulls the other way and is applied second.

## One derivation, one owner

**When two artifacts ship together and both could carry the same reasoning, one owns it and the other points at it.** Not the accumulation `code-style.md` § Comments describes, which needs rounds to build up: this happens at a single instant, a commit body and a changelog entry written together, each fully re-deriving the same explanation. § Say what changed does not reach it, because that rule cuts by category and the duplicated reasoning is usually substantive and worth reading. Its only defect is being in the second-best of two places.

**The owner is decided by where the reader stands on their path, not by what kind of artifact it is.** Readers notice a change, orient, then act on it; one still triaging needs enough to decide whether to look further, one already acting needs the derivation. The later stage owns it. **Posture is relative rather than absolute**: the same changelog entry is the later stage against a commit body and the earlier stage against a migration guide, and both at once, because a path is ordered. Asking per artifact class asks at the wrong grain, and manufactures a limit that is not there.

**Compress, never delete.** The earlier artifact keeps enough to stand alone for its own stage. Reported by the SQON session, from a commit whose body re-derived reasoning that its own changelog entries already carried in full: what shipped kept "(a `not`'s children are independently negated)", enough to make the diff intelligible to someone reading only the log, while the derivation lived once.

**Two conditions bound it.** The owning artifact has to exist and be reachable when the earlier reader arrives, which is why a paging alert cannot compress against an incident writeup authored afterward. And two artifacts at the same stage fall outside this rule entirely: that is plain duplication, governed by § Say it once, where the remedy is deletion rather than compression.

## Write for zero required inferences, not for brevity

Scoped to output a human reads once while scanning, a review comment above all. It qualifies the succinctness default above rather than competing with it, and it is placed here because a reader applying that default is exactly who needs this next.

**Cutting words is an improvement only when the cut removes ornament.** Cutting a reasoning step makes the text shorter and the reader's job harder, which is the opposite trade. The first draft was rejected for ornament and dashes. The rewrite cut 520 words to 407 by removing four connective steps, each one established by the writer and then left out, and was rejected as **"reads like half of the comment requires mind reading... perhaps it's too succinct?"** The accepted version was 264 words with those steps restored. **Length went down, then up, then stayed flat**, which is why word count is the wrong target and why the middle draft was shorter and worse.

Three things reliably cost the reader an inference and are worth checking for by name:

- **A pronoun or a positional referent.** "it", "here", "this one", "just below". Name the thing instead: "just below this block", "remove `SqonCombinationSchema` from". § Density's *no pointers across distance* covers the same defect at document scale; this is its sentence-scale form, where the referent is one clause away and the reader still has to go and get it.
- **A conclusion without the step under it.** If you checked something to reach a claim, give what the check established. "This throws" is weaker than "`safeParse` is documented never to throw, so a caller who wrapped it the way the docs say still crashes."
- **A contrast left to adjacency.** Two sentences side by side do not announce that the second qualifies the first. Say so, or restructure.

**This is not licence to pad, and the first draft is the proof**: it was longer than the accepted version and worse. Ornament and reasoning are both words and only one is worth the reader's time. The test is per sentence: does removing it make the reader work out something you already know? If not, cut it.

**It does not loosen the terser bars elsewhere.** Session files, entry formats and commit bodies are written for an already-oriented reader and keep their own limits.

## Backwards-syntax clauses

**Do not describe a noun with a clause that has its own noun subject.** "The records a category marks" puts two noun phrases in a row before the verb, so the reader has to hold both and wait to learn how they relate. The noun comes first and the verb acting on it comes last. Adding "that" does not fix it, since the order is the problem.

**It is worst when the verb can also be read as a noun.** "A category marks" reads first as "category marks", a compound, and the reader has to back out when the sentence fails. Verbs like `marks`, `holds`, `grants`, `covers`, `names` and `records` do this.

**Rewrite so the noun comes after what describes it.** Try a possessive first, since it is usually shortest: "their grants", "the record's category". Otherwise use a participle, "records marked by a category", or a compound, "category-marked records".

**A personal-pronoun subject is fine.** "The code it covers" stacks nothing, because a pronoun cannot join the noun before it. A quantifier pronoun is not fine: "the one category nothing marks" misleads just as a noun subject does. Keep a backwards clause only where no rewrite exists or where it is quoted.

## Density

Write so the first read is enough. **Human-facing content only**, and the boundary is load-bearing rather than a caveat.

**The test for scope is who reads the file to make a decision, and it is not a directory test.** An earlier draft of this section split by path and was wrong in the way that matters: the document that prompted the whole rule was `.dev/docs/atlas/roadmap/doc-reconciliation.md`, and a path rule exempts it.

| Category | Examples | Rule |
| --- | --- | --- |
| Human-facing | `README`, `DEVELOPMENT`, `/docs`, PR and commit text, review findings, anything said in chat | Density applies |
| Agent-facing instructions | `AGENTS.md`, `CLAUDE.md`, `copilot-instructions.md`, the convention files | Condensed. Context economy wins |
| Working docs both read | `.dev/roadmap.md`, `.dev/tech-debt.md`, `.dev/docs/` | Human rule: a person reads these to decide something |

**The asymmetry decides the working-docs row.** An agent reading a longer document spends context budget, which has slack and can be recovered by summarizing. A person reading a condensed one pays a cost they cannot delegate. So where both read, the human rule wins.

**Note that `.dev/` spans two rows.** `roadmap.md` follows the human rule; session logs are condensed. The directory tells you nothing; the question is always whether a person reads it to decide.

**Exempting agent-facing docs from Density does not exempt them from everything: brevity is licensed, ambiguity is not.** The replacement rule is **condense freely, but never to a pointer that has to be reconstructed.** Reported with the incident that produced it: a reference table named two query operators without describing what either emitted, so the names described each other. That is cheap in tokens and expensive in misinterpretation, and the reader reached for the wrong operator. Had it shipped, an authorization filter would have returned records it was written to withhold. **The human failure mode here is frustration; the agent failure mode is confident misreading, which is worse and quieter.**

**Applying Density itself to agent-facing text would make things worse, not merely be unnecessary.** Unpacking a dense convention inflates a file that every adopter loads on every session, so the reader who gains nothing pays the whole cost. One convention in this repo grew from 18KB to 41KB in a single day of legitimate additions; that is where this rule would push all of them.

**One practice here is not scoped, because it is not about density at all: one claim per sentence.** If a sentence carries a claim and its qualification, split it. Split, do not drop; the qualification was load-bearing or nobody would have written it. This applies to agent-facing text too, and the reason it escapes the scope rule is that its cost is accuracy rather than comprehension. Density makes a reader work harder. A merged claim makes them read something unasserted.

**It is also free, which is why the inflation argument does not reach it.** Separating two claims adds a full stop, not words: "Superseded, and this is the one that matters: empty combinations are no longer fail-secure" becomes "Superseded. Empty combinations are no longer fail-secure." Shorter, and the priority judgement that was riding along for free is now either stated deliberately or gone.

**It has no mechanical proxy, and placement substitutes for one.** Density is checked by sentence length; this is not a length problem, and a fused sentence can be short. The example above is twelve words. So in condensed files the only writing rule still in force is the unmeasurable one, which is the "easy to agree with and ignore" failure arriving by another route. The answer is where it lives rather than a weak check: it is restated in `entry-formats.md` § One entry states one thing, read while composing an entry rather than once at session start. Proxies considered and rejected, because each produces enough false positives to train a reader to skip the output: a colon followed by a judgement clause, the strings "and this is" or "which is the", and a sentence carrying both a status word and a priority word.

**It matters most where prose is thinnest.** A doubled claim in a terse entry is harder to spot than in flowing prose, because nothing around it contradicts the smuggled half. Session logs are the sharpest case: they are what a future reader consults specifically to find out what was decided, so **a merged claim there becomes a decision never made.**

**Mixed-audience artifacts resolve toward the person.** A commit message or a CHANGELOG entry is read by both, and only one of them is slowed down by density, so write those for the human.

**The test: if a sentence has to be read twice, the sentence is wrong.** Not the reader. Everything below is a way of failing that test; this is the rule.

**Why this needs saying.** When you finish a piece of work you are holding all of it at once. Your prose becomes an index into that structure instead of a description of it. Names stand in for findings, pointers stand in for arguments, and a single sentence can carry a claim and its qualifications because you can see them together. The reader has none of that structure. They rebuild it sentence by sentence, and that rebuilding is work you moved onto them. You compress once. Every reader decompresses again.

This is not about reading level. Assume the reader knows more about the domain than the document requires. It is about how much work your writing makes them do to reach what you already know. Stated that way the fault is entirely the writer's, which is why it can be said plainly without condescending to anyone.

**What to do**

- **Say the thing before you name it.** "Arranger's plugin hook has no way to refuse a request" comes before "the contract incompatibility." After that, the short name is fine. Never before.
- **Specific before general.** The instance, then the pattern. Not the pattern illustrated afterward.
- **No pointers across distance.** "That arm", "the distinction above", "as noted" all assume the reader is holding what you are holding. If the referent is more than a few lines back, name it again.
- **Prefer the plainer word wherever it is exact, and stop at a defined term.** Not for the reader's benefit: a shorter word leaves less to parse and means the same thing. **The rule governs a word chosen for how it sounds, never one chosen for what it means**, and which applies is settled by asking whether the word is defined rather than by taste. Where a glossary or an external standard defines it, the plain synonym is **barred rather than merely not preferred**, however long the term and however ordinary the near-synonym looks. Taken past that line, plainness does not simplify a corpus, it adds a synonym to it.
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

**Measured against the files the table above actually covers: 86 of 572 prose sentences are over 30 words**, worst at 68. Expect the figure to move, since it tracks both the corpus and the measure, and an earlier reading of 87 of 564 predates a fix to the splitter. Those files were not exempt from this problem, and shipping the rule without saying so would have been the first thing it forbids. Two earlier drafts of this paragraph cited different numbers because the scope was still wrong, and the direction of the error is worth keeping: whenever the boundary was drawn by path it excluded the densest prose in the repository, which is `.dev/docs/` and the roadmap, and which is exactly where a person goes to decide something.

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

**Before any output leaves your control, run a mechanical check against the exact final text, and report the count.** **For a message rather than a file, write it to a scratch file first, check that, and send it.** A message cannot be checked as output, which is why this was once recorded here as impossible, and it stops being output the moment it is a file. **The scope is anything that leaves through a tool**, a peer message, a published page, a ticket body, a file, since those already pass through a payload you control and making it a file first costs one write and one command. It does not reach ordinary conversational text, which is not sent through a tool at all: drafting and then retyping it as the reply is an uncontrolled copy where the defect returns. So this converts many remembered rules into one remembered habit rather than removing the remembering, and the honest claim is **checked before sending, for things that are sent**, not checked before speaking. Reporting a count taken over files while sending a message is not an attestation about the message, so name what the count was computed over. Reporting the number is not ceremony: it is the only part of this that cannot be skipped silently, since a count you did not compute has to be invented rather than merely omitted. That matters because stating this rule explicitly has already failed to make it fire. A session holding it in two places, with the near-identical prior incident on record as the reason it exists, drafted a review reply containing two em dashes and presented it unchecked; the developer caught it after the draft had left their control. `grep -c '—\|–'` covers the two dash characters and not the other two banned forms, so it passes on text containing ` -- ` or a space-hyphen-space connector: check for all four, or run the repo's own dash check where one exists. This matters most for output with no commit hook behind it, a PR comment, a chat message, an issue reply, which is exactly where the untested forms have slipped through. Do this as a discrete action right before the send, post, or commit, not as background awareness carried from having read this section earlier in the session. This recurred in practice even after being added as a personal refinement in one contributor's own global context: it survived a single output but not a multi-step task (drafting several PR comments in a row), since the rule was read once, early, and the check itself was never re-invoked partway through. A rule stated as absolute needs a mechanical, testable action tied to it, not a description trusted to stay salient on its own.

## Spelling and language convention

[Team placeholder: configure your preferred spelling convention here. Example: Canadian English uses `-our` suffixes (colour, behaviour), `-re` suffixes (centre, fibre), `-ize` (not `-ise`), and `-yze` (analyze, paralyze; unlike the -ise/-ize split, Canadian does not diverge from American here).]

## Say it once, at the density it deserves

The same fact stated twice in different forms costs the same as stating it wrong, not incorrect, just taking up two or three times its own space: a caveat given in prose, then repeated as a bullet; a blocking condition explained, then given its own bolded status label ("trigger condition, not a start-now item") restating the same explanation a second way; a standing convention cited by name locally instead of just applied. Applies equally to `.dev/roadmap.md`, `.dev/tech-debt.md`, and session file entries: an entry that's grown a sub-section explaining its own nature, sitting beside entries that are two or three lines each, is the signal to fold that condition back into the entry's own fact, not evidence this one earned extra structure. Trusting this to happen at the moment of writing is the same fragile shape as any other unenforced judgment call: it's caught for real at `session-discipline.md`'s pre-commit re-check, the same checkpoint that catches stale entries. Same discipline as `CONTRIBUTING.md` § Design principles' succinct-wording rule (see `CHANGELOG.md` § `succinct-wording-is-a-separate-pass`), applied here to any persisted `.dev/` content rather than just convention prose.

**A test for it, since the rule above is otherwise a judgement call: try to write the pair as one sentence.** If the result is self-contradictory or absurd, the first half was carrying nothing and the second is the content. "Access is never granted over data directly. It is granted over a dataset." collapses into a sentence asserting that access is never granted over data and is granted over data, which is where the redundancy becomes visible. Where the negation is load-bearing the single sentence reads fine and keeps both halves, which is why "Usher is not an authentication service" survives it. The developer found this by attempting the rewrite, and it is worth more than the class it came from: a reviewer applies it in one motion and gets an answer, where deciding whether a negation is load-bearing has no such moment. No pattern reaches it, and a sweep for paragraph-opening negations returns 29 matches of which nearly all are content.

## Deliver the point first, because generative order is backwards

**The reader should not have to hold unresolved scaffolding until the payload arrives.** Four shapes, all the same defect: a count before the items, a pointer before the fact, an abstraction standing in for a thing not yet stated plainly, a denial before the claim. "A dataset also lists the kinds of approval it requires, and each of those kinds is a category" makes a reader construct the object and then learn what it is called. Repaired, it reads "A dataset can also carry extra requirements, and each one is called a category."

**The mechanism is why this recurs rather than occurring occasionally.** Reasoning runs context, then qualification, then conclusion. Writing the traversal down puts the conclusion last, and **a reader needs it first, because the conclusion is what makes the context interpretable.** So generative order and comprehension order are opposites, and transcribing your own thinking produces the wrong one by default. This is the same asymmetry as compressing once while every reader decompresses again, on a different axis: there it is density, here it is sequence.

**And it is invisible from the inside.** The writer already holds the conclusion, so the scaffolding reads as build-up rather than as burden. An instruction to write clearly cannot reach it, because the prose already seems clear to whoever produced it.

**The test: delete the opening clause or sentence and ask whether the paragraph lost anything.** If what follows still delivers the point, the deleted part was scaffolding. Across a 68-paragraph document this flagged 11 candidates and confirmed 4, so treat it as a candidate-raiser at roughly one in three.

**The boundary, and why the test is the test.** Setup is legitimate where the conclusion would be **unintelligible** without it, not merely unsurprising. Required setup leaves the paragraph broken when removed, which is exactly what the deletion check detects.

**Repairs are mechanical once the shape is named**: items before their count, claim before support, fact before denying the alternative, and the substance before the label, which is § Density's *say the thing before you name it* and is not restated here. An earlier version of this line read "name before describing" and inverted that rule outright, including against the worked example above, whose repair puts the requirement before the word `category`.

**Several smaller classes are children of this one rather than siblings**, which matters because a taxonomy of them is larger than the defect. A qualifier carrying an argument before the argument exists is one: "the second question deserves a single answer" rests its weight on *single* with nothing yet establishing why one beats several, and the repair is to state the reason and let the qualifier follow, since **softening the qualifier removes the symptom and keeps the defect**. A sentence whose subject is the document's own contents rather than its domain is another, and so is a pre-emptive contrast against an alternative never held, where the denial displaces the content the sentence existed to deliver.

## Vocabulary drifts in two directions and conventions only watch one

**Overload is one word carrying several senses; synonymy is several words carrying one.** The repair for the first is to split or reserve, and for the second to flatten. Writing guidance almost always addresses the first, and **the second is commoner in a corpus written incrementally**, because each new document reaches for a slightly different word and nothing notices. Measured across nine design documents by the session reporting this: seven words for the entity making a request, four for the thing being protected, four for what someone may do, four for the thing that narrows a query. None of it was decided.

**The diagnostic for synonymy: if what the word attaches to already carries the distinction, the second word is redundant.** Their worked example is the repair they were about to get wrong. Finding one term used two ways, they read it as overload and proposed coining a second term to separate the senses. The developer pointed out the two were layers of one vocabulary, and that "the role's capabilities" and "the grant's capabilities" already name which layer. **The possessive was doing the work a new noun was about to be hired for.** A tell worth knowing: they had written the correct entry earlier in the same session and argued themselves out of it, because the wrong reading had a count behind it and a count reads as evidence in a way prose does not.

**The repair for one direction produces the other, which is the failure to expect rather than a coincidence.** Moving senses off an overloaded word is right up to the defined one and wrong past it: the reporter of this pair did exactly that within an hour of stating the plain-word rule, sweeping a defined term along with two genuine plain senses, after which one file named the object plainly and another used the defined term. Two words for one thing, produced by the fix for one word with two meanings. **So the overload repair stops where a definition starts**, and a word reached for because it sounds substantial is the one most likely to collect senses in the first place: in their corpus one such word had reached four, two of which a plain synonym covered without ceremony.

**A rule that looks greppable and is not gets enforced backwards.** A fixed list of offenders is checkable, and whether a word is a defined term is not, so the check that matters here is a glossary lookup rather than a pattern. Say so where the rule is stated, because a pattern adopted for a rule it cannot decide will flag the defined terms it was meant to protect.

**The boundary, without which flattening destroys real distinctions: reserve a term for a distinction that recurs, and use a clause for one that is real but rare.** They split a concept into three terms, for a decision, the record of it, and the resulting state. All three separations are genuine, and neither divergent case occurs in the first release. Three terms for two edge cases made a rare separation look structural, and every reader then had to learn a three-tier scheme to use a word they already knew. The repair was one term and one sentence naming each exception. The test is whether a reader meets the distinction often enough to need a handle for it.

## Borrowing a register from a domain that is not the topic

**A register is the idiom of a field, and borrowing one imports the meaning its home field supplies rather than meaning the document has earned.** This is not jargon and is harder to catch than jargon, because jargon announces itself: a reader who does not know a term knows they do not know it. A borrowed register reads as competent writing about the subject at hand. Two forms recur, they fail differently, and only one of them is greppable.

**The derivational register reads as ordinary English and inverts.** It is the idiom of mathematics and formal philosophy: "the constraint falls out of the theory", "what this buys", "the decision turns on", "trivially", "by construction". A design document is premise, mechanism, consequence, so it sits one step from writing about derivations, which makes this the easiest register to slip into and the hardest to see from inside. A reader without the idiom takes "falls out of" for the opposite of what was meant, and "turns on" for activates, which in a document about access enforcement is worse than meaningless. **A phrase that silently means the opposite is more dangerous than one that means nothing**, because nothing about it prompts a second look. Write "follows from", "what this gives", "depends on", and say why in words.

**The borrowed-authority register reads as precise and claims obligations the work has not implemented.** Legal and medical idiom in a document about data model design is the recurring instance: "consent", "waiver", "governs", "pursuant to", "diagnosis", "chronic". These are not vague words, which is the problem. They are defined terms in a regulated field, and using one loosely asserts everything its home domain attaches to it. A boolean column described as "consent" is read by anyone from that field as informed consent, with revocation, documentation and withdrawal rights behind it, none of which the column implements. **The stake is highest exactly where the domain is adjacent**: a document about health data will be read by people for whom these words carry duties, so a loose use is not a style lapse but a claim of compliance.

**The discriminator is the topic, not the word.** "Consent" describing consent policy is the correct word and the only correct word. "Consent" describing a nullable timestamp borrows. So the test is to read the sentence as a practitioner of the borrowed domain would read it, with every consequence that domain attaches, and ask whether it is still true. Where it is not, either implement what the word promises or name the mechanism instead.

**Only the first form is checkable, and the second is not checkable at all.** `check-consistency.sh` raises derivational candidates and cannot decide them, since whether the phrase replaces a reason or summarizes a stated one is a judgement and a trailing-clause test for it catches a minority of instances. The borrowed-authority form defeats a pattern outright, because its words are ordinary English elsewhere in the same file and are frequently the right word in the very document under review. **A rule with no pattern is not a weaker rule here, it is a rule whose check is a reader**, and saying so is what stops someone adopting a pattern that would flag the correct uses along with the borrowed ones.

## Writing as though the reader can see your context

**The sentence is grammatical, confident, and coherent to whoever wrote it, and something it depends on is in the writer's context rather than in the reader's text.** The writer resolves it instantly. The reader cannot, and often cannot tell what is missing, because nothing looks wrong.

**The cost is not a wasted exchange, it is what the reader concludes about themselves.** The developer, after one such sentence: *"I generally assume you just speak in ways my dumb less educated brain struggles to comprehend. good for me to be made aware of."* § Density already records that needing to ask for something to be simplified is itself the defect. This is what follows: a reader who meets enough of these stops asking and starts treating confusion as their own failing, at a rate they cannot audit.

**It lands hardest in conversation rather than in documents**, because a reader can re-read an artifact at their own pace and cannot scroll back through the writer's context, and because asking costs them something each time.

Three tells, each checkable by someone who does not know the subject:

- **A reference whose referent is in a previous turn.** "The audit taxonomy is missing two of the four" where the four were named in the message before. The test is whether a definite article or a number can be resolved from **this** message alone.
- **A slot noun with no container.** "The item", where a roadmap, an atlas file, a to-discuss list and a checklist all have items. The word names a position rather than a thing, and more than one collection has positions by that name. Same for entry, section, note, decision, question.
- **A phrase whose disambiguator lives in the writer's head.** "Refuse new grants on an ungoverned category" was read as blocking people from using grants; it meant blocking the creation of new ones. The test is a sentence carrying an object where a person should be: "grant access to a collaborator" is clear, "grant access through a category" is not.

Two further sub-classes were reported with these and are already covered: a count standing in for the items is § Deliver the point first, and a term of art used before it is defined is § Density's *say the thing before you name it*.

**A reference by position into something that can be reordered is a latent falsehood, and it costs nothing until it does.** "The third row", "the second bullet", "the section above" are all correct when written and become silently wrong once the structure is edited, with nothing to catch the change. This is a different cost class from an unresolvable reference, which taxes a reader immediately: **a reader-cost rule passes straight over this one**, because today it reads perfectly. Name what the position currently holds instead, since a name cannot rot. Reported against this file, which said "the asymmetry decides the third row" while pointing into a table directly above it; one instance across the corpus, found by the first grep, so treat that as a test of the pattern rather than a sweep.
