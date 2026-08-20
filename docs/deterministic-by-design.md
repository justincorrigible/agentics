# Deterministic by design

Dual audience: contributors maintaining agentics, and anyone building a similar agent-instruction system elsewhere. Both readings are intentional.

An agent following a written instruction is not the same act as a compiler executing code. A rule that's true, well-written, and correctly understood can still not fire, because "the agent should do X" is a probabilistic claim, not a guarantee: it holds most of the time, then doesn't, for reasons that don't repeat cleanly enough to call a pattern. That's not a bug in any one instruction. It's what "possible" means when the thing doing the reasoning is a probabilistic process instead of a deterministic one: the same input can produce a different outcome on a different run, and you don't find out which one you got until you check.

Every incident logged in this repo's `CHANGELOG.md` under a `conventions` or `repo` category is an instance of this: a rule existed, was arguably clear, and still didn't fire at the moment it needed to. The fix each time looked like "write the rule more clearly." That helps, but it doesn't change what kind of thing is enforcing it.

What did we learn? **"stop trusting 'memory' for the parts that don't need judgment, and make the parts that do need judgment impossible to quietly skip"**

## The actual lever: reduce what depends on being remembered

Sort every rule you're tempted to add into one of three buckets, and treat each differently.

**1. Purely mechanical, no judgment required.** A pattern that either exists in a file or doesn't; a count that either matches or doesn't; a name that either appears in a diff or doesn't. Nothing about deciding whether it's a problem requires understanding intent. These should never be "remember to check this", they should be a script, wired into something that runs whether or not anyone remembers it exists (a pre-commit hook, CI, whatever your equivalent is). Documenting a mechanical check as a step in a checklist is strictly worse than automating it: it costs the same to write down, and still depends on memory to execute. `testing/scripts/check-consistency.sh` plus `.githooks/pre-commit` in this repo is this bucket, fully converted.

**2. Requires judgment, but has a clear trigger.** "Does this change actually solve the stated problem" can't be mechanized, it needs understanding. But _when_ to ask it is knowable: at review time, every time, no exceptions. The failure mode here isn't "the rule is wrong", it's "the rule lost to something that felt like a good enough reason to skip it this once": the change looked small, it was already discussed, confidence was high. The fix is naming the override explicitly: state that this check is not conditional on how the change feels, and name the specific rationalizations that don't count as an exception. `agentics_contributor`'s mandatory upstream-check tier needed exactly this (`CHANGELOG.md` § `contributor-check-explicit-override`): "run this every session" lost to a project's own complete-looking checklist until it was rephrased as "this runs _in addition to_ that checklist, even when it looks complete." A plain instruction reads as a frequency; an override has to read as a precedence.

**3. Structural: the ambiguity itself is avoidable, not just catchable.** Some failure classes don't need a check after the fact, because the pattern that causes them can be disallowed outright. A relative path with no stated base directory reads correctly from wherever it was written and incorrectly from everywhere else; that's not a rule to remember to apply, it's a shape of writing to stop producing, the same way you'd ban a footgun API instead of writing a linter for every way to misuse it. This repo's `global-guideline-material-never-in-project` incident (a dispatch table's bare relative paths, ambiguous the moment they were copied into a different project) was this bucket. The fix wasn't "review paths more carefully", it was stating explicitly, once, that this class of content is always a live pointer, never a local path, and checking for the regression of that one sentence going missing, not for every way a bad path could be written.

## A check implements a rule; it is never a source of one

When a check and the convention it enforces disagree, **the convention wins and the check is a defect**, every time. This needs saying because the instinct runs the other way: a script is concrete, it just ran, and it returned a specific complaint about a specific line, while prose sits in a file being general. Concreteness reads as authority.

**A check enforcing something undocumented is worse than an undocumented rule.** An unwritten convention at least announces its own softness when someone states it. A check states it with machine authority nobody granted, in the imperative, at the moment of action, to a reader with no easy way to tell whether the prose behind it exists.

