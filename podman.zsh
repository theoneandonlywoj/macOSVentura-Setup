#!/bin/zsh
# === podman.zsh ===
# Purpose: Install Podman (container engine) on macOS Ventura with Zsh
# Shell: Zsh (default on macOS Ventura)
# Author: theoneandonlywoj

echo "🚀 Starting Podman installation on macOS Ventura..."
echo

# === Configuration ===
brew_path="/opt/homebrew/bin/brew"
podman_bin="/opt/homebrew/bin/podman"

echo "📦 Target binary: $podman_bin"
echo "🧠 Shell: Zsh"
echo

# === 1. Ensure Homebrew is installed ===
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

# === 2. Install Podman ===
echo
echo "📥 Installing Podman..."
if brew list podman &>/dev/null; then
  echo "ℹ️  Podman is already installed. Upgrading to latest version..."
  brew upgrade podman || echo "⚠️  Upgrade skipped (already up-to-date)."
else
  brew install podman
fi

# === 3. Verify installation ===
if command -v podman >/dev/null 2>&1; then
  echo "✅ Podman installed successfully!"
else
  echo "❌ Podman installation failed. Aborting."
  exit 1
fi

# === 4. Add Homebrew to PATH (if missing) ===
if [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
  echo "🧩 Adding Homebrew to PATH in ~/.zshrc..."
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
  echo "ℹ️  Please restart your shell or run 'source ~/.zshrc' to update your PATH."
  echo "✅ PATH update instruction provided."
fi

# === 5. Initialize Podman machine ===
echo
echo "🧰 Checking Podman machine status..."
if ! podman machine list | grep -q "podman-machine-default"; then
  echo "🆕 Creating Podman virtual machine (default)..."
  podman machine init
else
  echo "✅ Podman machine already exists."
fi

echo "▶️ Starting Podman machine..."
podman machine start

if [[ $? -ne 0 ]]; then
  echo "❌ Failed to start Podman machine."
  exit 1
fi

# === 6. Verify Podman functionality ===
echo
echo "🧪 Testing Podman setup..."
podman info >/dev/null 2>&1

if [[ $? -eq 0 ]]; then
  podman_version=$(podman --version)
  echo "✅ Podman is running successfully!"
  echo "📘 Version: $podman_version"
else
  echo "⚠️  Podman installed but not responding properly. Try restarting the machine:"
  echo "   podman machine stop && podman machine start"
fi

# === 7. Post-install hints ===
echo
echo "🎉 Podman installation complete!"
echo
echo "💡 Useful commands:"
echo "   • podman machine start          → Start Podman virtual machine"
echo "   • podman ps                     → List running containers"
echo "   • podman images                 → Show available images"
echo "   • podman run -it alpine sh      → Run a lightweight container"
echo "   • podman machine stop           → Stop Podman VM"
echo
echo "🐳 Enjoy rootless containers with Podman on macOS Ventura!"
