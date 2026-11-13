# Squid Quarters Homebrew tap

Homebrew installers for [Squid Quarters](https://github.com/squid-quarters) applications.

## Hyper Chamber beta

[Hyper Chamber](https://squid-quarters.github.io/hyper-chamber/) is a fighting-game practice reference with visual inputs, short replays and personal notes. The beta cask follows its beta releases; it will not switch you to a stable release automatically.

```sh
brew install --cask squid-quarters/tap/hyper-chamber@beta
```

Use a current Homebrew release. The fully qualified command adds this tap and trusts only the named cask, rather than every package in the tap. Homebrew selects the Apple Silicon or Intel download and checks its SHA-256 before installation.

The app requires **macOS 13.5 or later**. This first beta is ad-hoc signed, not Apple-notarized. macOS may ask you to approve it under **System Settings → Privacy & Security** before opening it. See [Apple’s instructions](https://support.apple.com/102445). The cask leaves macOS security checks in place.

To update or remove the app:

```sh
brew update
brew upgrade --cask squid-quarters/tap/hyper-chamber@beta
brew uninstall --cask squid-quarters/tap/hyper-chamber@beta
```

Uninstalling the cask removes the application; it keeps your library, content packs, notes and preferences. There is no automatic data cleanup or `zap` stanza.

## Maintaining the cask

All cask changes go through a pull request. Keep each version tied to a published [Hyper Chamber beta release](https://github.com/squid-quarters/hyper-chamber/releases), with architecture-specific SHA-256 values. Check both DMG downloads against that release’s checksum manifest before changing the recipe.

Run `make check` for Ruby syntax, Homebrew style and an offline audit. These checks load the fully qualified cask, so this checkout must be registered as `squid-quarters/tap` in Homebrew; CI registers its checkout automatically. `make audit-online` additionally checks the published URLs, metadata and application minimum macOS version. Gatekeeper/notarization acceptance is separate: this third-party beta tap is not a submission to Homebrew’s official cask repository.

The prerelease audit allowlist applies only to the explicitly named beta cask. Its livecheck selects published, non-draft beta releases. The app has no in-app automatic updater; Homebrew upgrades replace the app bundle independently of your library.
