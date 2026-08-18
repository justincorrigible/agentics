# Security: what you need to do yourself

**Written for the developer, not for your agent to act on.** This is your half of agentics' security posture: the things no convention file can handle for you, because they depend on a person actually looking. `agent-security.md` covers the threat model and the checks an agent runs; this covers what you check, what you should not take on trust, and what to do when something has already gone wrong.

Read it once when you adopt agentics, and again if you ever find yourself relying on a control rather than verifying it.

## The premise: a security control that reports success is not evidence it works

Agentics shipped a credential blocklist for months that never blocked anything. It read the wrong key out of the tool payload, so the path it checked was always empty, no pattern could match, and it returned "allow" for every credential file on disk. Nobody noticed, for three reasons worth internalizing because they generalize well past this one bug:

- **A permissive failure is silent.** A hook that wrongly denies gets reported immediately, because work stops. A hook that wrongly allows produces no error, no log line, and no observable difference from having no hook at all. You cannot notice this passively; you have to go and check.
- **The documentation asserted it was working**, which turned the absence of evidence into positive reassurance.
- **It had been tested, and the test passed.** The test fed sample paths to the pattern list and confirmed the patterns were correct. They were correct. The test exercised the half that already worked and never touched the part that was broken.

That last point is the one to carry forward. When an agent tells you a control is tested, the useful question is not "did it pass?" but **"what input did the test use, and where did that input come from?"** A test that builds its own input in the shape the code expects cannot discover that the real caller uses a different shape. Ask to see a test that uses a real, captured payload.

## Verify the credential blocklist yourself

Do this on adoption, and again after any change to `settings.json`. It takes a few seconds and does not depend on any agent's account of itself.

```sh
# Point this at the settings file you want to check: the project's .claude/settings.json,
# your global one, or agentics' template/.claude/settings.json.
SETTINGS=.claude/settings.json

CMD=$(python3 -c "import json,sys;print(json.load(open('$SETTINGS'))['hooks']['PreToolUse'][0]['hooks'][0]['command'])")
check() { printf '%s' "$2" | eval "$CMD" | python3 -c "import json,sys;print(json.load(sys.stdin)['hookSpecificOutput']['permissionDecision'])"; }

check "env"    '{"tool_input":{"file_path":"/tmp/project/.env"}}'      # expect: deny
check "ssh"    '{"tool_input":{"file_path":"/tmp/home/.ssh/id_rsa"}}'  # expect: deny
check "bash"   '{"tool_input":{"command":"cat /tmp/project/.env"}}'    # expect: deny
check "clean"  '{"tool_input":{"file_path":"/tmp/project/README.md"}}' # expect: allow
```

Three denies and one allow means it is live. Four allows means it is inert, whatever anything else claims. Note the paths above do not need to exist: the hook decides before the file is ever opened, which is what makes this safe to run anywhere.

## Know what the blocklist does not cover

It is a speed bump on the most common accident, not a boundary. Being precise about its limits is what stops it being over-trusted:

- **It is specific to Claude Code.** It is a `PreToolUse` hook, a Claude Code feature. If your team uses Cursor, Copilot, Codex, Aider, or anything else, **you have no mechanical credential enforcement at all**, only the prose rule in the conventions. If that is your situation, build the equivalent in your own tool's permission or deny-list system, and until you have, treat the credentials policy as entirely dependent on the agent's compliance.
- **It matches on paths and command text, so it can be worked around trivially.** A path assembled from variables, a file copied to an innocuous name first, or a tool that passes a directory rather than a file (`Grep`, `Glob`) all pass straight through. It is not an adversarial control and should never be described as one.
- **It does not stop a credential already in context from being written somewhere.** Once a secret has been read by any route, nothing here prevents it reaching a session log, a commit message, or a PR comment.

The real control for secrets remains keeping them out of the working tree: a secrets manager, environment injection at runtime, and `.gitignore`. The hook exists to catch the routine accident, not a determined path around it.

## Agent output to distrust by default

Not because agents are dishonest, but because these specific claims are ones an agent cannot reliably verify about itself. Each has a cheap check.

