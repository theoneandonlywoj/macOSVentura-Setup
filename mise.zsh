#!/bin/zsh
# === mise.zsh ===
# Purpose: Install Mise (version manager for programming languages) on macOS Ventura
# Shell: Zsh (default on macOS Ventura)
# Author: theoneandonlywoj

echo "🚀 Starting Mise installation on macOS Ventura..."
echo

# === Configuration ===
brew_path="/opt/homebrew/bin/brew"
mise_bin="/opt/homebrew/bin/mise"

echo "📦 Target binary: $mise_bin"
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

# === 2. Install Mise ===
echo
echo "📥 Installing Mise..."
if brew list mise &>/dev/null; then
  echo "✅ Mise is already installed."
else
  brew install mise
fi

# === 3. Verify Installation ===
if command -v mise >/dev/null 2>&1; then
  echo "✅ Mise successfully installed: $(mise --version)"
else
  echo "❌ Mise installation failed."
  exit 1
fi

# === 4. Shell integration ===
echo
echo "🔧 Setting up Zsh integration for Mise..."

# Ensure ~/.zshrc exists
touch ~/.zshrc

# Add Mise initialization lines if not already present
if ! grep -q 'mise activate zsh' ~/.zshrc; then
  echo "💡 Adding Mise activation to ~/.zshrc..."
  echo '' >> ~/.zshrc
  echo '# Initialize Mise (language version manager)' >> ~/.zshrc
  echo 'eval "$(/usr/local/bin/mise activate zsh)"' >> ~/.zshrc
else
  echo "✅ Mise already initialized in ~/.zshrc."
  # Update existing activation to use full path if needed
  if grep -q 'eval "$(mise activate zsh)"' ~/.zshrc; then
    echo "💡 Updating Mise activation to use full path..."
    sed -i '' 's|eval "$(mise activate zsh)"|eval "$(/usr/local/bin/mise activate zsh)"|' ~/.zshrc
  fi
fi

# Load Mise immediately in this shell
eval "$(mise activate zsh)"

echo "✅ Mise integrated with Zsh shell."

# === 5. Post-installation checks ===
echo
echo "🧪 Verifying setup..."
mise --version >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
  echo "✅ Mise is ready to use."
else
  echo "⚠️  Mise command not found in PATH. Restart your terminal or run:"
  echo '   source ~/.zshrc'
fi

# === 6. Optional: Show common usage ===
echo
echo "💡 Tip: Restart your terminal or run 'source ~/.zshrc' to activate Mise immediately."
echo
echo "📚 Useful Mise commands:"
echo "   mise install <tool>@<version>   # Install a specific tool version"
echo "   mise use <tool>@<version>       # Use a specific tool version"
echo "   mise list                       # List installed tools"
echo "   mise env                        # Show environment variables"
echo "   mise help                       # Show documentation"
echo
echo "🎉 Mise installation complete!"
