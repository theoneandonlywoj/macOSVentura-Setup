#!/bin/zsh
# === brew.zsh ===
# Purpose: Install Homebrew package manager on macOS Ventura
# Shell: Zsh (default on macOS Ventura)
# Author: theoneandonlywoj (style inspired)

echo "🚀 Starting Homebrew installation on macOS Ventura..."
echo "📦 Preparing environment..."
echo

# === 1. Check if Homebrew is already installed ===
if command -v brew >/dev/null 2>&1; then
  current_version=$(brew --version | head -n1)
  echo "✅ Homebrew is already installed!"
  echo "   $current_version"
  echo
  echo "💡 To update Homebrew, run: brew update"
  echo "🎉 Nothing to do!"
  exit 0
fi

# === 2. Detect CPU architecture (Intel vs Apple Silicon) ===
echo "🧠 Detecting system architecture..."
arch_name=$(uname -m)
if [[ "$arch_name" == "arm64" ]]; then
  echo "🍏 Detected Apple Silicon (M1/M2/M3)..."
  brew_path="/opt/homebrew/bin/brew"
  brew_shell_line='eval "$(/opt/homebrew/bin/brew shellenv)"'
else
  echo "💻 Detected Intel-based Mac..."
  brew_path="/usr/local/bin/brew"
  brew_shell_line='eval "$(/usr/local/bin/brew shellenv)"'
fi
echo

# === 3. Install Homebrew ===
echo "📥 Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [[ $? -ne 0 ]]; then
  echo "❌ Homebrew installation failed!"
  echo "⚠️  Please check your internet connection or permissions."
  exit 1
fi

echo
echo "✅ Homebrew installation completed successfully."

# === 4. Configure PATH for Zsh ===
echo "🔧 Adding Homebrew to PATH..."

# Append brew init line if not already in .zprofile
if ! grep -q "$brew_shell_line" ~/.zprofile 2>/dev/null; then
  echo "$brew_shell_line" >> ~/.zprofile
  echo "📄 Updated ~/.zprofile with Homebrew path"
else
  echo "ℹ️  Homebrew path already configured in ~/.zprofile"
fi

# Apply immediately to current shell session
eval "$brew_shell_line"

# === 5. Verify installation ===
echo
echo "🧪 Verifying installation..."
if command -v brew >/dev/null 2>&1; then
  brew_version=$(brew --version | head -n1)
  echo "✅ Homebrew is ready to use!"
  echo "   $brew_version"
else
  echo "❌ Homebrew not found in PATH."
  echo "⚙️  Try restarting your terminal or running:"
  echo "   $brew_shell_line"
  exit 1
fi

# === 6. Post-install info ===
echo
echo "🎉 Homebrew installation complete!"
echo
echo "💡 Next steps:"
echo "   • Run 'brew doctor' to verify your setup"
echo "   • Run 'brew update' to fetch the latest packages"
echo "   • Explore available software with 'brew search <name>'"
echo
echo "🧠 Homebrew binaries are now immediately available in this Zsh session!"
echo "✨ Happy brewing!"

