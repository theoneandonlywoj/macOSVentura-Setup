#!/bin/zsh
# === postman.zsh ===
# Purpose: Install Postman (API development and testing tool) on macOS Ventura
# Shell: Zsh (default on macOS Ventura)
# Author: theoneandonlywoj

echo "🚀 Starting Postman installation on macOS Ventura..."
echo

# === Configuration ===
brew_path="/opt/homebrew/bin/brew"
postman_app="/Applications/Postman.app"
dock_add="yes"   # set to "yes" to add Postman to Dock automatically

echo "📦 Target application path: $postman_app"
echo "🧠 Shell: Zsh"
echo "🎯 Add to Dock?   $dock_add"
echo

# === 1. Ensure Homebrew is available ===
if ! command -v brew >/dev/null 2>&1; then
  echo "⚙️  Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo "💡 Adding Homebrew to PATH..."
  if [[ -d "/opt/homebrew/bin" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  echo "✅ Homebrew installed successfully."
else
  echo "✅ Homebrew already installed."
fi

# === 2. Install Postman via Homebrew Cask ===
echo
echo "📥 Installing Postman..."
if brew list --cask postman &>/dev/null; then
  echo "ℹ️  Postman is already installed. Upgrading to latest version..."
  brew upgrade --cask postman || echo "⚠️  Upgrade skipped (already up-to-date)."
else
  brew install --cask postman
fi

# === 3. Verify installation ===
if [[ -d "$postman_app" ]]; then
  echo "✅ Postman installed successfully at: $postman_app"
else
  echo "❌ Postman installation failed. Aborting."
  exit 1
fi

# === 4. Add Homebrew to PATH if needed ===
if [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
  echo "🧩 Adding Homebrew to PATH in ~/.zshrc..."
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
  source ~/.zshrc
  echo "✅ PATH updated for Homebrew binaries."
fi

# === 5. Optionally add to Dock ===
if [[ "$dock_add" = "yes" ]]; then
  echo
  echo "🧭 Adding Postman to Dock..."

  # Backup current Dock configuration
  defaults export com.apple.dock - > ~/Desktop/com.apple.dock.backup.postman.plist 2>/dev/null
  echo "💾 Dock preference backup saved to ~/Desktop/com.apple.dock.backup.postman.plist"

  # Construct Dock entry XML snippet
  postman_entry="<dict>
    <key>tile-data</key>
    <dict>
      <key>file-data</key>
      <dict>
        <key>_CFURLString</key>
        <string>${postman_app}</string>
        <key>_CFURLStringType</key>
        <integer>0</integer>
      </dict>
    </dict>
    <key>tile-type</key>
    <string>file-tile</string>
  </dict>"

  # Add Postman if not already in Dock
  if defaults read com.apple.dock persistent-apps | grep -q "Postman.app"; then
    echo "ℹ️  Postman is already in the Dock."
  else
    echo "➕ Adding Postman to the end of the Dock..."
    defaults write com.apple.dock persistent-apps -array-add "$postman_entry"
  fi

  # Restart Dock to apply changes
  echo "🔄 Restarting Dock..."
  killall Dock 2>/dev/null
  echo "✅ Dock updated."
fi

# === 6. Wrap-up and hints ===
echo
echo "🎉 Postman installation complete!"
echo
echo "💡 Next steps:"
echo "   • Launch Postman via Launchpad or Spotlight (⌘ + Space → “Postman”)"
echo "   • Sign in or create a free account for syncing collections"
echo "   • Use Collections & Environments to organize your API requests"
echo "   • Integrate Postman CLI (newman) via 'brew install newman' if needed"
echo
echo "🧪 Verification:"
echo "   postman version (for CLI)"
echo
echo "🔥 Ready to build, test, and debug APIs faster than ever!"