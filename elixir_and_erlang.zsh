#!/bin/zsh
# === elixir_and_erlang.zsh ===
# Purpose: Install Erlang and Elixir using Mise on macOS Ventura
# Shell: Zsh (default)
# Author: theoneandonlywoj

echo "🚀 Starting Erlang + Elixir installation via Mise on macOS Ventura..."
echo

# === 0. Default versions (used if .tool-versions is not present) ===
DEFAULT_ERLANG="28.1"
DEFAULT_ELIXIR="1.19.0-otp-28"

# === 1. Determine versions ===
if [[ -f ".tool-versions" ]]; then
  echo "📂 Found .tool-versions file. Reading versions..."
  ERLANG_VER=$(grep "^erlang " .tool-versions | awk '{print $2}')
  ELIXIR_VER=$(grep "^elixir " .tool-versions | awk '{print $2}')
  if [[ -z "$ERLANG_VER" ]]; then
    echo "⚠️  Erlang version not found in .tool-versions. Using default: $DEFAULT_ERLANG"
    ERLANG_VER="$DEFAULT_ERLANG"
  fi
  if [[ -z "$ELIXIR_VER" ]]; then
    echo "⚠️  Elixir version not found in .tool-versions. Using default: $DEFAULT_ELIXIR"
    ELIXIR_VER="$DEFAULT_ELIXIR"
  fi
else
  echo "ℹ️ .tool-versions not found. Using default versions."
  ERLANG_VER="$DEFAULT_ERLANG"
  ELIXIR_VER="$DEFAULT_ELIXIR"
fi

echo "📌 Erlang version to install: $ERLANG_VER"
echo "📌 Elixir version to install: $ELIXIR_VER"
echo

# === 2. Check Mise installation ===
if ! command -v mise >/dev/null 2>&1; then
  echo "❌ Mise is not installed. Please run install_mise.zsh first."
  exit 1
fi
echo "✅ Mise detected."

# === 3. Install Erlang ===
echo
echo "📥 Installing Erlang $ERLANG_VER via Mise..."
mise install erlang@"$ERLANG_VER"
if [[ $? -ne 0 ]]; then
  echo "❌ Failed to install Erlang $ERLANG_VER"
  exit 1
fi
mise use erlang@"$ERLANG_VER"
echo "✅ Erlang $ERLANG_VER installed and activated."

# === 4. Install Elixir ===
echo
echo "📥 Installing Elixir $ELIXIR_VER via Mise..."
mise install elixir@"$ELIXIR_VER"
if [[ $? -ne 0 ]]; then
  echo "❌ Failed to install Elixir $ELIXIR_VER"
  exit 1
fi
mise use elixir@"$ELIXIR_VER"
echo "✅ Elixir $ELIXIR_VER installed and activated."

# === 5. Verify installations ===
echo
echo "🧪 Verifying installations..."

# Verify Erlang version using mise exec to ensure proper environment
erlang_v=$(mise exec -- erl -eval 'io:format("~s~n", [erlang:system_info(otp_release)]), halt().' -noshell 2>/dev/null)
if [[ -z "$erlang_v" ]]; then
  echo "❌ Failed to retrieve Erlang version. The 'erl' command may have failed to run."
  exit 1
fi

# Verify Elixir version using mise exec to ensure proper environment
elixir_v=$(mise exec -- elixir -v 2>/dev/null | grep "Elixir" | awk '{print $2}')
if [[ -z "$elixir_v" ]]; then
  echo "❌ Failed to detect Elixir version. Please check your installation."
  exit 1
fi

echo "📌 Erlang version: $erlang_v"
echo "📌 Elixir version: $elixir_v"

# Check if versions match (allowing for minor differences in format)
erlang_major=$(echo "$erlang_v" | cut -d. -f1)
erlang_expected_major=$(echo "$ERLANG_VER" | cut -d. -f1)
elixir_base=$(echo "$elixir_v" | cut -d- -f1)
elixir_expected_base=$(echo "$ELIXIR_VER" | cut -d- -f1)