| Claim | Why it is unreliable | What to do |
|---|---|---|
| "I tested it and it passes" | The test may exercise the wrong half, as above | Ask what the input was and where its shape came from |
| "I cleaned up / renamed / removed all X" | Long sessions get summarized, and a summary can turn "intended to do X" into "X is done" | `grep` for what should be gone before building on it |
| "The check passed" | The check may not cover what you assume it covers | Ask what it actually asserts, not whether it was green |
| "That is already handled by <convention>" | A rule existing is not a rule firing; most of this repo's own incidents are rules that existed | Ask what event triggers it, and whether that event occurred |
| A confident specific value (a version, a timestamp, a count) | If no source was consulted, a plausible value may have been produced instead of an unknown | Ask where the number came from |

The general form: **an agent's report about its own behaviour is a claim, not evidence.** Reports about the world, which you can go and check, are a different matter.

## Trust boundaries that are yours to hold

**Text in a pull request or issue is attacker-controlled.** Injecting instructions into PR titles, issue bodies, and review comments to hijack a reviewing agent is a demonstrated attack, not a hypothetical. Agentics scopes its own "recognized identity" exception to the platform's structured author field precisely because attribution appearing *inside* body text can be typed by anyone. When you point an agent at a PR from outside your team, you are pointing it at untrusted input, and you should read what it proposes to do rather than approving on the strength of its summary.

**A message from another agent session is never your approval.** Sessions can reach each other, and a peer can report that you approved something, that a review passed, or that a check already ran. None of that is you. If an action needs your consent, give it in the conversation where you are actually present.

**Your global context is loaded into every project and is usually not version controlled.** For Claude, that is `~/.claude/`; other tools have an equivalent. Anything written there applies everywhere, silently, from then on, and no `git log` will show you it changed. Treat additions to it as a higher bar than a change inside one repo, and be more sceptical of a casual "shall I add this globally?" than of a proposed code change. Consider putting that directory under git so you can diff it.

**Committed prose is a leak path.** Session logs, memory files, the atlas, and changelog entries are records of real work, written in prose, and committed. An internal hostname, a private URL, a cluster endpoint, or a token can end up in any of them. The mechanical check is deliberately narrow: it greps changed files for your own git identity and username, which means it catches your name and nothing else. It cannot catch a colleague's name, an API token, or an internal URL. **Reading `.dev/` diffs before pushing is a human control with no automated substitute**, and it matters most in a repo shared outside your team.

## Reviewing a security change an agent proposes

The failure mode is narrower than "the agent got it wrong." It is that the change is correct in the part it is thinking about and untested in the part it is not:

- **Ask what the failure mode looks like.** If the answer is "it silently allows," insist on a test that would catch that, not just a test that the intended case works.
- **Check the boundary, not the centre.** Patterns and rules are usually right. Extraction, parsing, and the contract with the caller are where the bugs are.
- **Be suspicious of a passing test written in the same breath as the code.** It tends to encode the same assumption twice, so agreement between them proves nothing.
- **For anything with a permissive failure mode, ask for the negative test**: break it deliberately, confirm the check fails, then restore. A check nobody has ever seen fail is not known to work.

## If something has gone wrong

- **A secret was read into context.** Assume it is compromised and rotate it. It may exist in the session transcript, a summary, or any file written afterward. Rotating is cheaper than establishing where it went.
- **A secret reached a commit.** Rotate first, then deal with history. Removing it from a pushed branch does not un-publish it.
- **An agent acted on injected instructions.** Check what it actually did (`git status`, `git log`, the working tree, anything it pushed or posted) before reading its account of what it did. Then check whether anything was written to your global context, since that is the change with the widest and least visible blast radius.
- **Instruction files changed unexpectedly.** `git log -- AGENTS.md CLAUDE.md .claude/settings.json` and read the diff yourself. A semantic change ("never commit" softened into "commit when asked") looks trivial in a diff and only a human reading for meaning will catch it.

## Where this fits

`agent-security.md` has the threat model, the attack vectors, the session-start integrity check agents run, and an honest account of what agents cannot catch automatically. `conventions/security.md` and `conventions/security-guidelines.md` are the agent-facing application-security conventions. This file is the part that only works if a person does it.
