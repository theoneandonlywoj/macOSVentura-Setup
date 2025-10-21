#!/bin/zsh
# === install_1password.zsh ===
# Purpose: Install 1Password on macOS Ventura (with optional Dock integration)
# Shell: Zsh (default)
# Author: theoneandonlywoj (style inspired)

echo "🚀 Starting 1Password installation on macOS Ventura..."
echo

# === Configuration ===
brew_path="/opt/homebrew/bin/brew"
app_path="/Applications/1Password.app"
dock_add="yes"   # set to "no" if you don’t want to add to Dock

echo "📦 Target application: $app_path"
echo "🎯 Add to Dock?   $dock_add"
echo

# === 1. Check and install Homebrew if missing ===
if ! command -v brew >/dev/null 2>&1; then
  echo "⚙️  Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "💡 Adding Homebrew to PATH..."
  if [[ -d "/opt/homebrew/bin" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  echo "✅ Homebrew installed."
else
  echo "✅ Homebrew already installed."
fi

# === 2. Install 1Password ===
echo
echo "📥 Installing 1Password..."
if brew list 1password &>/dev/null; then
  echo "✅ 1Password is already installed."
else
  brew install --cask 1password
fi

# === 3. Verify installation ===
if [[ -d "$app_path" ]]; then
  echo "✅ 1Password installed successfully: $app_path"
else
  echo "❌ 1Password installation failed. Aborting."
  exit 1
fi

# === 4. Optionally add to Dock ===
if [[ "$dock_add" = "yes" ]]; then
  echo
  echo "🧭 Adding 1Password to Dock..."

  # Backup Dock preferences
  defaults export com.apple.dock - > ~/Desktop/com.apple.dock.backup.1password.plist 2>/dev/null
  echo "💾 Dock backup saved to ~/Desktop/com.apple.dock.backup.1password.plist"

  # Construct Dock entry XML snippet
  dock_entry="<dict>
    <key>tile-data</key>
    <dict>
      <key>file-data</key>
      <dict>
        <key>_CFURLString</key>
        <string>${app_path}</string>
        <key>_CFURLStringType</key>
        <integer>0</integer>
      </dict>
    </dict>
    <key>tile-type</key>
    <string>file-tile</string>
  </dict>"

  # Check if already in Dock
  if defaults read com.apple.dock persistent-apps | grep -q "1Password.app"; then
    echo "ℹ️  1Password is already in the Dock."
  else
    echo "➕ Adding 1Password to the end of the Dock..."
    defaults write com.apple.dock persistent-apps -array-add "$dock_entry"
  fi

  # Restart Dock to apply changes
  echo "🔄 Restarting Dock..."
  killall Dock 2>/dev/null
  echo "✅ Dock updated."
fi

# === 5. Post-installation info ===
echo
echo "🧪 Verifying..."
if open -Ra "1Password"; then
  echo "✅ 1Password is ready to launch!"
else
  echo "⚠️  Unable to verify app launch. Check installation manually."
fi

# === 6. Wrap-up ===
echo
echo "🎉 1Password installation complete!"
echo
echo "💡 Next steps:"
echo "   • Launch 1Password via Spotlight (⌘ + Space → '1Password')"
echo "   • Sign in with your 1Password account"
echo "   • Configure browser extensions or Touch ID if desired"
echo
echo "🔐 You’re now ready for secure password management."

