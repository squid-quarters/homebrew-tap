# Squid Quarters Homebrew tap

Homebrew installers for [Squid Quarters](https://github.com/squid-quarters) applications.

## Hyper Chamber

[Hyper Chamber](https://squid-quarters.github.io/hyper-chamber/) is a fighting-game practice reference with visual inputs, short replays and personal notes.

```sh
brew install --cask squid-quarters/tap/hyper-chamber
```

Use a current Homebrew release. The fully qualified command adds this tap and trusts only the named cask, rather than every package in the tap. Homebrew selects the Apple Silicon or Intel download and checks its SHA-256 before installation.

The app requires **macOS 13.5 or later**. It is ad-hoc signed, not Apple-notarized. macOS may ask you to approve it under **System Settings → Privacy & Security** before opening it. See [Apple’s instructions](https://support.apple.com/102445). The cask leaves macOS security checks in place.

To update or remove the app:

```sh
brew update
brew upgrade --cask squid-quarters/tap/hyper-chamber
brew uninstall --cask squid-quarters/tap/hyper-chamber
```

Uninstalling either cask removes the application; it keeps your library, content packs, notes and preferences. There is no automatic data cleanup or `zap` stanza.

### Switching from the beta

Quit Hyper Chamber first; closing its window keeps it running. Remove the beta cask before installing the stable one, since both install `Hyper Chamber.app`:

```sh
brew uninstall --cask squid-quarters/tap/hyper-chamber@beta
brew install --cask squid-quarters/tap/hyper-chamber
```

The stable app opens your existing library. The beta cask remains available for beta releases and will not switch you to stable automatically:

```sh
brew install --cask squid-quarters/tap/hyper-chamber@beta
```

## Maintaining the casks

All cask changes go through a pull request. Keep each version tied to a published [Hyper Chamber release](https://github.com/squid-quarters/hyper-chamber/releases), with architecture-specific SHA-256 values. Check both DMG downloads against that release’s checksum manifest before changing a recipe.

Run `make check` for Ruby syntax, Homebrew style and an offline audit of both casks. These checks load the fully qualified casks, so this checkout must be registered as `squid-quarters/tap` in Homebrew; CI registers its checkout automatically. `make audit-online` additionally checks the published URLs, metadata and application minimum macOS version. Gatekeeper/notarization acceptance is separate: this third-party tap is not a submission to Homebrew’s official cask repository.

CI also installs the beta into an isolated application folder, removes it, then installs and removes stable 1.0.0 on Apple Silicon and Intel runners. It verifies the application version, identifier, architecture, signature and quarantine, and checks that settings and a sample SQLite library survive both removals. This test never launches the application; its owned test data is cleaned up afterward.

The stable cask follows the latest published stable release. The prerelease audit allowlist applies only to the explicitly named beta cask, whose livecheck selects published, non-draft beta releases. The app has no in-app automatic updater; Homebrew upgrades replace the app bundle independently of your library.
