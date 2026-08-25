# AGENTS.md

Guidance for AI coding agents and humans working in this repository. `CLAUDE.md` is a symlink to this file.

## Project overview

`homebrew-unsigned` is a personal Homebrew tap for selected third-party packages whose upstream releases do not pass the macOS Gatekeeper requirements enforced by Homebrew.

The repository exists to preserve a convenient Homebrew installation and update workflow without taking ownership of upstream binaries.

Repository layout:

- `Casks/` — Homebrew cask definitions
- `Formula/` — Homebrew formula definitions, when present
- `packages.yml` — declarative package metadata and update policy
- `scripts/` — repository validation, documentation, and maintainer helpers
- `.github/workflows/` — validation, security checks, and automated update workflows
- `docs/` — maintainer runbooks and operational documentation

Read the surrounding files and the relevant README sections before making changes.

## Non-negotiable invariants

### Upstream binaries

This repository must not:

- mirror upstream binaries;
- modify upstream binaries;
- re-sign upstream binaries;
- redistribute upstream binaries.

Recipes must download artifacts directly from their original upstream sources.

Compatibility handling such as quarantine removal must operate only on installed artifacts and must remain narrowly scoped.

### Homebrew provenance

Recipes imported from official Homebrew must preserve their provenance in `packages.yml`:

- original Homebrew tap;
- exact source commit.

If the upstream Homebrew recipe was disabled because of Gatekeeper, retain the historical declaration as a comment in the imported recipe:

```ruby
# Upstream Homebrew status:
# disable! date: "YYYY-MM-DD", because: :fails_gatekeeper_check
```

Do not rewrite history to make an imported package look native to this tap.

### Source of truth

The package recipe is the source of truth for:

- download URL;
- version;
- checksums;
- Homebrew artifact declarations.

`packages.yml` is intentionally declarative metadata. Do not duplicate recipe state there unless the repository schema explicitly requires it.

### Gatekeeper handling

Only remove quarantine when `gatekeeper.dequarantine: true` is explicitly configured for that package.

Quarantine removal must be limited to the exact installed executable artifacts that require it.

Do not use:

- wildcard paths;
- recursive blanket removal;
- `xattr -cr`;
- broad directory-level dequarantine when exact artifact paths are available.

Do not automatically remove a package, disable dequarantine, re-sign an artifact, or otherwise change policy merely because an upstream release starts passing Gatekeeper. Report the change for human review.

### Automatic updates

For casks, automatic updates are allowed only when the Homebrew-generated change is limited to the accepted `version` and `sha256` fields.

Any other recipe change must stop automatic processing and require manual review.

Formula automatic update validation is intentionally fail-safe. Formula updates remain manual until a Formula-specific policy is explicitly introduced.

Never broaden automatic-update policy merely to make an update pass.

### Generated documentation

The package table in `README.md` is generated from repository metadata.

Do not hand-edit content between:

```text
<!-- PACKAGES:START -->
<!-- PACKAGES:END -->
```

Use:

```sh
ruby scripts/update-readme-packages.rb
```

and commit the generated result when metadata changes require it.

## Coding standards — Ponytail / Lazy Senior Dev

Operate in **lazy senior dev** mode: lazy means efficient, not careless. Prefer the smallest correct change and avoid creating code, abstractions, files, configuration, or infrastructure that the repository does not need.

The best code is the code never written.

Before writing code, stop at the first rung that holds:

1. **Does this need to exist?** Speculative need = skip it. YAGNI.
2. **Is it already in this repository?** Reuse the existing helper, script, pattern, Homebrew feature, or workflow.
3. **Does the language or standard library already do it?** Use it.
4. **Does the native platform or Homebrew already provide it?** Use that instead of building a parallel mechanism.
5. **Does an already-installed dependency solve it?** Use it; do not add a new dependency without a concrete need.
6. **Can it be one line or one small change?** Keep it that way.
7. **Only then:** write the minimum code that works.

Rules:

- Match the style, naming, and idioms of the surrounding files.
- Keep changes scoped to the requested concern.
- Prefer deletion over addition and boring over clever.
- Use the fewest files necessary.
- Do not introduce speculative abstractions, feature flags, schemas, frameworks, services, or configuration.
- Do not add infrastructure for a hypothetical future scale problem. Keep the repository at zero extra infrastructure until there is an actual need.
- Before adding a helper, search for an existing helper or Homebrew-native command that already covers the task.
- Do not duplicate logic merely to avoid understanding the existing implementation.
- Do not force abstractions over code that is only coincidentally similar.
- Question unnecessary complexity: if a simpler existing mechanism covers the requirement, use it.
- When two approaches are equally small, choose the one that handles edge cases correctly.
- Comments should explain constraints, intent, provenance, security decisions, or non-obvious invariants — not narrate obvious code.
- Do not leave dead code, commented-out alternatives, unused configuration, or "just in case" branches.
- If an intentional shortcut has a known ceiling, mark it with a `ponytail:` comment that names the limitation and the likely upgrade path.

