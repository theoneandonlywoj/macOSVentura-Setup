#!/bin/zsh
# === kubectl.zsh ===
# Purpose: Install kubectl, kubelogin, and krew using Mise on macOS Ventura
# Shell: Zsh (default)
# Author: theoneandonlywoj

echo "🚀 Starting kubectl + krew + kubelogin installation via Mise on macOS Ventura..."
echo

# === 0. Default versions (used if .tool-versions is not present) ===
DEFAULT_KUBECTL="1.31.3"

# === 1. Determine kubectl version ===
if [[ -f ".tool-versions" ]]; then
  echo "📂 Found .tool-versions file. Reading versions..."
  KUBECTL_VER=$(grep "^kubectl " .tool-versions | awk '{print $2}')
  if [[ -z "$KUBECTL_VER" ]]; then
    echo "⚠️  kubectl version not found in .tool-versions. Using default: $DEFAULT_KUBECTL"
    KUBECTL_VER="$DEFAULT_KUBECTL"
  fi
else
  echo "ℹ️ .tool-versions not found. Using default versions."
  KUBECTL_VER="$DEFAULT_KUBECTL"
fi

echo "📌 kubectl version to install: $KUBECTL_VER"
echo

# === 2. Check Mise installation ===
if ! command -v mise >/dev/null 2>&1; then
  echo "❌ Mise is not installed. Please run mise.zsh first."
  exit 1
fi
echo "✅ Mise detected."

# === 3. Install kubectl ===
echo
echo "📥 Installing kubectl $KUBECTL_VER via Mise..."
mise install kubectl@"$KUBECTL_VER"
if [[ $? -ne 0 ]]; then
  echo "❌ Failed to install kubectl $KUBECTL_VER"
  exit 1
fi
mise use kubectl@"$KUBECTL_VER"
echo "✅ kubectl $KUBECTL_VER installed and activated."

# === 4. Verify kubectl installation ===
echo
echo "🧪 Verifying kubectl installation..."
kubectl_v=$(mise exec -- kubectl version --client 2>&1 | grep "Client Version:" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n1 | sed 's/^v//')
if [[ -z "$kubectl_v" ]]; then
  echo "❌ Failed to detect kubectl version. Please check your installation."
  exit 1
fi
echo "📌 kubectl version: $kubectl_v"

# Check if version matches (allowing for minor differences in format)
kubectl_major=$(echo "$kubectl_v" | cut -d. -f1)
kubectl_minor=$(echo "$kubectl_v" | cut -d. -f2)
kubectl_expected_major=$(echo "$KUBECTL_VER" | cut -d. -f1)
kubectl_expected_minor=$(echo "$KUBECTL_VER" | cut -d. -f2)

if [[ "$kubectl_major" = "$kubectl_expected_major" && "$kubectl_minor" = "$kubectl_expected_minor" ]]; then
  echo "✅ kubectl setup complete!"
else
  echo "⚠️  Version mismatch detected. Check Mise installation."
  echo "   Expected kubectl: $KUBECTL_VER (got: $kubectl_v)"
fi

# === 5. Install krew (kubectl plugin manager) ===
echo
echo "📥 Installing krew (kubectl plugin manager)..."

# Set krew installation directory
KREW_ROOT="${KREW_ROOT:-$HOME/.krew}"
export KREW_ROOT

# Check if krew is already installed
if [[ -x "$KREW_ROOT/bin/kubectl-krew" ]]; then
  echo "✅ krew is already installed."
else
  echo "💻 Downloading and installing krew..."
  
  # Create temporary directory for installation
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  
  # Detect OS and architecture
  OS="$(uname | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
  KREW="krew-${OS}_${ARCH}"
  
  # Download krew
  echo "📦 Downloading krew for ${OS}/${ARCH}..."
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
  
  if [[ $? -ne 0 ]]; then
    echo "❌ Failed to download krew."
    cd - >/dev/null
    rm -rf "$TEMP_DIR"
    exit 1
  fi
  
  # Extract and install
  tar zxf "${KREW}.tar.gz"
  ./"${KREW}" install krew
  
  if [[ $? -ne 0 ]]; then
    echo "❌ Failed to install krew."
    cd - >/dev/null
    rm -rf "$TEMP_DIR"
    exit 1
  fi
  
  # Clean up
  cd - >/dev/null
  rm -rf "$TEMP_DIR"
  
  echo "✅ krew installed successfully!"
