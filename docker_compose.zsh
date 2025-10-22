#!/bin/zsh
# === docker_compose.zsh ===
# Purpose: Install Docker Compose (v2) on macOS Ventura with Zsh
# Shell: Zsh (default on macOS Ventura)
# Author: theoneandonlywoj

echo "🚀 Starting Docker Compose installation on macOS Ventura..."
echo

# === Configuration ===
compose_dir="/opt/homebrew/lib/docker/cli-plugins"
compose_plugin="$compose_dir/docker-compose"
zshrc_path="$HOME/.zshrc"
alias_line="alias docker-compose='docker compose'"
docker_config="$HOME/.docker/config.json"

echo "📦 Target binary: $compose_plugin"
echo "🧠 Shell: Zsh"
echo

# === 1. Ensure Docker or Podman exists ===
if ! command -v docker >/dev/null 2>&1 && ! command -v podman >/dev/null 2>&1; then
  echo "⚠️  Neither Docker nor Podman is installed."
  echo "💡 Please install Docker Desktop or Podman before running this script."
  exit 1
fi

# === 2. Install Docker Compose plugin via Homebrew ===
echo "📥 Installing Docker Compose..."
if brew list docker-compose &>/dev/null; then
  echo "ℹ️  Docker Compose is already installed. Upgrading..."
  brew upgrade docker-compose || echo "⚠️  Upgrade skipped (already up-to-date)."
else
  brew install docker-compose
fi

# === 3. Verify plugin file ===
if [[ -f "$compose_plugin" ]] || [[ -f "/usr/local/lib/docker/cli-plugins/docker-compose" ]]; then
  echo "✅ Docker Compose binary found!"
else
  echo "❌ Docker Compose binary not found. Aborting."
  exit 1
fi

# === 4. Ensure Docker recognizes plugin directory ===
echo
echo "🔧 Ensuring Docker sees Docker Compose plugin..."
mkdir -p "$(dirname "$docker_config")"

if [[ -f "$docker_config" ]]; then
  if ! grep -q "cliPluginsExtraDirs" "$docker_config"; then
    tmpfile=$(mktemp)
    jq '. + {"cliPluginsExtraDirs": ["'"$compose_dir"'"]}' "$docker_config" > "$tmpfile" && mv "$tmpfile" "$docker_config"
    echo "✅ Added cliPluginsExtraDirs to $docker_config"
  else
    echo "✅ cliPluginsExtraDirs already set in Docker config"
  fi
else
  echo "{\"cliPluginsExtraDirs\": [\"$compose_dir\"]}" > "$docker_config"
  echo "✅ Created new Docker config with cliPluginsExtraDirs"
fi

# === 5. Add docker-compose alias ===
echo
echo "🔗 Ensuring docker-compose alias in ~/.zshrc..."
if grep -Fxq "$alias_line" "$zshrc_path"; then
  echo "✅ docker-compose alias already exists"
else
  echo "\n# Docker Compose v2 alias" >> "$zshrc_path"
  echo "$alias_line" >> "$zshrc_path"
  echo "✅ Added docker-compose alias to ~/.zshrc"
fi

# Apply immediately
eval "$alias_line"

# === 6. Test installation ===
echo
echo "🧪 Verifying Docker Compose setup..."
if docker compose version >/dev/null 2>&1; then
  version_info=$(docker compose version | head -n1)
  echo "✅ Docker Compose is functional!"
  echo "📘 Version: $version_info"
else
  echo "⚠️  Docker could not locate the Compose plugin yet."
  echo "💡 Try restarting Docker Desktop or Podman, then run:"
  echo "   docker compose version"
fi

# === 7. Test docker-compose alias ===
echo
echo "🧩 Testing docker-compose alias..."
if docker-compose version >/dev/null 2>&1; then
  echo "✅ docker-compose alias works correctly!"
else
  echo "⚠️  Alias may not yet be active. Run: source ~/.zshrc"
fi

# === 8. Wrap-up ===
echo
echo "🎉 Docker Compose installation complete!"
echo
echo "💡 Useful commands:"
echo "   • docker compose up -d      → Start containers in detached mode"
echo "   • docker compose down       → Stop and remove containers"
echo "   • docker compose ps         → List running containers"
echo "   • docker-compose up -d      → (Alias) Same as above"
echo
echo "🐳 Docker Compose v2 ready for use in your Zsh environment!"

