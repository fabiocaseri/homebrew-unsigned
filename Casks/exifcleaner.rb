cask "exifcleaner" do
  arch arm: "-arm64"

  version "4.3.0"
  sha256 arm:   "98238e4d66cacd5b7006e1c2551ac238599b1deaf2c6399c26c3dedcd9f745d5",
         intel: "ffb4bc667d52cc5265820f43bfe6a21d3ba6f1853c4854377c6b7cba9be6a37e"

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

  depends_on macos: :monterey

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
