#!/bin/zsh
# === wget.zsh ===
# Purpose: Install wget on macOS Ventura
# Shell: Zsh (default on macOS Ventura)
# Author: theoneandonlywoj

echo "🌐 Starting wget installation on macOS Ventura..."
echo

# === Configuration ===
wget_binary="/usr/local/bin/wget"
brew_path="/opt/homebrew/bin/brew"

echo "📦 Target binary: $wget_binary"
echo

# === 1. Check if wget is already installed ===
if command -v wget >/dev/null 2>&1; then
  current_version=$(wget --version | head -n1)
  echo "✅ wget is already installed!"
  echo "   $current_version"
  echo
  echo "💡 To update wget, run: brew upgrade wget"
  echo "🎉 Nothing to do!"
  exit 0
fi

# === 2. Check and install Homebrew if missing ===
if ! command -v brew >/dev/null 2>&1; then
  echo "⚙️  Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "💡 Adding Homebrew to PATH..."
  if [[ -d "/opt/homebrew/bin" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -d "/usr/local/bin" ]]; then
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  echo "✅ Homebrew installed."
else
  echo "✅ Homebrew already installed."
fi

# === 3. Install wget via Homebrew ===
echo
echo "📥 Installing wget via Homebrew..."
if brew list wget &>/dev/null; then
  echo "✅ wget is already installed via Homebrew."
else
  brew install wget
  if [[ $? -ne 0 ]]; then
    echo "❌ Failed to install wget via Homebrew."
    echo "💡 Trying alternative installation method..."
    
    # === 4. Alternative: Install via MacPorts (if available) ===
    if command -v port >/dev/null 2>&1; then
      echo "📦 Installing wget via MacPorts..."
      sudo port install wget
      if [[ $? -eq 0 ]]; then
        echo "✅ wget installed via MacPorts."
      else
        echo "❌ Failed to install wget via MacPorts."
        exit 1
      fi
    else
      # === 5. Alternative: Manual compilation ===
      echo "🔨 Installing wget via manual compilation..."
      
      # Create temporary directory
      temp_dir="/tmp/wget_install_$(date +%Y%m%d_%H%M%S)"
      mkdir -p "$temp_dir"
      cd "$temp_dir"
      
      # Download wget source
      echo "⬇️  Downloading wget source code..."
      wget_url="https://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz"
      curl -L -o wget.tar.gz "$wget_url"
      
      if [[ $? -ne 0 ]]; then
        echo "❌ Failed to download wget source."
        rm -rf "$temp_dir"
        exit 1
      fi
      
      # Extract and compile
      echo "📦 Extracting wget source..."
      tar -xzf wget.tar.gz
      cd wget-*
      
      echo "🔧 Configuring wget..."
      ./configure --prefix=/usr/local
      
      echo "🔨 Compiling wget..."
      make
      
      if [[ $? -ne 0 ]]; then
        echo "❌ Failed to compile wget."
        rm -rf "$temp_dir"
        exit 1
      fi
      
      echo "📥 Installing wget..."
      sudo make install
      
      if [[ $? -ne 0 ]]; then
        echo "❌ Failed to install wget."
        rm -rf "$temp_dir"
        exit 1
      fi
      
      # Cleanup
      cd /
      rm -rf "$temp_dir"
      echo "✅ wget installed via manual compilation."
    fi
  fi
fi

# === 6. Verify installation ===
echo
echo "🧪 Verifying wget installation..."
if command -v wget >/dev/null 2>&1; then
  wget_version=$(wget --version | head -n1)
  wget_path=$(which wget)
  echo "✅ wget successfully installed!"
  echo "   Version: $wget_version"
  echo "   Location: $wget_path"
else
  echo "❌ wget installation failed."
  echo "💡 Please check the error messages above and try again."
  exit 1
fi

# === 7. Test wget functionality ===
echo
echo "🧪 Testing wget functionality..."
test_url="https://httpbin.org/get"
test_file="/tmp/wget_test_$(date +%Y%m%d_%H%M%S).txt"

if wget -q -O "$test_file" "$test_url" 2>/dev/null; then
  if [[ -f "$test_file" && -s "$test_file" ]]; then
    echo "✅ wget test successful!"
    echo "   Downloaded test file: $test_file"
    rm -f "$test_file"
  else
    echo "⚠️  wget test completed but file is empty or missing."
  fi
else
  echo "⚠️  wget test failed, but installation may still be working."
  echo "   This could be due to network issues or the test URL being unavailable."
fi

# === 8. Add to PATH if needed ===
echo
echo "🔧 Checking PATH configuration..."
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
  echo "💡 Adding /usr/local/bin to PATH..."
  echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
  echo "✅ PATH updated in ~/.zshrc"
  echo "💡 Restart your terminal or run 'source ~/.zshrc' to apply changes."
else
  echo "✅ /usr/local/bin is already in PATH."
fi

# === 9. Show usage examples ===
echo
echo "💡 wget usage examples:"
echo "   • Download a file: wget https://example.com/file.zip"
echo "   • Download with progress: wget --progress=bar https://example.com/file.zip"
echo "   • Download to specific location: wget -O /path/to/file.zip https://example.com/file.zip"
echo "   • Resume interrupted download: wget -c https://example.com/file.zip"
echo "   • Download recursively: wget -r https://example.com/"
echo "   • Show help: wget --help"

# === 10. Wrap-up ===
echo
echo "🎉 wget installation complete!"
echo
echo "📚 Additional information:"
echo "   • wget is a command-line utility for downloading files from the web"
echo "   • It's particularly useful for downloading files in scripts and automation"
echo "   • wget supports HTTP, HTTPS, and FTP protocols"
echo "   • For more advanced features, see: man wget"
echo
echo "✨ Happy downloading!"
