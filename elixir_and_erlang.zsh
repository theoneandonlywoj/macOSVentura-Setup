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
erlang_v=$(erl -eval 'io:format("~s~n", [erlang:system_info(otp_release)]), halt().' -noshell)
if ! command -v elixir >/dev/null 2>&1; then
  echo "❌ Elixir command not found in PATH. Please check your installation and ensure Mise has set up your environment correctly."
  exit 1
fi
elixir_v=$(elixir -v | head -n1 | awk '{print $2}')
if [[ -z "$elixir_v" ]]; then
  echo "❌ Failed to detect Elixir version. Please check your installation and PATH."
  exit 1
fi

echo "📌 Erlang version: $erlang_v"
echo "📌 Elixir version: $elixir_v"

if [[ "$erlang_v" = "$ERLANG_VER" && "$elixir_v" = "$ELIXIR_VER" ]]; then
  echo "✅ Erlang + Elixir setup complete!"
else
  echo "⚠️  Version mismatch detected. Check Mise installation."
fi

# === 6. Wrap-up ===
echo
echo "💡 Next steps:"
echo "   • Use Erlang: erl"
echo "   • Use Elixir: iex"
echo "   • Manage versions with: mise install/use <tool>@<version>"
echo
echo "🎉 Installation finished successfully!"

