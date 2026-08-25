# GitHub App automation

This document is the maintainer runbook for the GitHub App used by this repository's automated maintenance workflow.

## Purpose

The scheduled update workflow performs two kinds of repository mutations:

- opens or refreshes issues when a package configured for manual updates has a newer upstream version;
- creates commits, `autobump/...` branches, and pull requests for packages whose automatic update policy accepts the Homebrew-generated recipe change.

These mutations use the `fabiocaseri-automation` GitHub App rather than a maintainer personal access token or the workflow's standard `GITHUB_TOKEN`.

The design goals are:

- automated activity is visibly attributed to a bot identity rather than to the maintainer;
- credentials are short-lived installation access tokens;
- the App has only the repository permissions required by the workflow;
- installation is limited to explicitly selected repositories;
- no webhook service, OAuth user authorization flow, or external runtime is required.

GitHub Actions remains the automation engine. The GitHub App provides identity and authorization only.

## Current configuration

GitHub App:

```text
fabiocaseri-automation
```

Registration scope:

```text
Only on this account
```

Repository installation scope:

```text
Only select repositories
fabiocaseri/homebrew-unsigned
```

Repository permissions:

| Permission | Access |
| --- | --- |
| Metadata | Read-only (mandatory) |
| Contents | Read and write |
| Issues | Read and write |
| Pull requests | Read and write |

All other repository, organization, account, and enterprise permissions should remain at `No access`.

The App does not use:

- callback URLs;
- OAuth user authorization during installation;
- device flow;
- a setup URL;
- webhooks.

## First-time registration

Open:

```text
GitHub account Settings
→ Developer settings
→ GitHub Apps
→ New GitHub App
```

Configure:

```text
GitHub App name:
fabiocaseri-automation

Description:
Personal repository automation for maintenance workflows and automated pull requests/issues.

Homepage URL:
https://github.com/fabiocaseri/homebrew-unsigned
```

Under user authorization:

- leave the callback URL empty;
- leave `Request user authorization (OAuth) during installation` disabled;
- leave `Enable Device Flow` disabled.

Under post-installation:

- leave the setup URL empty;
- leave redirect-on-update disabled.

Under Webhook:

- disable `Active`;
- do not configure a webhook URL or secret.

Under Repository permissions, grant only:

```text
Contents       Read and write
Issues         Read and write
Pull requests  Read and write
```

Leave all other optional permissions at `No access`.

For installation availability, select:

```text
Only on this account
```

Create the App.

## Private key

From the GitHub App settings page:

```text
Settings
→ Developer settings
→ GitHub Apps
→ fabiocaseri-automation
→ General
→ Private keys
→ Generate a private key
```

GitHub downloads a PEM file. Treat it as a credential:

- never commit it to this repository;
- never paste it into issues, pull requests, logs, or documentation;
- store it only long enough to configure or recover the Actions secret, unless a separate secure backup is intentionally maintained.

The private key itself does not get committed to the repository. GitHub Actions receives it through an encrypted repository secret.

## Install the App

From the App settings page, choose:

```text
Install App
→ fabiocaseri
→ Only select repositories
→ fabiocaseri/homebrew-unsigned
→ Install
```

After installation, verify that the installation page shows:

```text
Read access to metadata
Read and write access to code, issues, and pull requests
```

and that repository access is still limited to `fabiocaseri/homebrew-unsigned`.

If another repository needs the same automation in the future, explicitly add that repository to the installation rather than switching to `All repositories` without a concrete need.

## Repository Actions configuration

Open:

```text
fabiocaseri/homebrew-unsigned
→ Settings
→ Secrets and variables
→ Actions
```

Create the repository variable:

```text
FABIOCASERI_AUTOMATION_CLIENT_ID
```

with the GitHub App **Client ID** shown on the App's General page.

Do not use the App ID unless a future tool specifically requires it. `actions/create-github-app-token` recommends the Client ID input.

Create the encrypted repository secret:

```text
FABIOCASERI_AUTOMATION_PRIVATE_KEY
```

whose value is the complete contents of the generated PEM file, including its BEGIN/END lines.

No OAuth client secret or installation ID is required by the workflow.

## Workflow integration

`.github/workflows/update.yml` creates an installation access token with:

```yaml
- name: Create GitHub App token
  id: app-token
  uses: actions/create-github-app-token@v3
  with:
    client-id: ${{ vars.FABIOCASERI_AUTOMATION_CLIENT_ID }}
    private-key: ${{ secrets.FABIOCASERI_AUTOMATION_PRIVATE_KEY }}
    permission-contents: write
    permission-issues: write
    permission-pull-requests: write
```

With no `owner` or `repositories` input, the token is scoped to the current repository.

