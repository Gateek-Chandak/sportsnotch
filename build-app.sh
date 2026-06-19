#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="Sportsnotch"
BUNDLE_ID="com.sportsnotch.app"
DIST="dist"
BUNDLE="$DIST/$APP_NAME.app"

echo "Building release binary..."
swift build -c release

echo "Building app icon..."
rm -rf "$DIST"
mkdir -p "$DIST/AppIcon.iconset"
for spec in "16 16x16" "32 16x16@2x" "32 32x32" "64 32x32@2x" "128 128x128" "256 128x128@2x" "256 256x256" "512 256x256@2x" "512 512x512"; do
    set -- $spec
    sips -z "$1" "$1" assets/icon.png --out "$DIST/AppIcon.iconset/icon_$2.png" >/dev/null
done
iconutil -c icns "$DIST/AppIcon.iconset" -o "$DIST/AppIcon.icns"

echo "Assembling $BUNDLE..."
mkdir -p "$BUNDLE/Contents/MacOS" "$BUNDLE/Contents/Resources"
cp ".build/release/App" "$BUNDLE/Contents/MacOS/$APP_NAME"
cp -R ".build/release/sportsnotch_App.bundle" "$BUNDLE/Contents/Resources/"
cp "$DIST/AppIcon.icns" "$BUNDLE/Contents/Resources/AppIcon.icns"

cat > "$BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>$APP_NAME</string>
    <key>CFBundleDisplayName</key><string>$APP_NAME</string>
    <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
    <key>CFBundleExecutable</key><string>$APP_NAME</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

echo "Zipping..."
ditto -c -k --keepParent "$BUNDLE" "$DIST/$APP_NAME.zip"

echo ""
echo "Built:   $BUNDLE"
echo "Release: $DIST/$APP_NAME.zip   (attach this to a GitHub Release)"
echo "Install: cp -R \"$BUNDLE\" /Applications/"
