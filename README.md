# Make Organization Repositories Private

A safe, auditable, and configurable toolset (Bash script + usage patterns) to change the visibility of all repositories in a GitHub organization to **private**. This repository contains a production-ready Bash script with safety checks, filters, dry-run support, logging and a summary report — intended for organization administrators who need to migrate multiple repositories to private visibility.

---

## Table of contents

* [Overview](#overview)
* [When to use this tool](#when-to-use-this-tool)
* [Important considerations & warnings](#important-considerations--warnings)
* [Features](#features)
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)

  * [Basic example](#basic-example)
  * [Flags and options](#flags-and-options)
  * [Dry-run example](#dry-run-example)
  * [Non-interactive automation example (CI)](#non-interactive-automation-example-ci)
* [How it works (implementation notes)](#how-it-works-implementation-notes)
* [Logging, audit and outputs](#logging-audit-and-outputs)
* [Troubleshooting & common errors](#troubleshooting--common-errors)
* [Security & permissions](#security--permissions)
* [Extending the tool](#extending-the-tool)
* [Contribution guidelines](#contribution-guidelines)
* [License](#license)
* [Changelog (suggested)](#changelog-suggested)

---

# Overview

This project provides a robust, carefully-considered Bash script that uses the GitHub CLI (`gh`) to iterate all repositories in an organization and set their visibility to `private`. It implements safety mechanisms (dry-run, skip archived/forked repos, interactive confirmation), error handling and a summary of results for audit purposes.

The intended audience is organization administrators and site reliability engineers who need a repeatable, auditable procedure for changing repository visibility at scale.

---

# When to use this tool

* You plan to change many repositories' visibility from `public` to `private`.
* You need a controlled, auditable approach that can be tested (dry-run) before executing.
* You want to skip archived or forked repositories by policy.
* You require a script that checks `gh` auth and reports successes/failures clearly.

---

# Important considerations & warnings

**READ THIS BEFORE RUNNING**

* Changing repository visibility is destructive with respect to public accessibility: any anonymous/public consumers lose access immediately once the change completes.
* GitHub Pages, public forks, CI integrations, mirrors, or third-party webhooks may stop working or change behavior when a repo becomes private.
* The account or token executing the script **must** have admin privileges on each repository (organization owner or repo admin). Without correct privileges, the change will fail.
* Organization policies or enterprise-level settings may prevent changing repo visibility. The script will surface permission errors but cannot bypass organization policy.
* Always run with `--dry-run` first and test on a single low-risk repository before making bulk changes in production.
* Keep an audit log and notify stakeholders prior to running.

---

# Features

* Dry-run mode to preview changes without applying them
* Skip archived repositories and forks (optional)
* Interactive confirmation (or `--yes` to skip prompt)
* Optional parallelism for faster execution (`--parallel N`)
* Authentication and precondition checks
* Per-repo success/failure logging and final summary
* Safe shell flags (`set -euo pipefail`) and minimal dependencies (only `gh` required)

---

# Requirements

* `gh` (GitHub CLI) installed and available in `PATH` (tested with `gh` v2+)
* Network access to GitHub (api.github.com)
* An authenticated `gh` session or environment variable `GITHUB_TOKEN` / `GH_TOKEN` with appropriate scopes

  * Token scopes required: `repo` (for private repos) and `admin:org` or organization repo admin rights depending on your org policy
* Bash (POSIX-compatible; `bash` recommended)
* Optional: `xargs` for parallel execution (standard on most Unix systems)

---

# Installation

Clone this repository (or copy script file) into a safe administrative workstation:

```bash
git clone https://github.com/your-org/make-org-repos-private.git
cd make-org-repos-private
chmod +x make-org-repos-private.sh
```

**Note:** Replace `https://github.com/your-org/...` with your own location or copy the single script file into your administration host.

---

# Usage

The script is intentionally self-contained and offers a number of options to reduce risk of accidental mass changes.

## Basic example

Run a dry-run first to see which repositories *would* be changed:

```bash
./make-org-repos-private.sh scraper-bots --dry-run
```

If the output looks correct, proceed interactively:

```bash
./make-org-repos-private.sh scraper-bots
# You will be asked to type 'yes' to confirm before changes are applied
```

## Flags and options

```
Usage: ./make-org-repos-private.sh ORG_NAME [--dry-run] [--skip-forks] [--skip-archived] [--yes] [--parallel N]

Options:
  --dry-run         List repositories that would be changed, but make no changes.
  --skip-forks      Skip repositories that are forks.
  --skip-archived   Skip archived repositories.
  --yes, -y         Skip interactive confirmation (use with caution).
  --parallel N      Run N changes in parallel (useful for many repos; default: 1).
```

## Dry-run example

```bash
./make-org-repos-private.sh scraper-bots --dry-run --skip-forks --skip-archived
```

Output will be a list of repositories that would be changed and a summary count. No repositories are modified.

## Non-interactive automation example (CI)

> Use with extreme caution. Ensure the token used has the correct scopes and is stored securely.

```bash
export GITHUB_TOKEN="${CI_GITHUB_TOKEN}"   # secure secret in CI environment
./make-org-repos-private.sh scraper-bots --skip-forks --skip-archived --yes --parallel 4
```

---

# How it works (implementation notes)

* The script uses `gh repo list "$ORG" --limit 10000 --json name,visibility,archived,fork --jq -r '... @tsv'` to fetch metadata in one request (minimizes repeated network calls).
* It filters out repos that are already private or match skip rules (`archived`, `fork`).
* Optionally runs changes in parallel using `xargs -P` when `--parallel` is selected (recommended to tune to avoid rate limiting).
* Each repository change is performed with `gh repo edit ORG/NAME --visibility private`.
* Successes and failures are logged to temporary files and printed in a final summary for audit.

---

# Logging, audit and outputs

* The script writes per-run success/failure lists to `/tmp/make-private-successes.txt` and `/tmp/make-private-failures.txt` (these paths can be adapted in the script).
* A final summary lists:

  * Total processed
  * Succeeded repos
  * Failed repos (with error messages if present)
  * Skipped repos (already private, archived, fork)
* For strict audit requirements you should:

  * Modify the script to append a CSV/JSON entry to a secure location (S3, R2, or internal storage).
  * Tag each run with a run ID and operator identity (the operator who executed the script) — you can pick this up from `gh auth status` or an env var.

---

# Troubleshooting & common errors

* **`gh` not found**: Install GitHub CLI (`https://cli.github.com/`) and ensure it is in `PATH`.
* **Authentication errors**: Run `gh auth login` or ensure `GITHUB_TOKEN` or `GH_TOKEN` is exported and has sufficient scopes.
* **Permission denied / HTTP 403**: The token or user lacks admin privileges on one or more repos. Confirm membership & permission level.
* **Organization policy blocks changes**: Some organizations enforce policies preventing visibility changes; check with org owners or review GitHub organization policy settings.
* **Rate limiting / API errors**: Reduce parallelism, implement backoff, or add retries in the script. The script can be extended to add exponential backoff on transient HTTP errors.
* **GitHub Pages broken after change**: GitHub Pages sites that were public may no longer be available — plan and notify owners in advance.

---

# Security & permissions

* Use short-lived tokens where possible and avoid storing long-lived tokens on shared machines.
* Restrict token scopes to the minimum required to perform the operation.
* Consider running this from a dedicated administrative host or ephemeral container.
* Notify repository owners and stakeholders before making changes to avoid surprise outages.
* Record who executed the script, when, and what the results were.

---

# Extending the tool

Possible improvements (ideas for contributions):

* Export results to a signed CSV or JSON for audit compliance.
* Add retry logic with exponential backoff for transient API failures.
* Add rate-limit awareness (inspect GitHub headers and throttle).
* Add a `--restore-from-csv` mode which can revert visibility changes from a CSV (useful for rollback planning).
* Provide a Python implementation using `PyGithub` or `github3.py` for more advanced logic and better error handling.
* Add integration tests (mock `gh` responses) or a dry-run unit test harness.

---

# Contribution guidelines

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature-name`.
3. Add tests where appropriate (e.g., unit tests for helper scripts or CI verification steps).
4. Open a pull request with a clear description of the change and the reasoning behind it.
5. For any change that can affect run-time safety (flags, defaults), ensure backward compatibility and document new flags in `README`.

---

# License

This repository is provided under the **MIT License** unless otherwise specified. See `LICENSE` for full text.

```
MIT License
Copyright (c) YEAR Your Organization
Permission is hereby granted, free of charge...
```

(Replace `YEAR` and `Your Organization` as appropriate.)

---

# Changelog (suggested)

* `v1.0` — Initial production-ready script with dry-run, skip-archived, skip-forks, logging, and interactive confirmation.
* Future releases: add CSV audit export, exponential backoff, and REST API (curl) variant.

---

# Example — Full script (reference)

> The repository already includes a production-ready script with the features described in this README. See `make-org-repos-private.sh` for the canonical implementation. Below is an excerpt of example invocation and common patterns included in that script:

```bash
# Dry-run, skip forks and archived repos
./make-org-repos-private.sh scraper-bots --dry-run --skip-forks --skip-archived

# Non-interactive (use with secure token in CI):
GITHUB_TOKEN="$CI_SECRET" ./make-org-repos-private.sh scraper-bots --skip-forks --skip-archived --yes --parallel 4
```

---

# Contact & support

For questions, please open an issue in this repository and tag `admin` or `ops`. For urgent operational support, contact your organization’s GitHub administrators or SRE team and provide the run summary and logs if available.