**Never cite a script as the basis for asserting a rule to someone else.** Cite the convention, and if you cannot find the passage, that is the finding: either the rule is undocumented or the check is wrong, and both want fixing before anyone acts on it. Reported by a session that had read the relevant convention fresh that morning, then read a script later, treated it as authoritative, and asserted a rule to two other sessions that the convention never contained. Its own summary is the sharpest statement of the gap: a freshness rule governs **when** to read the convention, not **which artifact wins** when a script and a convention disagree.

**The damage is asymmetric in one direction worth naming.** A flag phrased in the imperative invites correction, so a wrong check does not merely misinform, it recruits the reader into changing correct data. In the case above, an entry that was right would have been "fixed" into an entry that was wrong, by someone doing exactly what the tool told them.

## Report the extreme next to the count, or the count cannot be audited

**A measurement artifact shows up in the extreme value and never in the count.** Two independent implementations of the same sentence-length check make the point. One merged whole bullet lists into a single 255-word "sentence", because list items carry no terminal punctuation for a splitter to break on. The other split on lines before splitting on sentences and topped out at 68 words. Both produced a plausible-looking count, and the counts alone cannot be told apart. The maximum separates them immediately, because nobody writes a 255-word sentence and no reader needs to be told so.

**So the artifact detector belongs in the summary line, since the summary line is what gets quoted.** A figure travels without its output. The peer who found the 255-word case warned that this repository's check carried the same bug, and the disproof was already published next to the number as "worst at 68", in the convention rather than in the check's own headline. It never reached them, because the count had been quoted on its own. Putting the extreme where the count is makes the figure self-auditing wherever it ends up.

**The method lesson is separate and larger than the check.** That peer had calibrated their own tool exactly this way, by printing its worst item and reading it, which is how they found the merged list at all. They then asserted the same failure in someone else's implementation without running the one command they had just used on their own. Having a technique available is not the same as turning it on yourself, and the second is the part that needs a trigger, since the first feels like enough.

## A per-item test cannot see an aggregate property

**Some defects exist only in the total, so a rule applied correctly to each item in turn will pass every one and still produce the failure.** This is not the composite case, where one artifact's parts go unexamined. Here every part is examined, each verdict is right, and the sum is wrong.

**Witnessed in code comments.** A file under four rounds of adversarial review accumulated comments narrating who found what and how it was verified. Each passed the "is the why non-obvious" test when written, because at that moment it was. Confirmed first-hand by that session rather than inferred: it checked every comment as it wrote it, and every individual verdict was sound. The accumulation read as a changelog embedded in the source, and a dedicated pass afterwards removed 17% of the file with nothing lost.

**The remedy is a separate pass at a moment the work is not moving, because no judgement made during the work can see the total.** That is the same shape as this repository's own release simplification pass, which exists because convention text accumulates the same way and no single addition ever looks like the problem. Scale differs and the mechanism does not.

**So when a rule is per-item, ask what its aggregate looks like after fifty applications.** If the answer is a defect nobody would have accepted in one step, the rule needs a pass rather than a better statement.

## Before crediting a coverage defect, check that the rule was invoked

**A rule that ran and passed and a rule nobody ran are indistinguishable from the artifact, and they want opposite fixes.** The first is a defect in the rule, which no amount of care on the reader's side reaches. The second is a lapse, and care is exactly the remedy. Since the output looks identical, anyone reconstructing what happened will pick one and be right about half the time.

**Recorded because this file got it wrong.** A session reported a four-sentence comment where one sentence was necessary, and this section credited it as a keep-or-drop test passing a composite on its strongest part. Two things were false. The reporter had never invoked the test, having judged that explanation was warranted and written freely, so nothing passed because nothing was asked. And the same convention already carried an unqualified content rule, never explain WHAT the code does, which reaches any explaining at any granularity and caught all three discarded sentences by itself.

**Only the actor can settle it, so ask rather than reconstruct.** The reconstruction was plausible, which is the problem: it was accepted, written down, and used to exonerate someone who then corrected it unprompted. The same asymmetry governs any first-hand account of an internal state, invisible from outside and decisive for who owns the fix.

