# Security policy

## Reporting a vulnerability

Report it privately, through **Report a vulnerability** on this repository's **Security** tab. Do not open a public issue or pull request, and do not describe it in a discussion: the description is the disclosure, and it would reach every adopter before a fix exists.

Include what it affects and how to reproduce it. The report stays private until a fix is released.

## What counts here

Agentics is mostly prose, so most of what it ships cannot be exploited directly. A vulnerability here is a shipped file or instruction that leaves an adopting project less safe than it would be without it. Examples: a hook or settings file that weakens the agent's permission controls, an instruction that leads an agent to expose a credential, or a convention that tells an agent to publish something it should keep private.

## Which releases receive fixes

Agentics is pre-1.0, and only the latest release receives fixes. Adopters pin a version rather than tracking `main`, so a fixed release reaches a project only when that project upgrades. The upgrade procedure in `template/conventions/upgrading-adoption.md` checks the credential hook by behaviour before anything else, because that file is copied at adoption rather than read live.

## How a fix is disclosed

A fix for a hole that an earlier release carries ships with a security advisory on this repository, giving the affected and fixed versions, the severity, and a workaround for anyone who cannot upgrade at once. The sequence is in `template/conventions/security.md` § Releasing the fix for a hole a published release carries.
