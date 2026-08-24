# homebrew-unsigned

A personal Homebrew tap for packages that are no longer eligible for the official Homebrew repositories because their upstream releases do not pass the macOS Gatekeeper requirements enforced by Homebrew.

## Purpose

This tap preserves convenient Homebrew installation and update workflows for selected third-party software whose upstream developers continue to publish releases but do not provide binaries that satisfy Homebrew's Gatekeeper requirements.

Packages in this tap continue to download artifacts directly from their original upstream sources.

This repository does **not** mirror, modify, re-sign, or redistribute upstream application binaries.

## Security model

This tap deliberately packages software that may not pass macOS Gatekeeper checks.

Where explicitly enabled for a package, the tap may remove the `com.apple.quarantine` attribute from the installed application after Homebrew has downloaded and verified the artifact against the checksum recorded in the cask.

Automated updates are intended to verify upstream provenance, release assets, checksums, Homebrew metadata, code-signing state, and Gatekeeper status before changes can be merged.

Updates are submitted as pull requests and require manual review before merging.

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
