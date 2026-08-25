# homebrew-unsigned

A personal Homebrew tap for packages that are no longer eligible for the official Homebrew repositories because their upstream releases do not pass the macOS Gatekeeper requirements enforced by Homebrew.

## Purpose

This tap preserves convenient Homebrew installation and update workflows for selected third-party software whose upstream developers continue to publish releases but do not provide binaries that satisfy Homebrew's Gatekeeper requirements.

Packages in this tap continue to download artifacts directly from their original upstream sources.

This repository does **not** mirror, modify, re-sign, or redistribute upstream binaries.

## Security model

This tap deliberately packages software that may not pass macOS Gatekeeper checks.

Where explicitly enabled for a package, the tap may remove the `com.apple.quarantine` attribute from installed executable artifacts after Homebrew has downloaded and verified the artifact against the checksum recorded in the cask.

Automated updates verify upstream provenance, release assets, checksums, Homebrew metadata, code-signing state, and Gatekeeper status before changes can be merged.

Updates are submitted as pull requests and require manual review before merging.

## Automated updates

Package updates are checked automatically once per day.

All packages are monitored with Homebrew `livecheck`, including packages whose recipes are intentionally configured for manual updates.

If a newer version is detected for a manual-update package, the scheduled workflow opens or refreshes a GitHub issue for maintainer review without modifying the package recipe. When `update.release_url_template` is configured, the issue includes a direct link to the detected upstream release by substituting the latest version into the single `{version}` placeholder.

For packages with automatic updates enabled in `packages.yml`, the update workflow:

1. runs Homebrew `livecheck` to detect a newer upstream release;
2. uses Homebrew's official bump tooling to update the package definition;
3. verifies that only the expected package recipe was modified;
4. validates that the recipe diff is within the allowed automatic-update policy;
5. creates a dedicated `autobump/...` branch;
6. opens a pull request against `main`;
7. runs the repository validation and security checks.

Automatic update pull requests are never merged automatically.

For casks, automatic updates are currently accepted only when the Homebrew-generated diff changes the cask `version` and `sha256` fields. Any other recipe change causes the automatic update to stop for manual review.

Automatic Formula diff validation is intentionally fail-safe for now: Formula updates require manual handling until a Formula-specific automatic-update policy is defined.

The `main` branch is protected by a repository ruleset requiring the following checks to pass before merging:

- `validate`
- `security`

The security workflow records the installed executable artifacts' code-signing and Gatekeeper state and verifies package-specific expectations such as quarantine removal.

If an upstream release starts passing Gatekeeper checks, the workflow reports that condition for maintainer review rather than automatically removing the package from this tap.

## Package import conventions

Recipes imported from official Homebrew retain historical provenance in `packages.yml` through the original tap and exact source commit.

If the original Homebrew recipe was disabled because of Gatekeeper, the imported recipe keeps the original `disable!` declaration as a comment rather than deleting it completely. The standard form is:

```ruby
# Upstream Homebrew status:
# disable! date: "YYYY-MM-DD", because: :fails_gatekeeper_check
```

The commented declaration is historical metadata only and has no functional effect in this tap.

Gatekeeper metadata may also include optional `upstream_context` references to relevant upstream discussions, issues, or maintainer positions. These references are documentary context only; they do not alter installation or update behavior. Each reference records an HTTPS URL and a controlled status such as `wontfix`, `not_planned`, `open`, or `context`.

Package-specific compatibility changes, such as quarantine handling, must remain narrowly scoped and must not modify, re-sign, or otherwise alter upstream binaries.

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

| Package | Type | Upstream | Status | Gatekeeper context |
| --- | --- | --- | --- | --- |
| ExifCleaner | Cask | [szTheory/exifcleaner](https://github.com/szTheory/exifcleaner) | Maintained | [won't fix](https://github.com/szTheory/exifcleaner/issues/331) |
| ImHex | Cask | [WerWolv/ImHex](https://github.com/WerWolv/ImHex) | Maintained | [not planned](https://github.com/WerWolv/ImHex/issues/2657) |
| qBittorrent | Cask | [www.qbittorrent.org](https://www.qbittorrent.org/) | Manual updates | [open](https://github.com/qbittorrent/qBittorrent/issues/24052) · [context](https://github.com/qbittorrent/qBittorrent/issues/10085) |
| RAR Archiver | Cask | [www.rarlab.com](https://www.rarlab.com/) | Maintained | — |

<!-- PACKAGES:END -->

This table is generated automatically from the repository metadata.

## Licensing

The source code, Homebrew package definitions, metadata and automation contained in this repository are licensed under the BSD 2-Clause License unless otherwise noted.

Third-party software installed through this tap remains subject to its own upstream license and copyright terms.

No upstream application binaries are distributed by this repository.

## Disclaimer

This is an independent third-party Homebrew tap. It is not affiliated with or endorsed by Homebrew or by the upstream projects represented here.

Users remain responsible for deciding whether they trust the software and upstream sources they install.
