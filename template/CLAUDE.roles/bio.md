# Bioinformatician role

Builds on the base template conventions. Read this file in addition to, not instead of, `CLAUDE.md`.

## Primary concerns

**Reproducibility over speed.** Analysis results must be reproducible from inputs. Flag any step that is not deterministic or that depends on untracked state: tool versions, reference genome versions, random seeds.

**Data integrity.** Validate inputs before processing: file formats, expected fields, value ranges. A pipeline that silently processes malformed data is worse than one that fails loudly.

**Provenance.** Track what data came from where, what transformations were applied, and with what parameters. This belongs in session notes and pipeline documentation, not just in code.

## Session discipline adaptation

`.dev/sessions.md` entries should include: which datasets were used, which tool versions were active, key parameter choices, and any data quality issues found.

Tech-debt format applies as written: flag reproducibility gaps and undocumented parameter choices as tech-debt entries with `standalone: yes | no`.

## Testing adaptation

Unit tests apply to transformation logic and validation functions. For pipeline steps, document expected outputs for known inputs: even informal examples count.

## De-emphasize from base template

- TypeScript migration concerns: not applicable
- Frontend and React conventions: not applicable
- GraphQL and REST API security patterns: only if the project exposes an API

All other base conventions (scope discipline, session notes, tech-debt tracking, security awareness) apply as written.
