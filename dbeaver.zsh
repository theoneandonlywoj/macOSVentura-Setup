#!/bin/zsh
# === dbeaver.zsh ===
# Purpose: Install DBeaver (database management tool) on macOS Ventura with Zsh and add it to the Dock
# Shell: Zsh (default)
# Author: theoneandonlywoj

echo "🚀 Starting DBeaver installation on macOS Ventura..."
echo

# === Configuration ===
zshrc_path="$HOME/.zshrc"
dbeaver_app="/Applications/DBeaver.app"
alias_line="alias dbeaver='open -a DBeaver'"

echo "📦 Target application: $dbeaver_app"
echo "🧠 Shell: Zsh"
echo

# === 1. Ensure Homebrew is installed ===
if ! command -v brew >/dev/null 2>&1; then
  echo "📥 Installing Homebrew (required for DBeaver installation)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "✅ Homebrew already installed."
fi

# === 2. Install or update DBeaver ===
echo
echo "📥 Installing DBeaver via Homebrew..."
if brew list --cask dbeaver-community &>/dev/null; then
  echo "ℹ️  DBeaver is already installed. Upgrading to latest version..."
  brew upgrade --cask dbeaver-community || echo "⚠️  Already up-to-date."
else
  brew install --cask dbeaver-community
fi

# === 3. Verify installation ===
echo
echo "🧪 Verifying DBeaver installation..."
if [[ -d "$dbeaver_app" ]]; then
  echo "✅ DBeaver installed successfully at: $dbeaver_app"
else
  echo "❌ DBeaver installation failed. Aborting."
  exit 1
fi

# === 4. Add DBeaver alias to Zsh ===
echo
echo "🔗 Ensuring DBeaver alias is in ~/.zshrc..."
if grep -Fxq "$alias_line" "$zshrc_path"; then
  echo "✅ DBeaver alias already exists in ~/.zshrc"
else
  echo "\n# DBeaver launcher alias" >> "$zshrc_path"
  echo "$alias_line" >> "$zshrc_path"
  echo "✅ Added DBeaver alias to ~/.zshrc"
fi

# Apply immediately
eval "$alias_line"

# === 5. Add DBeaver to Dock ===
echo
echo "📌 Adding DBeaver to the Dock..."

if ! command -v dockutil >/dev/null 2>&1; then
  echo "📥 Installing dockutil (for Dock management)..."
  brew install dockutil
fi

# Remove any old DBeaver icons from the Dock
dockutil --remove "DBeaver" --no-restart &>/dev/null

# Add DBeaver to Dock (after last item)
dockutil --add "$dbeaver_app" --replacing "DBeaver" --no-restart
killall Dock >/dev/null 2>&1
echo "✅ DBeaver added to Dock successfully!"

# === 6. Verify alias works ===
echo
echo "🧩 Testing DBeaver alias..."
if command -v open >/dev/null 2>&1; then
  echo "✅ You can now launch DBeaver with: dbeaver"
else
  echo "⚠️  'open' command unavailable — alias might not work."
fi

# === 7. Wrap-up ===
echo
echo "🎉 DBeaver installation complete!"
echo
echo "💡 Useful commands:"
echo "   • dbeaver                   → Launch DBeaver GUI"
echo "   • brew upgrade --cask dbeaver-community  → Update DBeaver"
echo "   • brew uninstall --cask dbeaver-community → Remove DBeaver"
echo
echo "🧭 DBeaver is pinned to your Dock and ready to use!"
echo "📚 Docs: https://dbeaver.io/"
echo
echo "✅ Done!"
