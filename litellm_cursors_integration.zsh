#!/bin/zsh
# === litellm_cursors_integration.zsh ===
# Purpose: Add Anthropic API environment variables (via LiteLLM) to ~/.zshrc
# Shell: Zsh (default on macOS Ventura)
# Author: theoneandonlywoj

set -e

echo "🚀 Configuring Anthropic environment variables for LiteLLM integration..."
echo

# === 1. Define configuration path ===
ZSHRC_PATH="$HOME/.zshrc"

# Ensure ~/.zshrc exists
if [[ ! -f "$ZSHRC_PATH" ]]; then
  echo "📄 No ~/.zshrc found — creating one..."
  touch "$ZSHRC_PATH"
fi

# === 2. Prompt for user input ===
echo "🧠 Please provide your Anthropic configuration details."
echo
read -r "?🔗 Enter your LiteLLM endpoint URL (e.g. https://api.your-llm-proxy.com): " USER_BASE_URL
read -r "?🔐 Enter your Anthropic Auth Token (input hidden): " -s USER_AUTH_TOKEN
echo
echo

# === 3. Construct export lines ===
VAR_1="export ANTHROPIC_BASE_URL=${USER_BASE_URL}"
VAR_2="export ANTHROPIC_AUTH_TOKEN=${USER_AUTH_TOKEN}"

# === 4. Add variables to ~/.zshrc if not already present ===
add_if_missing() {
  local key="$1"
  local value="$2"
  local full_line="export ${key}=${value}"

  if grep -q "^export ${key}=" "$ZSHRC_PATH"; then
    echo "🔁 Updating existing ${key} entry..."
    # Replace existing line safely
    sed -i '' "s|^export ${key}=.*|export ${key}=${value}|" "$ZSHRC_PATH"
  else
    echo "➕ Adding ${key} to ~/.zshrc"
    echo "$full_line" >> "$ZSHRC_PATH"
  fi
}

add_if_missing "ANTHROPIC_BASE_URL" "$USER_BASE_URL"
add_if_missing "ANTHROPIC_AUTH_TOKEN" "$USER_AUTH_TOKEN"

# === 5. Reload configuration ===
echo
echo "🔄 Reloading ~/.zshrc to apply new environment variables..."
source "$ZSHRC_PATH"

# === 6. Verify ===
echo
echo "✅ Anthropic environment configuration complete!"
echo "💡 Verify with:"
echo "   echo \$ANTHROPIC_BASE_URL"
echo "   echo \$ANTHROPIC_AUTH_TOKEN"
echo
echo "🎉 Done! Your Anthropic LiteLLM environment is now ready to use."