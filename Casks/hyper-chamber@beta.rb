cask "hyper-chamber@beta" do
  arch arm: "aarch64", intel: "x64"

  version "1.0.0-beta.1"
  sha256 arm:   "b7f2929b9017f5b439958476e5ea18c503f8153c2773fc3a0e513391a82c456e",
         intel: "422f290972352461292f5872f879ae02db3b39354c109ee9c1fea59a5293fc16"

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
