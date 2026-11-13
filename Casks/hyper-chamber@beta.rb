# Release checksums are placeholders; this draft must not be merged.
cask "hyper-chamber@beta" do
  arch arm: "aarch64", intel: "x64"

  version "1.0.0-beta.1"
  sha256 arm:   "0000000000000000000000000000000000000000000000000000000000000000",
         intel: "1111111111111111111111111111111111111111111111111111111111111111"

  url "https://github.com/squid-quarters/hyper-chamber/releases/download/v#{version}/Hyper-Chamber_#{version}_#{arch}.dmg"
  name "Hyper Chamber Beta"
  desc "Fighting-game practice references with inputs, short replays, and notes"
  homepage "https://squid-quarters.github.io/hyper-chamber/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+-beta\.\d+)$/i)
    strategy :github_releases do |json, regex|
      json.filter_map do |release|
        next if release["draft"]
        next unless release["prerelease"]

        release["tag_name"]&.[](regex, 1)
      end
    end
  end

  depends_on macos: :ventura

  app "Hyper Chamber.app"

  caveats <<~EOS
    Hyper Chamber requires macOS 13.5 or later.
    This beta is ad-hoc signed and has not been notarized by Apple.
    macOS may ask you to approve opening it in System Settings > Privacy & Security.
    Your library and practice notes are kept when you uninstall this cask.
  EOS
end
