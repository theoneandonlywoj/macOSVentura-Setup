#!/bin/zsh
# === install_emacs_and_doom_custom.zsh ===
# Purpose: Install Emacs + Doom Emacs on macOS Ventura, using a custom Doom config from GitHub
# Shell: Zsh (default on macOS Ventura)
# Author: theoneandonlywoj (style inspired)

echo "🚀 Starting Emacs + Doom Emacs installation on macOS Ventura..."
echo

# === Configuration ===
brew_path="/opt/homebrew/bin/brew"
doom_dir="$HOME/.emacs.d"
doom_config_dir="$HOME/.doom.d"
doom_bin="$doom_dir/bin/doom"
repo_url="git@github.com:theoneandonlywoj/CachyOS-Setup.git"
temp_repo_dir="/tmp/CachyOS-Setup"

echo "📦 Target Doom directory: $doom_dir"
echo "📂 Config destination: $doom_config_dir"
echo "📁 Source repo: $repo_url"
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

# === 2. Install Emacs ===
echo
echo "📥 Installing Emacs..."
if brew list emacs &>/dev/null; then
  echo "✅ Emacs already installed."
else
  brew install emacs --cask
fi

# === 3. Verify Emacs ===
if command -v emacs >/dev/null 2>&1; then
  echo "✅ Emacs successfully installed: $(emacs --version | head -n1)"
else
  echo "❌ Emacs installation failed."
  exit 1
fi

# === 4. Install Doom Emacs ===
echo
echo "🧠 Installing Doom Emacs..."
if [[ -d "$doom_dir" ]]; then
  echo "ℹ️ Doom Emacs already exists. Updating..."
  git -C "$doom_dir" pull
else
  git clone --depth 1 https://github.com/doomemacs/doomemacs "$doom_dir"
fi

# === 5. Clone custom Doom configuration ===
echo
echo "🧩 Cloning Doom configuration from $repo_url..."
if [[ -d "$temp_repo_dir" ]]; then
  echo "🧹 Cleaning up old temporary clone..."
  rm -rf "$temp_repo_dir"
fi

git clone "$repo_url" "$temp_repo_dir"
if [[ $? -ne 0 ]]; then
  echo "❌ Failed to clone repository. Please check SSH access or GitHub key setup."
  exit 1
fi

# === 6. Copy only .doom.d folder ===
if [[ -d "$temp_repo_dir/.doom.d" ]]; then
  echo "📂 Copying .doom.d from repository..."
  rm -rf "$doom_config_dir"
  cp -R "$temp_repo_dir/.doom.d" "$doom_config_dir"
  echo "✅ Custom Doom configuration installed to $doom_config_dir"
else
  echo "❌ .doom.d folder not found in repository. Aborting."
  exit 1
fi

# Cleanup temp repo
rm -rf "$temp_repo_dir"

# === 7. Run Doom Emacs installation ===
if [[ -f "$doom_bin" ]]; then
  echo "🔧 Installing Doom Emacs..."
  "$doom_bin" install
  echo "✅ Doom Emacs installed."
else
  echo "❌ Doom binary missing — clone may have failed."
  exit 1
fi

# === 8. Sync and verify ===
echo
echo "🔄 Running Doom sync..."
"$doom_bin" sync

echo
echo "🧪 Verifying..."
if [[ -x "$doom_bin" ]]; then
  echo "✅ Doom Emacs is ready!"
else
  echo "❌ Something went wrong with the setup."
  exit 1
fi

# === 9. PATH setup ===
if [[ ":$PATH:" != *":$doom_dir/bin:"* ]]; then
  echo
  echo "🔧 Adding Doom Emacs to PATH..."
  echo "export PATH=\"\$PATH:$doom_dir/bin\"" >> ~/.zshrc
  source ~/.zshrc
  echo "✅ PATH updated."
fi

# === 10. Wrap-up ===
echo
echo "🎉 Emacs + Doom Emacs installation complete!"
echo
echo "💡 Next steps:"
echo "   • Launch Doom Emacs: emacs"
echo "   • Update modules: doom sync"
echo "   • Upgrade Doom: doom upgrade"
echo "   • Docs: https://doomemacs.org/docs/getting_started"
echo
echo "🔥 Custom Doom configuration from: $repo_url/.doom.d/"

