# Roadmap

This document tracks the implementation status and planned evolution of
`homebrew-unsigned`.

The project follows a demand-driven approach: unchecked items do not
necessarily represent technical debt. Deferred work should only be implemented
when a concrete use case demonstrates that the current design is insufficient.

Completed items should end with a link to the commit that landed the change on
`main`, preferably the merge commit of the pull request that completed the
item. The link label uses the 7-character short SHA.

## Completed foundations

- [x] Add ExifCleaner and establish the initial tap structure [[89f53d1](https://github.com/fabiocaseri/homebrew-unsigned/commit/89f53d111bd282666d4bf7168b3a54cf9231b02b)]
- [x] Add the repository validation workflow [[a80e3e9](https://github.com/fabiocaseri/homebrew-unsigned/commit/a80e3e9e6d3431cd80a9c981600952c0ea2fdd1a)]
- [x] Add Gatekeeper/security checks for supported packages [[615c4b5](https://github.com/fabiocaseri/homebrew-unsigned/commit/615c4b5a1e1bc29fdbd44f57e40b2669db621070)]
- [x] Add scheduled automatic package updates using Homebrew-native tooling [[1f6987b](https://github.com/fabiocaseri/homebrew-unsigned/commit/1f6987b3a9840a5341bbce8cfca513fb7cd1a96d)]
- [x] Finalize automatic update flow with manual merge as the default [[83c0a75](https://github.com/fabiocaseri/homebrew-unsigned/commit/83c0a754a55e3da8d5cd1f524a19055e6872ebf9)]
- [x] Document maintainer setup and protected-branch expectations [[2f07a6c](https://github.com/fabiocaseri/homebrew-unsigned/commit/2f07a6c5a9718744dc852f231df870a97031aa78)]
- [x] Add `start-change.sh`, `publish-change.sh`, and `close-change.sh` maintainer helpers [[fcd09ca](https://github.com/fabiocaseri/homebrew-unsigned/commit/fcd09ca84efa31408008ddb04640d3214a19dc73)]
- [x] Generate the README package table from repository metadata [[e067d47](https://github.com/fabiocaseri/homebrew-unsigned/commit/e067d47737c6567df6458886f3bb76dda1177c91)]
- [x] Preserve historical upstream Homebrew `disable!` status in imported recipes [[d738ce8](https://github.com/fabiocaseri/homebrew-unsigned/commit/d738ce8815bb6405794176be82b4cb0b6093e037)]
- [x] Restrict automatic cask updates to the accepted `version` / `sha256` diff policy [[4f5a9a2](https://github.com/fabiocaseri/homebrew-unsigned/commit/4f5a9a260d613ddd51d7abfbcf5cf4dd96540ab4)]
- [x] Document package import, provenance, and update conventions [[b58668f](https://github.com/fabiocaseri/homebrew-unsigned/commit/b58668ff876ec9dd066537cf407d855d6adf19cd)]

## Package support

- [x] Add ImHex [[804ffcb](https://github.com/fabiocaseri/homebrew-unsigned/commit/804ffcbd809c30847c1761b2c964a216adce34c9)]
- [x] Add qBittorrent `@lt20` with manual-update handling [[0ddb93a](https://github.com/fabiocaseri/homebrew-unsigned/commit/0ddb93a7685e3dee942d2106ebef2b8b17bb321d)]
- [x] Support executable binary artifacts in Gatekeeper/security inspection [[115844a](https://github.com/fabiocaseri/homebrew-unsigned/commit/115844a306d1b3a436bd5845b9b83ec8db4330c5)]
- [x] Add RAR with multi-architecture checksums and binary artifact handling [[0a99766](https://github.com/fabiocaseri/homebrew-unsigned/commit/0a99766723f3a06ed1454c295ccc776c4384fbff)]
- [x] Add documentary Gatekeeper `upstream_context` metadata [[c8c07cb](https://github.com/fabiocaseri/homebrew-unsigned/commit/c8c07cb70e4874337401067ce85202f00907d064)]
- [x] Show Gatekeeper context in the generated README package table [[bb0ced9](https://github.com/fabiocaseri/homebrew-unsigned/commit/bb0ced9364e88063011b27afbaf770c6bada44b1)]

## Automation and maintenance

- [x] Monitor packages configured for manual updates and open/update maintainer issues [[ae2ea7c](https://github.com/fabiocaseri/homebrew-unsigned/commit/ae2ea7ca310d7bf5ab7d4452963ab62a79dba15c)]
- [x] Add direct upstream release links to manual-update issues where a release template is available [[7522a91](https://github.com/fabiocaseri/homebrew-unsigned/commit/7522a919fa4a9611f8c27bf4d27da6781abe4a6c)]
- [x] Keep Formula automatic updates fail-safe/manual until a Formula-specific policy is defined [[4f5a9a2](https://github.com/fabiocaseri/homebrew-unsigned/commit/4f5a9a260d613ddd51d7abfbcf5cf4dd96540ab4)]
- [x] Warn for maintainer review if an upstream release starts passing Gatekeeper instead of changing policy automatically [[115844a](https://github.com/fabiocaseri/homebrew-unsigned/commit/115844a306d1b3a436bd5845b9b83ec8db4330c5)]

## GitHub App automation

- [x] Replace the long-lived maintainer PAT with the private `fabiocaseri-automation` GitHub App [[91722d1](https://github.com/fabiocaseri/homebrew-unsigned/commit/91722d1def10ff277ba1962b722fb79660eccb1c)]
- [x] Use short-lived installation tokens and the dedicated `fabiocaseri-automation[bot]` identity [[91722d1](https://github.com/fabiocaseri/homebrew-unsigned/commit/91722d1def10ff277ba1962b722fb79660eccb1c)]
- [x] Document registration, installation, permissions, rotation, verification, cleanup, and recovery in `docs/github-app.md` [[91722d1](https://github.com/fabiocaseri/homebrew-unsigned/commit/91722d1def10ff277ba1962b722fb79660eccb1c)]
- [x] Remove workflow dependence on `HOMEBREW_UPDATE_TOKEN` [[91722d1](https://github.com/fabiocaseri/homebrew-unsigned/commit/91722d1def10ff277ba1962b722fb79660eccb1c)]

## Agent and development guidance

- [x] Add `AGENTS.md` with repository invariants, maintainer workflow, Homebrew-first rules, and Ponytail / Lazy Senior Dev guidance [[53498a8](https://github.com/fabiocaseri/homebrew-unsigned/commit/53498a8a90b7959eac8856999d74fcd13d8bfa72)]
- [x] Add `CLAUDE.md` as a symlink to `AGENTS.md` so agent guidance has a single source of truth [[53498a8](https://github.com/fabiocaseri/homebrew-unsigned/commit/53498a8a90b7959eac8856999d74fcd13d8bfa72)]

## Current phase — Real-world observation

The core repository architecture is considered stable. The current focus is
validating the automation against real upstream releases before adding more
infrastructure or broadening update policies.

- [ ] Observe the first real automatic package update detected by the scheduled workflow
- [ ] Verify that `fabiocaseri-automation[bot]` creates the autobump branch, commit, and pull request
- [ ] Verify that a pull request created with the GitHub App installation token triggers the expected `pull_request` validation workflow
- [ ] Verify the first real multi-architecture automatic update, especially RAR
- [ ] Verify the first real automatic update of ExifCleaner or ImHex
- [ ] Observe the first real manual-update notification and confirm that the issue is created or refreshed by `fabiocaseri-automation[bot]`
- [ ] Confirm that repeated scheduled runs remain idempotent when an update PR or manual-update issue already exists

## Backlog

### Package maintenance

- [ ] Evaluate additional Gatekeeper-disabled Homebrew packages when useful candidates are identified
- [ ] Validate that new package types fit the existing metadata and security model before extending the schema
- [ ] Add package-specific upstream context where it provides useful documentary value

### Automation

- [ ] Define a safe automatic-update policy for Formulae only when a real Formula use case requires it
- [ ] Revisit download retry handling only if transient upstream failures become recurrent
- [ ] Revisit package-specific update handling only when the current generic workflow proves insufficient

### GitHub App

- [ ] Consider installing `fabiocaseri-automation` on other personal repositories when a concrete automation use case appears
- [ ] Keep GitHub App permissions at the minimum required scope when new automation is added

## Deferred / trigger-based work

These items are intentionally not scheduled. They should be implemented only
when a concrete use case demonstrates that the current design is insufficient.

- [ ] Formula automatic updates
- [ ] Custom retry/backoff infrastructure for upstream downloads
- [ ] Additional GitHub App infrastructure such as webhooks or an external runtime
- [ ] More complex package metadata abstractions
- [ ] Additional CI or release automation
