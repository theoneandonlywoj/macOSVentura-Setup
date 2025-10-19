#!/bin/zsh
# === Google Chrome Installer + Dock Setup for macOS Ventura (Zsh) ===
# Author: theoneandonlywoj
# Description:
#   Installs Google Chrome via Homebrew or .dmg, adds it to the Dock
#   right after Calendar, and refreshes the Dock.

echo "🌐 Google Chrome Installer + Dock Setup (macOS Ventura)"
echo "------------------------------------------------------"

# === 1. Check for admin rights ===
if [[ $EUID -ne 0 ]]; then
  echo "⚠️  Some steps may require admin privileges."
  echo "   You might be asked for your password."
fi
echo

# === 2. Check for Homebrew ===
if command -v brew >/dev/null 2>&1; then
  echo "🍺 Homebrew detected."
  echo "📦 Installing Google Chrome via Homebrew Cask..."
  brew install --cask google-chrome
  if [[ $? -eq 0 ]]; then
    echo "✅ Google Chrome installed successfully via Homebrew!"
  else
    echo "❌ Failed to install Chrome via Homebrew."
    exit 1
  fi
else
  echo "⚠️  Homebrew not found. Installing Google Chrome manually..."
  echo "⬇️  Downloading Chrome .dmg..."
  tmp_dir="/tmp/chrome_install"
  mkdir -p "$tmp_dir"
  dmg_path="$tmp_dir/GoogleChrome.dmg"

  curl -L "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" -o "$dmg_path"
  if [[ $? -ne 0 ]]; then
    echo "❌ Failed to download Chrome."
    exit 1
  fi

  echo "💿 Mounting GoogleChrome.dmg..."
  hdiutil attach "$dmg_path" -nobrowse -quiet
  sleep 2

  if [[ -d "/Volumes/Google Chrome/Google Chrome.app" ]]; then
    echo "📂 Copying Google Chrome.app to /Applications..."
    cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications/
    echo "✅ Chrome installed successfully in /Applications."
  else
    echo "❌ Google Chrome.app not found in DMG."
  fi

  echo "🧹 Cleaning up..."
  hdiutil detach "/Volumes/Google Chrome" -quiet
  rm -rf "$tmp_dir"
fi

# === 3. Verify installation ===
if [[ ! -d "/Applications/Google Chrome.app" ]]; then
  echo "❌ Chrome installation failed."
  exit 1
fi

echo
echo "🚀 Chrome installed at: /Applications/Google Chrome.app"

# === 4. Add Chrome to Dock ===
echo
echo "🧭 Adding Google Chrome to Dock..."

chrome_path="/Applications/Google Chrome.app"
calendar_path="/System/Applications/Calendar.app"

# Method 1: Use dockutil if available (best)
if command -v dockutil >/dev/null 2>&1; then
  echo "⚙️  Using dockutil to manage Dock..."
  
  # Remove existing Chrome icon if present
  dockutil --remove "Google Chrome" --no-restart >/dev/null 2>&1

  # Insert Chrome after Calendar if possible
  if dockutil --find "Calendar" >/dev/null 2>&1; then
    dockutil --add "$chrome_path" --after "Calendar" --no-restart
  else
    dockutil --add "$chrome_path" --no-restart
  fi

else
  # Method 2: Fallback using defaults (if dockutil not installed)
  echo "⚠️  dockutil not found. Using built-in Dock modification..."
  echo "   (You can install dockutil with: brew install dockutil)"

  # Read Dock entries
  defaults write com.apple.dock persistent-apps -array-add "<dict>
    <key>tile-data</key>
    <dict>
      <key>file-data</key>
      <dict>
        <key>_CFURLString</key>
        <string>$chrome_path</string>
        <key>_CFURLStringType</key>
        <integer>0</integer>
      </dict>
    </dict>
  </dict>"
fi

# === 5. Restart Dock to apply changes ===
echo "🔄 Restarting Dock to apply changes..."
killall Dock 2>/dev/null
sleep 2

echo
echo "🎉 Google Chrome has been installed and added to your Dock!"
echo "💫 You can launch it anytime with: open -a 'Google Chrome'"
echo "-----------------------------------------------------------"

