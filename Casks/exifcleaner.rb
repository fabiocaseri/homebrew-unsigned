cask "exifcleaner" do
  arch arm: "-arm64"

  version "4.4.0"
  sha256 arm:   "78b79caddf6fe96ec39253cae27a28e6bd2877a3401b74cde6108d65344afdb5",
         intel: "909a180ec171906b2ac69506cb6dcc2db7de66c0f0f1e9d40c2b604d10c7777a"

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
