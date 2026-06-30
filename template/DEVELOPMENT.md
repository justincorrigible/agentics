# Development guide

<!-- Template placeholder: replace with your project's actual setup and development instructions -->

## Repository structure

<!-- TODO: describe the repo layout and what each top-level directory contains -->

## Prerequisites

<!-- TODO: list required tools and versions -->

## Setup

<!-- TODO: step-by-step local setup instructions -->

## Running the project

<!-- TODO: how to start the application or service locally -->

## Running tests

<!-- TODO: how to run the test suite -->

## Working documents

The `.dev/` directory contains living documents maintained alongside the codebase:

- `.dev/roadmap.md`: planned features and architectural direction; read at session start
- `.dev/tech-debt.md`: known issues, scope-adjacent problems, and deferred work
- `.dev/sessions.md`: brief session log (done, decisions, open threads)
- `.dev/docs/`: service-specific deployment notes and operational guides; indexed at `.dev/docs/index.md`; one subdirectory per service (e.g. `.dev/docs/postgres/`, `.dev/docs/kafka/`)

Read the `.dev/` files at the start of each session before beginning work. Read the relevant `docs/<service>/` guide before deploying or debugging a specific service. Update these at the end of any session that produces meaningful output.
