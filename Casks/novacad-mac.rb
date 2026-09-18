cask "novacad-mac" do
  version "1.2.3"
  sha256 "b6f99298298f25a93677381965bf9c5c36c0b40a53f3570425f28e6f476f19c5"

  url "https://github.com/ryandirezze/NovaCAD-Mac/releases/download/v#{version}/NovaCAD-#{version}.pkg",
      verified: "github.com/ryandirezze/NovaCAD-Mac/"
  name "NovaCAD"
  desc "Native macOS DWG/DXF viewer, markup, and data tooling for technical drawings"
  homepage "https://github.com/ryandirezze/NovaCAD-Mac"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :sequoia"
  depends_on arch: :arm64

  pkg "NovaCAD-#{version}.pkg"

  uninstall pkgutil: "com.novacad.app"

  zap trash: [
    "~/Library/Application Support/NovaCAD",
    "~/Library/Preferences/com.novacad.app.plist",
  ]
end