### Not lazy about

Minimalism must never weaken:

- checksum verification;
- upstream provenance;
- Gatekeeper/security inspection;
- quarantine scoping;
- input validation at trust boundaries;
- error handling that prevents unsafe or ambiguous automation;
- idempotency where repository automation depends on it;
- required CI validation;
- documentation for behavior or maintainer-configuration changes.

Fail safe when automation cannot prove that a change is within policy.

## Homebrew-first implementation

Prefer Homebrew-native behavior over custom parsing or duplicated update logic whenever practical.

Examples include:

- `brew livecheck`;
- `brew audit`;
- `brew style`;
- `brew bump-cask-pr`;
- `brew bump-formula-pr`.

Custom validation is appropriate only where this repository has a narrower policy that Homebrew itself does not enforce, such as restricting an automatic cask update to version/checksum changes.

Do not replace a Homebrew-native mechanism with custom code merely for consistency or control.

## Package changes

When adding or changing a package:

- inspect the upstream source and current Homebrew conventions first;
- preserve imported Homebrew provenance where applicable;
- keep package-specific compatibility behavior inside the package recipe/metadata rather than generalizing prematurely;
- preserve cross-platform or architecture-specific recipe behavior when it exists upstream;
- keep dequarantine exact and package-specific;
- retain documentary `upstream_context` references without overstating upstream maintainer positions;
- use controlled statuses already supported by the repository rather than inventing synonyms.

Do not infer that an upstream issue being closed means the maintainer "refuses to fix" something. Preserve the actual status and documentary context.

## Repository automation and permissions

GitHub Actions is the automation engine.

Repository mutations performed by automated maintenance use the repository-scoped `fabiocaseri-automation` GitHub App and short-lived installation tokens. See [`docs/github-app.md`](docs/github-app.md).

Do not:

- reintroduce a maintainer PAT for normal automation;
- broaden the GitHub App installation to all repositories without a concrete need;
- add GitHub App permissions that the workflow does not require;
- enable automatic merging;
- weaken the `main` branch ruleset to make automation easier.

Automatic update pull requests must remain manually merged.

If authentication or permissions need to change, update the relevant runbook in the same PR.

## Maintainer workflow

Start changes from a clean, up-to-date `main` branch:

```sh
scripts/start-change.sh <branch>
```

Make the smallest focused change that satisfies the task.

Before publishing, run the checks relevant to the files changed. At minimum:

```sh
git diff --check
```

For metadata or package changes, also run the repository validators that cover the modified behavior, including generated README validation where applicable.

Publish with:

```sh
scripts/publish-change.sh "<commit message>"
```

All changes go through a pull request.

Required checks on `main` are:

- `validate`
- `security`

Do not merge until required checks pass. Do not auto-merge.

After the PR is merged, clean up locally with:

```sh
scripts/close-change.sh <branch>
```

Do not bypass these helpers without a concrete reason.

## Pull requests

Keep each PR focused on one concern.

A PR should make clear:

- what changed;
- why it changed;
- what was validated.

Avoid boilerplate descriptions when a short explanation is sufficient.

When a change affects behavior, metadata semantics, maintainer setup, security policy, or automation, update the corresponding documentation in the same PR.

Documentation must describe the implemented behavior, not a planned or hypothetical future state.

## CI and security

Treat `validate` and `security` as repository contracts, not obstacles to work around.

Do not:

- weaken checks to make a change green;
- suppress meaningful Gatekeeper/signing results;
- bypass provenance validation;
- silently accept unexpected files in an automatic update;
- convert an ambiguous update into an automatic one.

If upstream starts passing Gatekeeper, surface that condition for maintainer review.

If an automatic update produces a diff outside the accepted policy, stop and require human intervention.

## Local and sensitive data

Do not commit:

- private keys;
- tokens;
- PATs;
- credentials;
- machine-specific secrets;
- local test data that should remain private.

GitHub App credentials belong in repository Actions variables/secrets as documented in `docs/github-app.md`.

Do not copy secrets into logs, issues, pull requests, documentation, or examples.

## References

The minimalism philosophy in this file follows **Ponytail / Lazy Senior Dev**:

- https://ponytail.dev/
- https://github.com/MattFaz/actuali/pull/335
