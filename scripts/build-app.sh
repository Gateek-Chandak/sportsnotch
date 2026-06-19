#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME="SportsNotch"
BUNDLE_ID="com.sportsnotch.app"
BUNDLE="$APP_NAME.app"

echo "Building release binary..."
swift build -c release

echo "Assembling $BUNDLE..."
rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS" "$BUNDLE/Contents/Resources"
cp ".build/release/App" "$BUNDLE/Contents/MacOS/$APP_NAME"
cp -R ".build/release/sportsnotch_App.bundle" "$BUNDLE/Contents/Resources/"

cat > "$BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>$APP_NAME</string>
    <key>CFBundleDisplayName</key><string>$APP_NAME</string>
    <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
    <key>CFBundleExecutable</key><string>$APP_NAME</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

echo "Built $BUNDLE"
echo "Install:  cp -R \"$BUNDLE\" /Applications/"
echo "Launch:   open \"$BUNDLE\"   (or from Spotlight once installed)"
