#!/bin/zsh
# === podman.zsh ===
# Purpose: Install Podman (container engine) on macOS Ventura with Zsh and a working Docker alias
# Shell: Zsh (default on macOS Ventura)
# Author: theoneandonlywoj

echo "🚀 Starting Podman installation on macOS Ventura..."
echo

# === Configuration ===
podman_bin="/opt/homebrew/bin/podman"
zshrc_path="$HOME/.zshrc"

echo "📦 Target binary: $podman_bin"
echo "🧠 Shell: Zsh"
echo

# === 1. Install or update Podman ===
echo "📥 Installing Podman..."
if brew list podman &>/dev/null; then
  echo "ℹ️  Podman is already installed. Upgrading to latest version..."
  brew upgrade podman || echo "⚠️  Upgrade skipped (already up-to-date)."
else
  brew install podman
fi

# === 2. Verify installation ===
if command -v podman >/dev/null 2>&1; then
  echo "✅ Podman installed successfully!"
else
  echo "❌ Podman installation failed. Aborting."
  exit 1
fi

# === 3. Initialize and start Podman machine ===
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

# === 4. Add Docker alias and Podman socket setup to Zsh ===
echo
echo "🔗 Ensuring Docker alias and Podman socket setup in ~/.zshrc..."

setup_block="# --- Podman Docker alias and socket setup ---
if command -v podman >/dev/null 2>&1; then
  alias docker=podman
  export DOCKER_HOST=\"unix://\$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}' 2>/dev/null)\"
fi"

if grep -q "Podman Docker alias and socket setup" "$zshrc_path"; then
  echo "✅ Docker alias + Podman socket setup already present in ~/.zshrc"
else
  echo "\n$setup_block" >> "$zshrc_path"
  echo "✅ Added Docker alias + Podman socket setup to ~/.zshrc"
fi

# Apply immediately for current session
eval "$setup_block"

# === 5. Verify Podman functionality ===
echo
echo "🧪 Testing Podman setup..."
if podman info >/dev/null 2>&1; then
  podman_version=$(podman --version)
  echo "✅ Podman is running successfully!"
  echo "📘 Version: $podman_version"
else
  echo "⚠️  Podman installed but not responding properly. Try restarting the machine:"
  echo "   podman machine stop && podman machine start"
fi

# === 6. Verify Docker alias works ===
echo
echo "🧩 Testing docker alias..."
if docker ps >/dev/null 2>&1; then
  echo "✅ Docker alias works correctly — 'docker ps' maps to Podman!"
else
  echo "⚠️  Docker alias may not yet be active in new shells. Run: source ~/.zshrc"
fi

# === 7. Wrap-up ===
echo
echo "🎉 Podman installation complete!"
echo
echo "💡 Useful commands:"
echo "   • podman machine start          → Start Podman virtual machine"
echo "   • docker ps                     → (Alias) List running containers"
echo "   • docker run -it alpine sh      → (Alias) Run lightweight container"
echo "   • podman images                 → List container images"
echo "   • podman machine stop           → Stop Podman VM"
echo
echo "🐳 You can now use 'docker' commands — powered by Podman (just restart the terminal)!"