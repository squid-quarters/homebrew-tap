#!/usr/bin/env bash
set -euo pipefail

if [[ ${CI:-} != true || ${GITHUB_ACTIONS:-} != true ||
      ${RUNNER_ENVIRONMENT:-} != github-hosted || ${RUNNER_OS:-} != macOS ]]; then
  printf 'This installation smoke test runs only on a fresh GitHub Actions runner.\n' >&2
  exit 1
fi
if [[ -z ${RUNNER_TEMP:-} || ! -d $RUNNER_TEMP || $RUNNER_TEMP == / ]]; then
  printf 'A dedicated GitHub Actions temporary directory is required.\n' >&2
  exit 1
fi
if [[ $(uname -m) != "${HYPER_CHAMBER_SMOKE_ARCH:?Expected runner architecture is required}" ]]; then
  printf 'The runner architecture does not match its test matrix.\n' >&2
  exit 1
fi

stable_cask=squid-quarters/tap/hyper-chamber
beta_cask=squid-quarters/tap/hyper-chamber@beta
data_dir="$HOME/Library/Application Support/com.squidquarters.hyperchamber"
for cask in "$stable_cask" "$beta_cask"; do
  if brew list --cask --versions "$cask" >/dev/null 2>&1; then
    printf 'Refusing to replace an existing cask installation: %s\n' "$cask" >&2
    exit 1
  fi
done
if [[ -e $data_dir ]]; then
  printf 'Refusing to use an existing application data folder: %s\n' "$data_dir" >&2
  exit 1
fi

smoke_dir=$(mktemp -d "$RUNNER_TEMP/hyper-chamber-tap-smoke.XXXXXX")
app_dir="$smoke_dir/Applications"
created_data=false
cleanup() {
  local result=$?
  trap - EXIT
  set +e
  for cask in "$stable_cask" "$beta_cask"; do
    if brew list --cask --versions "$cask" >/dev/null 2>&1; then
      brew uninstall --cask "$cask" || result=1
    fi
  done
  if [[ $created_data == true ]]; then
    if [[ -f $data_dir/.tap-smoke-owned ]] &&
       [[ $(cat "$data_dir/.tap-smoke-owned") == "$smoke_dir" ]]; then
      rm -rf -- "$data_dir" || result=1
    elif [[ -e $data_dir ]]; then
      printf 'Retaining test data because its ownership marker changed: %s\n' "$data_dir" >&2
      result=1
    fi
  fi
  rm -rf -- "$smoke_dir" || result=1
  exit "$result"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
mkdir -p "$app_dir"

brew install --cask --appdir="$app_dir" "$beta_cask"
[[ -d "$app_dir/Hyper Chamber.app" ]]
[[ ! -e $data_dir ]]
mkdir -p "$data_dir/library"
printf '%s\n' "$smoke_dir" > "$data_dir/.tap-smoke-owned"
created_data=true
ruby -rjson -e 'File.write(ARGV[0], JSON.generate(libraryDir: ARGV[1]) + "\n")' \
  "$data_dir/settings.json" "$data_dir/library"
sqlite3 "$data_dir/library/hyper-chamber.sqlite" <<'SQL'
CREATE TABLE practice_note (body TEXT);
INSERT INTO practice_note VALUES ('Keep this note');
SQL
cp "$data_dir/settings.json" "$smoke_dir/settings.expected"
cp "$data_dir/library/hyper-chamber.sqlite" "$smoke_dir/library.expected"

assert_data_preserved() {
  cmp "$data_dir/settings.json" "$smoke_dir/settings.expected"
  cmp "$data_dir/library/hyper-chamber.sqlite" "$smoke_dir/library.expected"
}
brew uninstall --cask "$beta_cask"
[[ ! -e "$app_dir/Hyper Chamber.app" ]]
assert_data_preserved
printf 'Settings and library survived beta removal.\n'

brew install --cask --appdir="$app_dir" "$stable_cask"
bundle="$app_dir/Hyper Chamber.app"
actual_version=$(plutil -extract CFBundleShortVersionString raw -o - "$bundle/Contents/Info.plist")
actual_identifier=$(plutil -extract CFBundleIdentifier raw -o - "$bundle/Contents/Info.plist")
[[ $actual_version == 1.0.0 ]]
[[ $actual_identifier == com.squidquarters.hyperchamber ]]
[[ $(lipo -archs "$bundle/Contents/MacOS/hyper-chamber-desktop") == "$HYPER_CHAMBER_SMOKE_ARCH" ]]
codesign --verify --deep --strict "$bundle"
xattr -p com.apple.quarantine "$bundle" >/dev/null
assert_data_preserved

brew uninstall --cask "$stable_cask"
[[ ! -e $bundle ]]
assert_data_preserved
printf 'Stable 1.0.0 installed, verified and removed; settings and library survived.\n'