**The structural claim survives; its evidence does not.** A binary keep-or-drop test on a composite cannot examine parts, so it will pass a whole on one part's merit, and that follows from the shape of the test rather than from any observation. No verified instance exists yet, because the candidate turned out to be an uninvoked rule. A real one needs a case where the per-part rules genuinely do not reach the riding-along content, which this was not. Left standing as unwitnessed rather than quietly evidenced by the case that failed to demonstrate it.

## What a convention actually costs, which is not its size

Size is the obvious measure and it misleads. Four things matter more, and they point at different files.

**Read frequency multiplies everything.** A character in a file read every session costs hundreds of times a character in one read at adoption. Agentics carries 112,000 characters in its always-read tier against 295,000 read on demand, so the smaller tier is the more expensive one. Optimise there first.

**Occupancy is a hard cost, not a soft one.** Always-read material sits in the context window for the whole session and displaces the work. On-demand material is read and can fall away. This is why the two tiers are not interchangeable at equal size.

**Every rule dilutes the others.** A file of 133 rules gives each one 132 competitors, so the marginal cost of adding one is partly paid by the rules already there. That cost is invisible in a byte count and it is the reason a corpus can be individually reasonable and collectively unusable.

**Redundancy is cheap; contradiction is not.** A restated rule wastes bytes. A rule that conflicts with another spends a decision every time both are in scope, and the reader may resolve it either way. Hunting duplication is the lower-value pass.

**The cheapest rule is one nobody reads, because a check enforces it.** Moving a rule into a script grows the repository and shrinks the cost to near zero: it fires without anyone holding it in mind. So `testing/scripts/` growing is not the same event as `session-discipline.md` growing, and a size budget that treats them alike is measuring the wrong thing.

**What follows for a pass.** Cut tier one before anything else. Prefer removing a rule to shortening it, since dilution is per-rule rather than per-character. Move what can be mechanised. Resolve conflicts before hunting restatements. And check proportion: agentics' largest file is `agent-index.md` at 14% of the corpus, documenting a capability its own opening paragraph calls optional and never a dependency.

## A rule whose test requires the judgement it produces is a restatement of the goal

**Some rules can only be applied by someone who already has the answer, and they read as instructions.** "Emit a shape only where the content has one" and "name an operation, not a property" both ask the reader to make the judgement the rule exists to produce. A reader who has understood the failure applies them correctly; a reader who has not agrees with them and carries on. That is worse than a rule going unread, because agreement feels like compliance.

**Three of one section's rules had this shape and it was invisible until its author tested them cold.** They were asked one question about a convention written from their own failures: would this wording have stopped you at the time, reading it without knowing what went wrong. Four rules failed, three of them by circularity, and none of the four looked defective to me when I wrote them.

**The fix is a proxy on something observable, not a better statement of the principle.** Each of the three had one available once the circularity was named. For operation versus property, the object of the verb rather than the verb, since both forms open with an imperative and only one takes a constraint as its object. For container fit, state the content as a sentence and keep the sentence unless it is worse. For reasoning versus derivation, the writer's own motive, since a writer can see whether they expect the reader to push back where they cannot see which category their paragraph belongs to. **In each case the proxy moved the test from the content onto something the writer can observe without having made the judgement first.**

**A paragraph that predicts how the failure feels from inside does work the rule cannot, so it goes before the rule.** The same report found that the one paragraph likely to make a reader actually run the test was positioned after the rule as justification, where it reads as support for something already accepted and gets skipped by anyone short on time. Its function is prospective rather than explanatory. Placement carries the difference, which is the same argument as moving a rule to the moment of writing.

**Testing for this needs the person who failed, before they understood why.** Nobody else holds the earlier state, and the author cannot recover it: by the time you write the rule you have the judgement, which is precisely what makes the circularity invisible.

## When no honest proxy exists, move the rule to the moment of writing