if [[ "$erlang_major" = "$erlang_expected_major" && "$elixir_base" = "$elixir_expected_base" ]]; then
  echo "✅ Erlang + Elixir setup complete!"
else
  echo "⚠️  Version mismatch detected. Check Mise installation."
  echo "   Expected Erlang: $ERLANG_VER (got: $erlang_v)"
  echo "   Expected Elixir: $ELIXIR_VER (got: $elixir_v)"
fi

# === Optional: Install ElixirLS (Language Server) ===
echo
echo "💻 Installing ElixirLS (Elixir Language Server)..."

# Create ElixirLS directory
ELIXIRLS_DIR="$HOME/.elixir-ls"
mkdir -p "$ELIXIRLS_DIR"

# Get the latest release URL
echo "📥 Fetching latest ElixirLS release..."

# Try multiple methods to get the latest release URL
LATEST_RELEASE_URL=""

# Method 1: Try GitHub API with proper JSON parsing
if command -v jq >/dev/null 2>&1; then
  LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/elixir-lsp/elixir-ls/releases/latest | jq -r '.assets[] | select(.name | test("elixir-ls-v.*\\.zip$")) | .browser_download_url' 2>/dev/null)
fi

# Method 2: Fallback to grep if jq is not available
if [[ -z "$LATEST_RELEASE_URL" ]]; then
  LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/elixir-lsp/elixir-ls/releases/latest | grep -o '"browser_download_url":"[^"]*elixir-ls-v[^"]*\.zip"' | cut -d '"' -f 4)
fi

# Method 3: Use a known working URL as fallback
if [[ -z "$LATEST_RELEASE_URL" ]]; then
  echo "⚠️  Could not fetch latest release URL. Using fallback method..."
  # Get the latest release tag first
  LATEST_TAG=$(curl -s https://api.github.com/repos/elixir-lsp/elixir-ls/releases/latest | grep '"tag_name"' | cut -d '"' -f 4)
  if [[ -n "$LATEST_TAG" ]]; then
    LATEST_RELEASE_URL="https://github.com/elixir-lsp/elixir-ls/releases/download/${LATEST_TAG}/elixir-ls-${LATEST_TAG}.zip"
  fi
fi

if [[ -z "$LATEST_RELEASE_URL" ]]; then
  echo "❌ Failed to fetch latest release URL. Skipping ElixirLS installation."
else
  echo "📦 Downloading ElixirLS from: $LATEST_RELEASE_URL"
  
  # Download and extract the release
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  
  curl -L -o elixir-ls.zip "$LATEST_RELEASE_URL"
  
  if [[ $? -ne 0 ]]; then
    echo "❌ Failed to download ElixirLS release."
    cd - >/dev/null
    rm -rf "$TEMP_DIR"
  else
    echo "📦 Extracting ElixirLS..."
    unzip -q elixir-ls.zip -d "$ELIXIRLS_DIR"
    
    if [[ $? -ne 0 ]]; then
      echo "❌ Failed to extract ElixirLS."
      cd - >/dev/null
      rm -rf "$TEMP_DIR"
    else
      # Make the language server script executable
      chmod +x "$ELIXIRLS_DIR/language_server.sh"
      
      # Create a symlink for easy access
      mkdir -p ~/.mix/escripts
      ln -sf "$ELIXIRLS_DIR/language_server.sh" ~/.mix/escripts/elixir-ls
      
      echo "✅ ElixirLS installed successfully!"
      echo "   Binary located at: $ELIXIRLS_DIR/language_server.sh"
      echo "   Symlink created at: ~/.mix/escripts/elixir-ls"
      
      # Clean up
      cd - >/dev/null
      rm -rf "$TEMP_DIR"
    fi
  fi
fi 

# === 6. Wrap-up ===
echo
echo "💡 Next steps:"
echo "   • Use Erlang: erl"
echo "   • Use Elixir: iex"
echo "   • Manage versions with: mise install/use <tool>@<version>"
echo
echo "🎉 Installation finished successfully!"

