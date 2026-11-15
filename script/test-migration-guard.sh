#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/hyper-chamber-guard.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT
export HYPER_CHAMBER_GUARD_CALLS="$test_dir/calls"
: > "$HYPER_CHAMBER_GUARD_CALLS"

brew() {
  printf 'brew %s\n' "$*" >> "$HYPER_CHAMBER_GUARD_CALLS"
  if [[ $# == 4 && $1 == list && $2 == --cask && $3 == --versions ]]; then
    if [[ $4 == hyper-chamber@beta ]]; then
      printf 'hyper-chamber@beta 1.0.0-beta.1\n'
      return 0
    fi
    return 1
  fi
  return 97
}
mkdir() {
  printf 'data:mkdir %s\n' "$*" >> "$HYPER_CHAMBER_GUARD_CALLS"
  return 97
}
export -f brew mkdir

if CI=true GITHUB_ACTIONS=true RUNNER_ENVIRONMENT=github-hosted RUNNER_OS=macOS \
   RUNNER_TEMP="$test_dir" HYPER_CHAMBER_SMOKE_ARCH="$(uname -m)" \
   bash "$script_dir/smoke-migration.sh" > "$test_dir/output" 2>&1; then
  printf 'Expected the existing beta installation to stop the smoke test.\n' >&2
  exit 1
fi
if ! grep -Fq 'Refusing to replace an existing cask installation: squid-quarters/tap/hyper-chamber@beta' "$test_dir/output"; then
  cat "$test_dir/output" >&2
  printf 'The installed-state guard did not detect the beta token.\n' >&2
  exit 1
fi
grep -Fxq 'brew list --cask --versions hyper-chamber@beta' "$HYPER_CHAMBER_GUARD_CALLS"
if grep -Eq '^brew (install|uninstall)|^data:' "$HYPER_CHAMBER_GUARD_CALLS"; then
  printf 'The guard reached installation, removal or data creation.\n' >&2
  exit 1
fi
printf 'Existing beta detected before installation, removal or data creation.\n'
