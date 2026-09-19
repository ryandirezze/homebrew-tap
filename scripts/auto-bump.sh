#!/usr/bin/env bash
set -euo pipefail

UPSTREAM="ryandirezze/NovaCAD-Mac"
CASK="Casks/novacad.rb"
APP="NovaCAD"

command -v curl >/dev/null || { echo "curl is required"; exit 1; }
[ -f "$CASK" ] || { echo "$CASK not found"; exit 1; }

latest_url=$(curl -fsSIL -o /dev/null -w '%{url_effective}' "https://github.com/$UPSTREAM/releases/latest")
tag="${latest_url##*/}"
version="${tag#v}"

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Latest release tag '$tag' is not a plain semantic version; skipping."
  exit 0
fi

pkg_url="https://github.com/$UPSTREAM/releases/download/$tag/$APP-$version.pkg"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

if ! curl -fsSL -o "$tmpdir/$APP.pkg" "$pkg_url"; then
  echo "Release $tag has no $APP-$version.pkg asset; skipping."
  exit 0
fi

if command -v sha256sum >/dev/null 2>&1; then
  sha=$(sha256sum "$tmpdir/$APP.pkg" | awk '{print $1}')
else
  sha=$(shasum -a 256 "$tmpdir/$APP.pkg" | awk '{print $1}')
fi

cur_version=$(sed -n 's/^  version "\(.*\)"$/\1/p' "$CASK" | head -n 1)
cur_sha=$(sed -n 's/^  sha256 "\(.*\)"$/\1/p' "$CASK" | head -n 1)

if [ "$cur_version" = "$version" ] && [ "$cur_sha" = "$sha" ]; then
  echo "Cask is already at $version ($sha); nothing to do."
  exit 0
fi

echo "Bumping $CASK: $cur_version -> $version"
sed -i.bak \
  -e "s/^  version \".*\"$/  version \"$version\"/" \
  -e "s/^  sha256 \".*\"$/  sha256 \"$sha\"/" \
  "$CASK"
rm -f "$CASK.bak"

if command -v ruby >/dev/null 2>&1; then
  ruby -c "$CASK" >/dev/null
fi

echo "Updated: version=$version sha256=$sha"