fi

# === 6. Configure krew in PATH ===
echo
echo "🔧 Configuring krew PATH..."

# Ensure ~/.zshrc exists
touch ~/.zshrc

# Add krew to PATH if not already present
if ! grep -q 'KREW_ROOT' ~/.zshrc; then
  echo "💡 Adding krew to PATH in ~/.zshrc..."
  echo '' >> ~/.zshrc
  echo '# Krew (kubectl plugin manager)' >> ~/.zshrc
  echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.zshrc
  echo "✅ krew added to PATH."
else
  echo "✅ krew already configured in ~/.zshrc."
fi

# Add krew to PATH in current session
export PATH="${KREW_ROOT}/bin:$PATH"

# === 7. Verify krew installation ===
echo
echo "🧪 Verifying krew installation..."
if [[ -x "$KREW_ROOT/bin/kubectl-krew" ]]; then
  krew_v=$("$KREW_ROOT/bin/kubectl-krew" version 2>/dev/null | grep -o 'GitTag:[^,]*' | cut -d':' -f2 | xargs)
  echo "📌 krew version: $krew_v"
  echo "✅ krew is ready to use."
else
  echo "⚠️  krew binary not found at expected location. Please check installation."
fi

# === 8. Install kubelogin plugin via krew ===
echo
echo "📥 Installing kubelogin (oidc-login) plugin via krew..."

# Update krew index first
echo "🔄 Updating krew plugin index..."
"$KREW_ROOT/bin/kubectl-krew" update

# Install oidc-login plugin (kubelogin)
echo "💻 Installing oidc-login plugin..."
"$KREW_ROOT/bin/kubectl-krew" install oidc-login

if [[ $? -ne 0 ]]; then
  echo "❌ Failed to install kubelogin (oidc-login) plugin."
  exit 1
fi

echo "✅ kubelogin (oidc-login) plugin installed successfully!"

# === 9. Verify kubelogin installation ===
echo
echo "🧪 Verifying kubelogin installation..."
if [[ -x "$KREW_ROOT/bin/kubectl-oidc_login" ]]; then
  kubelogin_v=$("$KREW_ROOT/bin/kubectl-oidc_login" --version 2>/dev/null | head -n 1)
  echo "📌 kubelogin version: $kubelogin_v"
  echo "✅ kubelogin is ready to use."
else
  echo "⚠️  kubelogin binary not found. Please check installation."
fi

# === 10. Final summary ===
echo
echo "═══════════════════════════════════════════════════════════"
echo "✅ Installation Summary:"
echo "───────────────────────────────────────────────────────────"
echo "  • kubectl $kubectl_v - Kubernetes command-line tool"
echo "  • krew $krew_v - kubectl plugin manager"
echo "  • kubelogin (oidc-login) - OIDC authentication plugin"
echo "═══════════════════════════════════════════════════════════"
echo

# === 11. Wrap-up ===
echo "💡 Next steps:"
echo "   • Restart your terminal or run: source ~/.zshrc"
echo "   • Test kubectl: kubectl version --client"
echo "   • List krew plugins: kubectl krew list"
echo "   • Search plugins: kubectl krew search <name>"
echo "   • Install plugins: kubectl krew install <plugin>"
echo "   • Use kubelogin: kubectl oidc-login --help"
echo
echo "📚 Useful commands:"
echo "   kubectl cluster-info                 # Display cluster info"
echo "   kubectl config view                  # Show kubeconfig"
echo "   kubectl krew upgrade                 # Upgrade all plugins"
echo "   kubectl oidc-login setup             # Setup OIDC authentication"
echo
echo "🎉 Installation finished successfully!"