**A noisy check is not a weak version of a good one; it trains people to skip the output.** Once a reader learns that most of a check's hits are false, they stop reading all of them, including the true ones. That is a worse outcome than never having shipped it, and it damages the other checks in the same run by association.

**So when a rule has no proxy you would actually trust, place it where it fires instead of measuring it.** Reading order is a real enforcement mechanism: a rule that binds while composing an entry belongs in the file an agent opens to write one, not in a general style file read once at session start. Same reasoning that split `entry-formats.md` out of `session-discipline.md`.

**Worked case.** One-claim-per-sentence cannot be checked by length, since a fused sentence can be short. A peer session listed the candidate proxies, a colon followed by a judgement clause, the strings "and this is" or "which is the", a sentence carrying both a status and a priority word, and rejected all of them on false-positive grounds rather than shipping the least bad. The rule was restated in the file read at the keystroke instead.

**Say which you chose and why, in the convention.** A reader who sees an unchecked rule should be able to tell that the absence of a check was a decision rather than an oversight, or they will reasonably assume nobody got to it yet.

## A control whose failure looks like success is worse than no control

Mechanising a check moves it out of memory, which is the point of everything above. It also creates a failure this document has now seen three times, and it is the most expensive one available: **a control that cannot distinguish its own failure from success, sitting in the artifact whose entire job is to be checkable.**

The three, none of them predicted and each found by someone using the thing rather than reviewing it:

- **A credential hook that never fired.** It read tool parameters under key names the harness does not send, so it inspected nothing and reported nothing. Every commit passed a guard that was not running.
- **An announcement that cannot be verified.** Nothing records that one was made, the sender learns nothing about who received it, and a session that heard none cannot distinguish "never announced" from "announced, missed me".
- **A registry checker that printed a confident false claim.** It compared paths exactly, so a casing difference split one ownership tree into two, and the section reporting how many entries carve out of a root used the same comparison and answered zero. It did not fail to notice the split; it asserted the tree was intact, under a heading a reader opens precisely to verify that.

**The shape is always the same: the check runs, returns, and looks like it worked.** A control that errors is self-announcing and gets fixed. A control that silently passes accumulates trust in proportion to how long it has been wrong, and the trust is what makes it costly: nobody re-derives by hand something a green check already answered.

**So when you mechanise a check, spend the extra minute on the failure mode rather than the happy path.** Three questions, in order of how often they catch something here:

1. **Make it fail on purpose and watch it fail.** Not "does it pass on good input" but "does it flag bad input, and does the run exit non-zero". Every one of the three above passed the first test.
2. **Ask what the check silently assumes**, and whether that assumption is checkable too. Exact string comparison assumes normalised input. A hook assumes it receives the fields it reads.
3. **When any input is malformed, suppress the derived claims rather than computing them anyway.** A count derived from bad data is not a smaller truth, it is a confident falsehood, and it appears in exactly the place someone went looking for certainty.

## What this doesn't solve

Bucket 1 gets to something close to actually deterministic: either the script runs and blocks, or it doesn't exist yet. Bucket 3 gets close too, once the structural fix is in place, the ambiguity can't recur in that specific shape. Bucket 2 does not get there. An override phrased correctly reduces how often it's skipped; it does not make skipping impossible, because applying it still runs through the same probabilistic reasoning as everything else. Don't oversell it as "solved" when what actually happened is "the failure rate dropped."

## Applying this to your own system

For each existing rule: would a person or agent following it perfectly, every time, actually need to exercise judgment, or are you just hoping they remember to run a check that has one right answer? If the latter, that's bucket 1, and it should already be a script wired into something that runs automatically, not a line in a document. If a rule keeps getting silently skipped despite being clearly written, check whether it's actually bucket 2 dressed up as a plain instruction, missing the explicit override it needs. And if the same class of mistake keeps recurring in slightly different shapes no matter how the rule is reworded, ask whether the underlying pattern should be disallowed structurally instead of caught after the fact, bucket 3, not bucket 2.
