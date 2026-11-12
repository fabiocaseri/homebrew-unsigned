cask "exifcleaner" do
  arch arm: "-arm64"

  version "4.8.0"
  sha256 arm:   "6a44065d6ce07e24e2d7ed31a8285fcbc6e557a694d054671b9d1839270d5555",
         intel: "dd84a7c7b4e21e179b3a7871f586663da3dc9e04a53a4eebd42a2f7c25a6511a"

  url "https://github.com/szTheory/exifcleaner/releases/download/v#{version}/ExifCleaner-#{version}#{arch}.dmg"
  name "ExifCleaner"
  desc "Metadata cleaner"
  homepage "https://exifcleaner.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Upstream Homebrew status:
  # disable! date: "2026-09-01", because: :fails_gatekeeper_check

  depends_on macos: :ventura

  app "ExifCleaner.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-dr", "com.apple.quarantine", "{{appdir}}/ExifCleaner.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.exifcleaner.sfl*",
    "~/Library/Application Support/ExifCleaner",
    "~/Library/Preferences/com.exifcleaner.plist",
    "~/Library/Saved Application State/com.exifcleaner.savedState",
  ]
end
