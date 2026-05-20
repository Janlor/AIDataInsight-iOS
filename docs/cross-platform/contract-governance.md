# Contract Governance

This repository is currently a monorepo, but contracts are organized so they can
be split into a standalone contracts repository later.

## Files

- `docs/cross-platform/contracts/contract-manifest.yaml`
  Current contract version, migration index, app alignment files, and check commands.
- `docs/cross-platform/contracts/migrations/*.yaml`
  Versioned migration records. Each migration states affected apps, required
  actions, recommended read set, and acceptance criteria.
- `app-*/contract-alignment.json`
  Per-app consumed contract version and pending migration state.
- `scripts/check-contract-alignment.sh`
  Local check for drift between the current contract package and each app.

## Change Flow

1. Update machine-readable contracts first.
2. Add or update fixtures when behavior changes.
3. Add a migration file.
4. Update `contract-manifest.yaml`.
5. Update explanatory docs only where needed.
6. Apply migration to affected apps.
7. Update each app's `contract-alignment.json`.
8. Run alignment checks and target tests.

## Version Policy

- Patch version: wording, metadata, fixtures that do not change behavior.
- Minor version: backward-compatible additions or stronger implementation rules.
- Major version: breaking changes to API, models, use cases, layout semantics, or
  persistence behavior.

## Future Multi-Repo Shape

The future company-scale layout can be:

```text
aidatainsight-contracts
aidatainsight-ios
aidatainsight-android
aidatainsight-web
aidatainsight-harmony
aidatainsight-apple
```

The contracts repository would publish `contractVersion`. Each app repository
would keep its own `contract-alignment.json` and upgrade on its release cadence.
Teams only need the contracts repository plus their own app repository.
