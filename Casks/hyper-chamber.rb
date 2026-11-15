cask "hyper-chamber" do
  arch arm: "aarch64", intel: "x64"

  version "1.0.0"
  sha256 arm:   "2246ddd2ceb98abd0fa2a8d3d4701707eb9c6d286424ea333a2092df20ea2493",
         intel: "ca52f30bbbe45298b4c77a24a3d1d24f1db793195ce5dfb0090be4eb7f8849f4"

  url "https://github.com/squid-quarters/hyper-chamber/releases/download/v#{version}/Hyper-Chamber_#{version}_#{arch}.dmg"
  name "Hyper Chamber"
  desc "Fighting-game practice references with inputs, short replays, and notes"
  homepage "https://squid-quarters.github.io/hyper-chamber/"

  livecheck do
    url :url
    strategy :github_latest
  end

  conflicts_with cask: "hyper-chamber@beta"
  depends_on macos: :ventura

  app "Hyper Chamber.app"

  caveats <<~EOS
    Hyper Chamber requires macOS 13.5 or later.
    This app is ad-hoc signed and has not been notarized by Apple.
    macOS may ask you to approve opening it in System Settings > Privacy & Security.
    Your library and practice notes are kept when you uninstall this cask.
  EOS
end
