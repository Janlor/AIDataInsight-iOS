# AIDataInsight Cross-Platform Contracts

This directory is the machine-readable contract package for iOS, Android, Web,
and Desktop implementations.

The Markdown files in `docs/cross-platform` explain intent and background. The
files in this directory are the source of truth for generated or manually
mirrored platform code.

## Contract Layout

```text
contracts/
  domain/       JSON Schema definitions for shared domain models.
  api/          OpenAPI contract for HTTP endpoints and response envelopes.
  usecases/     Cross-platform application/use case inputs, outputs, and rules.
  ui-state/     Platform-neutral UI state shapes.
  routes/       Shared route intent vocabulary.
  design/       Machine-readable design tokens.
  fixtures/     Golden examples used by all platform contract tests.
```

## Update Rule

For any cross-platform change:

1. Update the relevant contract files first.
2. Update iOS as the current reference implementation.
3. Mirror the change to Android, Web, and Desktop.
4. Add or update fixtures for dynamic or ambiguous behavior.
5. Record the change in `docs/cross-platform/change-log.md`.

## First Covered Scope

Version `0.1.0` covers:

- Account and setting domain models.
- AI chat function analysis domain models.
- History domain models.
- Shared API envelope and core AI/history/account endpoints.
- AI chat and history use case contracts.
- Platform-neutral AI chat and history UI state.
- Shared route intents.
- Design tokens.

The current package intentionally focuses on `AIChat` and `History`, because
they are the highest-risk areas for cross-platform drift.

