#!/usr/bin/env bash
# Renders every PNG and the .ico of the pack from the SVG and HTML sources,
# then copies what the site serves into ../public/.
# Needs only Google Chrome and macOS's sips: no ImageMagick, no SVG converter.
set -euo pipefail

cd "$(dirname "$0")"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Chrome refuses very small windows, so each SVG is rendered at 512 then scaled down.
shot() { # source width height output [background]
  "$CHROME" --headless=new --hide-scrollbars --disable-gpu \
    --default-background-color="${5:-00000000}" \
    --window-size="$2,$3" --virtual-time-budget=3000 \
    --screenshot="$4" "file://$PWD/$1" >/dev/null 2>&1
}
scale() { # input size output
  sips -z "$2" "$2" "$1" --out "$3" >/dev/null
}

shot icon.svg 512 512 icon-512.png
scale icon-512.png 192 icon-192.png

shot icon-maskable.svg 512 512 icon-maskable-512.png
# iOS rounds the corners itself: the touch icon is the full-bleed version.
scale icon-maskable-512.png 180 apple-touch-icon.png

shot favicon.svg 512 512 "$TMP/favicon-512.png"
for size in 16 32 48; do
  scale "$TMP/favicon-512.png" "$size" "$TMP/favicon-$size.png"
done
cp "$TMP/favicon-16.png" favicon-16.png
cp "$TMP/favicon-32.png" favicon-32.png
python3 -I ico.py favicon.ico "$TMP/favicon-16.png" "$TMP/favicon-32.png" "$TMP/favicon-48.png"

shot og-image.html 1200 630 og-image.png 07070bff

# What the site serves.
cp favicon.ico favicon.svg apple-touch-icon.png icon-192.png icon-512.png \
  icon-maskable-512.png site.webmanifest og-image.png ../public/
echo "brand: rendered and copied to public/"
