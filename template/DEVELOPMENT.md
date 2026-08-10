# Development guide

<!-- Template placeholder: replace with your project's actual setup and development instructions -->

## Repository structure

<!-- TODO: describe the repo layout and what each top-level directory contains -->

## Prerequisites

<!-- TODO: list required tools and versions -->

- GitHub CLI (`gh`), authenticated: any agent working in this repo uses `gh` for PRs and issues on your behalf; without it, your first GitHub-related request will stall on an auth prompt instead of just working

## Setup

<!-- TODO: step-by-step local setup instructions -->

1. If `gh auth status` doesn't already show you logged in, run `gh auth login` once per machine.

## Running the project

<!-- TODO: how to start the application or service locally -->

## Running tests

<!-- TODO: how to run the test suite -->

## Working documents

The `.dev/` directory contains living documents maintained alongside the codebase:

- `.dev/roadmap.md`: planned features and architectural direction; read at session start
- `.dev/tech-debt.md`: known issues, scope-adjacent problems, and deferred work
- `.dev/sessions/`: one file per contributor per day (`YYYY-MM-DDTHHMMSS.md`), brief log of what changed and why
- `.dev/docs/`: service-specific deployment notes and operational guides; one subdirectory per service (e.g. `.dev/docs/postgres/`, `.dev/docs/kafka/`), each organized however this project already does that
- `.dev/docs/atlas/` (the atlas): agent-generated reference material, roadmap depth if this project has opted into the roadmap split, lessons-learned write-ups; indexed at `.dev/docs/atlas/index.md`, kept separate from the service folders above so neither needs to conform to the other's shape

Read the `.dev/` files at the start of each session before beginning work. Read the relevant `docs/<service>/` guide before deploying or debugging a specific service. Update these at the end of any session that produces meaningful output.

## Troubleshooting

Common environment-specific gotchas, full detail lives in `conventions/session-discipline.md`:

- **Your agent doesn't see a file you're actively editing.** It reads the filesystem directly and can't see unsaved editor content: save the file first, or paste it directly into the conversation instead. See § "Troubleshooting: agent doesn't see a file you're actively editing."
- **Your agent's memory doesn't follow a project after a rename or a multi-root workspace setup.** Two different failure modes, each with its own fix. See § "Troubleshooting: agent won't load, or its memory doesn't follow a project."