The action returns:

- `token` — the short-lived installation access token;
- `installation-id` — the resolved installation;
- `app-slug` — `fabiocaseri-automation`.

The token is masked by GitHub Actions and is revoked by the action's post step when the job finishes. Installation access tokens otherwise have a maximum lifetime of one hour.

The workflow intentionally keeps the standard `GITHUB_TOKEN` limited to read-only repository access. Repository mutations use only the App token.

## Bot Git identity

For automatically generated commits, the workflow resolves the App bot user's numeric GitHub user ID and configures Git as:

```text
fabiocaseri-automation[bot]
<BOT_USER_ID>+fabiocaseri-automation[bot]@users.noreply.github.com
```

The same App token is used by `gh issue`, `git push`, and `gh pr`, so automated repository activity is consistently attributable to the GitHub App.

## Verification

After changing App credentials or workflow authentication, run the `Update packages` workflow manually from the Actions tab.

A healthy run should show the `Create GitHub App token` and `Resolve GitHub App bot identity` steps succeeding for every matrix entry, even when all packages are already current.

The identity step should log a line similar to:

```text
Authenticated as fabiocaseri-automation[bot] (user id …).
```

This is a read-only authentication check and does not create an issue or pull request by itself.

When a real manual-update notification is later required, verify that its author is:

```text
fabiocaseri-automation[bot]
```

When a real automatic package update is later generated, verify that:

- the commit author/committer uses the App bot identity;
- the `autobump/...` branch is pushed successfully;
- the pull request author is `fabiocaseri-automation[bot]`;
- the normal `pull_request` workflow runs;
- required `validate` and `security` checks pass;
- the pull request is not merged automatically.

## Post-migration cleanup

Do not remove legacy credentials or relax existing safeguards until the GitHub App workflow has been merged and a manual `Update packages` run has successfully created an App token and resolved the bot identity.

After successful verification:

1. delete the legacy repository secret:

   ```text
   HOMEBREW_UPDATE_TOKEN
   ```

   from:

   ```text
   Repository
   → Settings
   → Secrets and variables
   → Actions
   ```

2. disable the repository setting:

   ```text
   Allow GitHub Actions to create and approve pull requests
   ```

   under:

   ```text
   Repository
   → Settings
   → Actions
   → General
   → Workflow permissions
   ```

The workflow no longer relies on either mechanism. Repository mutations are performed through the `fabiocaseri-automation` installation token.

## Key rotation

To rotate the App private key without interrupting automation:

1. generate a new private key from the App's General page;
2. replace the repository secret `FABIOCASERI_AUTOMATION_PRIVATE_KEY` with the new PEM contents;
3. manually run `Update packages`;
4. verify that App-token creation and bot identity resolution succeed;
5. return to the App settings and delete the old private key;
6. remove any obsolete local copy of the old PEM.

Do not delete the old key before the new secret has been verified.

## Permission changes

If workflow requirements change, add only the minimum new App permission required.

After changing a GitHub App's permissions, GitHub may require the installation owner to approve the updated permissions before the installation receives them.

Verify the effective permissions on:

```text
Account Settings
→ Applications
→ Installed GitHub Apps
→ fabiocaseri-automation
```

Do not broaden installation access to all repositories merely to resolve a permissions error.

## Adding another repository

If another repository needs this App:

1. edit the existing `fabiocaseri-automation` installation;
2. keep `Only select repositories`;
3. add the new repository explicitly;
4. configure that repository's Client ID variable and private-key secret;
5. integrate the App token into that repository's workflow;
6. verify the bot identity and required permissions there.

The same GitHub App can be reused across multiple repositories; a separate App is not required per repository.

## Recovery and removal

If the App token stops working:

1. verify that the App is still installed on the repository;
2. verify the effective installation permissions;
3. verify that `FABIOCASERI_AUTOMATION_CLIENT_ID` still matches the App's Client ID;
4. rotate `FABIOCASERI_AUTOMATION_PRIVATE_KEY`;
5. manually run `Update packages` and inspect the token/identity steps.

To disable the automation identity immediately, suspend or uninstall the App installation from the account's installed GitHub Apps settings.

Uninstalling the App revokes its repository access. It does not remove branches, issues, pull requests, or commits that the App created previously.

## References

- GitHub documentation: Creating a GitHub App  
  https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app
- GitHub documentation: Installing your own GitHub App  
  https://docs.github.com/en/apps/using-github-apps/installing-your-own-github-app
- GitHub documentation: Authenticating as a GitHub App installation  
  https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/authenticating-as-a-github-app-installation
- `actions/create-github-app-token`  
  https://github.com/actions/create-github-app-token
