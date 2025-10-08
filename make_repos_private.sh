#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./make-org-repos-private.sh ORG_NAME [--dry-run] [--skip-forks] [--skip-archived] [--yes] [--parallel N]
#
# Example:
#   ./make-org-repos-private.sh scraper-bots --dry-run
#
ORG_NAME="${1:-}"
if [[ -z "$ORG_NAME" ]]; then
  echo "Usage: $0 ORG_NAME [--dry-run] [--skip-forks] [--skip-archived] [--yes] [--parallel N]"
  exit 2
fi

# Defaults
DRY_RUN=false
SKIP_FORKS=false
SKIP_ARCHIVED=false
AUTO_YES=false
PARALLEL=1   # set >1 to use xargs parallelism (optional)

# Parse optional flags
shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --skip-forks) SKIP_FORKS=true; shift ;;
    --skip-archived) SKIP_ARCHIVED=true; shift ;;
    --yes|-y) AUTO_YES=true; shift ;;
    --parallel)
      shift
      PARALLEL="${1:-1}"
      shift
      ;;
    *) echo "Unknown option: $1"; exit 2 ;;
  esac
done

# Preconditions
if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: GitHub CLI 'gh' is not installed or not in PATH."
  exit 3
fi

# Check auth
if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: gh CLI not authenticated. Run 'gh auth login' or set a token in GH_TOKEN."
  exit 4
fi

TMP_LOG="$(mktemp "/tmp/make-private.${ORG_NAME}.XXXXXX.log")"
FAILURES=()
SUCCESSES=()
SKIPPED=()

echo "Listing repositories for organization: $ORG_NAME"
# fetch name, visibility, archived, fork -> output tab-separated lines
repo_list_cmd=(gh repo list "$ORG_NAME" --limit 10000 --json name,visibility,archived,fork --jq -r '.[] | [.name, .visibility, (.archived|tostring), (.fork|tostring)] | @tsv')
mapfile -t REPOS < <("${repo_list_cmd[@]}")

if [[ "${#REPOS[@]}" -eq 0 ]]; then
  echo "No repositories returned for organization '$ORG_NAME'. Exiting."
  rm -f "$TMP_LOG"
  exit 0
fi

# Prepare changes list (filter according to flags)
TO_CHANGE=()
for line in "${REPOS[@]}"; do
  IFS=$'\t' read -r name visibility archived fork <<<"$line"
  if [[ "$visibility" == "private" ]]; then
    SKIPPED+=("$name (already private)")
    continue
  fi
  if [[ "$SKIP_ARCHIVED" == "true" && "$archived" == "true" ]]; then
    SKIPPED+=("$name (archived)")
    continue
  fi
  if [[ "$SKIP_FORKS" == "true" && "$fork" == "true" ]]; then
    SKIPPED+=("$name (fork)")
    continue
  fi
  TO_CHANGE+=("$name")
done

echo "Repositories considered for change: ${#TO_CHANGE[@]}"
if [[ ${#TO_CHANGE[@]} -gt 0 ]]; then
  printf '%s\n' "${TO_CHANGE[@]}" | sed 's/^/  - /'
fi

if [[ "${DRY_RUN}" == "true" ]]; then
  echo "[DRY RUN] No changes will be made. Exiting after list."
  [[ -s "$TMP_LOG" ]] && cat "$TMP_LOG"
  exit 0
fi

if [[ "${AUTO_YES}" != "true" ]]; then
  read -r -p "Proceed to set ${#TO_CHANGE[@]} repos to private? Type 'yes' to continue: " ans
  if [[ "$ans" != "yes" ]]; then
    echo "Aborted by user."
    exit 0
  fi
fi

# Function to change a single repo; logs and collects results
change_one() {
  local repo_name="$1"
  if gh repo edit "${ORG_NAME}/${repo_name}" --visibility private >/dev/null 2>&1; then
    echo "SUCCESS: ${repo_name}" >>"$TMP_LOG"
    printf '%s\n' "$repo_name" >> /tmp/make-private-successes.txt
  else
    echo "FAIL: ${repo_name}" >>"$TMP_LOG"
    printf '%s\n' "$repo_name" >> /tmp/make-private-failures.txt
  fi
}

# If PARALLEL > 1, use xargs to run in parallel; otherwise sequential
if [[ "$PARALLEL" -gt 1 ]]; then
  printf '%s\n' "${TO_CHANGE[@]}" | xargs -n1 -P "$PARALLEL" -I{} bash -c 'change_one "$@"' _ {}
else
  for r in "${TO_CHANGE[@]}"; do
    if change_one "$r"; then
      SUCCESSES+=("$r")
    else
      FAILURES+=("$r")
    fi
  done
fi

# Summarize results
echo
echo "=== SUMMARY ==="
echo "Total repos processed: ${#TO_CHANGE[@]}"
if [[ -f /tmp/make-private-successes.txt ]]; then
  echo "Succeeded:"
  sed -n '1,200p' /tmp/make-private-successes.txt | sed 's/^/  - /'
fi
if [[ -f /tmp/make-private-failures.txt ]]; then
  echo "Failed:"
  sed -n '1,200p' /tmp/make-private-failures.txt | sed 's/^/  - /'
fi
if [[ "${#SKIPPED[@]}" -gt 0 ]]; then
  echo "Skipped (${#SKIPPED[@]}):"
  printf '%s\n' "${SKIPPED[@]}" | sed 's/^/  - /'
fi

rm -f "$TMP_LOG" /tmp/make-private-successes.txt /tmp/make-private-failures.txt
echo "Done."
