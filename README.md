# homebrew-unsigned

A personal Homebrew tap for packages that are no longer eligible for the official Homebrew repositories because their upstream releases do not pass the macOS Gatekeeper requirements enforced by Homebrew.

## Purpose

This tap preserves convenient Homebrew installation and update workflows for selected third-party software whose upstream developers continue to publish releases but do not provide binaries that satisfy Homebrew's Gatekeeper requirements.

Packages in this tap continue to download artifacts directly from their original upstream sources.

This repository does **not** mirror, modify, re-sign, or redistribute upstream application binaries.

## Security model

This tap deliberately packages software that may not pass macOS Gatekeeper checks.

Where explicitly enabled for a package, the tap may remove the `com.apple.quarantine` attribute from the installed application after Homebrew has downloaded and verified the artifact against the checksum recorded in the cask.

Automated updates verify upstream provenance, release assets, checksums, Homebrew metadata, code-signing state, and Gatekeeper status before changes can be merged.

Updates are submitted as pull requests and require manual review before merging.

## Automated updates

Package updates are checked automatically once per day.

For packages with automatic updates enabled in `packages.yml`, the update workflow:

1. runs Homebrew `livecheck` to detect a newer upstream release;
2. uses Homebrew's official bump tooling to update the package definition;
3. verifies that only the expected package recipe was modified;
4. creates a dedicated `autobump/...` branch;
5. opens a pull request against `main`;
6. runs the repository validation and security checks.

Automatic update pull requests are never merged automatically.

The `main` branch is protected by a repository ruleset requiring the following checks to pass before merging:

- `validate`
- `security`

The security workflow records the installed application's code-signing and Gatekeeper state and verifies package-specific expectations such as quarantine removal.

If an upstream release starts passing Gatekeeper checks, the workflow reports that condition for maintainer review rather than automatically removing the package from this tap.

## Maintainer setup

The update workflow uses GitHub's standard `GITHUB_TOKEN` with read-only repository permissions for normal workflow operations.

Creating an update branch and pull request requires a separate fine-grained personal access token so that the resulting pull request triggers the normal `pull_request` validation workflow.

Create a fine-grained personal access token with access limited to this repository and the following repository permissions:

- **Contents:** Read and write
- **Pull requests:** Read and write

Store the token as the following GitHub Actions repository secret:

```text
HOMEBREW_UPDATE_TOKEN
```

The token is exposed only to the workflow step responsible for pushing the update branch and creating the pull request.

The token should have an expiration date and must be replaced before or after expiry for automated updates to continue working.

Repository configuration also requires:

- a branch ruleset protecting `main`;
- pull requests required before merging;
- required status checks `validate` and `security`;
- force pushes blocked;
- automatic deletion of merged pull-request branches enabled.

A future improvement may replace the maintainer personal access token with a repository-scoped GitHub App, providing a dedicated bot identity and short-lived credentials.

## Installation

Packages can be installed using their fully qualified Homebrew name:

```sh
brew install --cask fabiocaseri/unsigned/exifcleaner
```

## Packages

<!-- PACKAGES:START -->

| Package | Type | Upstream | Status |
| --- | --- | --- | --- |
| ExifCleaner | Cask | szTheory/exifcleaner | Maintained |

<!-- PACKAGES:END -->

This table will be generated automatically from the repository metadata.

## Licensing

The source code, Homebrew package definitions, metadata and automation contained in this repository are licensed under the BSD 2-Clause License unless otherwise noted.

Third-party software installed through this tap remains subject to its own upstream license and copyright terms.

No upstream application binaries are distributed by this repository.

## Disclaimer

This is an independent third-party Homebrew tap. It is not affiliated with or endorsed by Homebrew or by the upstream projects represented here.

Users remain responsible for deciding whether they trust the software and upstream sources they install.
