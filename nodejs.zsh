#!/bin/zsh
# === nodejs.zsh ===
# Purpose: Install Node.js (with npm + npx) using Mise on macOS Ventura
# Shell: Zsh (default)
# Author: theoneandonlywoj

echo "🚀 Starting Node.js installation via Mise on macOS Ventura..."
echo

# === 0. Default version (used if .tool-versions is not present) ===
DEFAULT_NODE="22.11.0"

# === 1. Determine version ===
if [[ -f ".tool-versions" ]]; then
  echo "📂 Found .tool-versions file. Reading version..."
  NODE_VER=$(grep "^nodejs " .tool-versions | awk '{print $2}')
  if [[ -z "$NODE_VER" ]]; then
    echo "⚠️  Node.js version not found in .tool-versions. Using default: $DEFAULT_NODE"
    NODE_VER="$DEFAULT_NODE"
  fi
else
  echo "ℹ️  .tool-versions not found. Using default Node.js version."
  NODE_VER="$DEFAULT_NODE"
fi

echo "📌 Node.js version to install: $NODE_VER"
echo

# === 2. Check Mise installation ===
if ! command -v mise >/dev/null 2>&1; then
  echo "❌ Mise is not installed. Please run install_mise.zsh first."
  exit 1
fi
echo "✅ Mise detected."
echo

# === 3. Install Node.js ===
echo "📥 Installing Node.js $NODE_VER via Mise..."
mise install nodejs@"$NODE_VER"
if [[ $? -ne 0 ]]; then
  echo "❌ Failed to install Node.js $NODE_VER"
  exit 1
fi

mise use nodejs@"$NODE_VER"
echo "✅ Node.js $NODE_VER installed and activated."
echo

# === 4. Verify Node.js, npm, and npx ===
echo "🧪 Verifying installation..."

node_v=$(mise exec -- node -v 2>/dev/null | sed 's/v//')
npm_v=$(mise exec -- npm -v 2>/dev/null)
npx_v=$(mise exec -- npx -v 2>/dev/null)

if [[ -z "$node_v" ]]; then
  echo "❌ Failed to retrieve Node.js version. 'node' command may not be available."
  exit 1
fi
if [[ -z "$npm_v" ]]; then
  echo "❌ npm not found. Something went wrong with the Node.js installation."
  exit 1
fi
if [[ -z "$npx_v" ]]; then
  echo "❌ npx not found. It should be included with npm. Please check your installation."
  exit 1
fi

echo "📘 Node.js version: $node_v"
echo "📘 npm version: $npm_v"
echo "📘 npx version: $npx_v"

# Compare major versions to expected
node_major=$(echo "$node_v" | cut -d. -f1)
expected_major=$(echo "$NODE_VER" | cut -d. -f1)
if [[ "$node_major" = "$expected_major" ]]; then
  echo "✅ Node.js setup verified successfully!"
else
  echo "⚠️  Version mismatch detected. Expected ~$NODE_VER but got $node_v"
fi

# === 5. Wrap-up ===
echo
echo "💡 Next steps:"
echo "   • Run Node REPL: node"
echo "   • Check npm: npm -v"
echo "   • Use npx: npx <package>"
echo "   • Manage versions: mise install/use nodejs@<version>"
echo "   • Set global default: mise use --global nodejs@$NODE_VER"
echo
echo "🎉 Node.js + npm + npx installation finished successfully!"
