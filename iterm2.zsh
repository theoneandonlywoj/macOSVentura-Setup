#!/bin/zsh
# === iterm2.zsh ===
# Purpose: Install iTerm2 + Oh My Zsh + popular themes on macOS Ventura
# Shell: Zsh (default on macOS Ventura)
# Author: theoneandonlywoj

echo "🚀 Starting iTerm2 + Oh My Zsh + Themes installation on macOS Ventura..."
echo

# === Configuration ===
iterm2_app="/Applications/iTerm.app"
oh_my_zsh_dir="$HOME/.oh-my-zsh"
zshrc_file="$HOME/.zshrc"
brew_path="/opt/homebrew/bin/brew"

# Popular themes to install
themes=(
    "powerlevel10k/powerlevel10k"
    "romkatv/powerlevel10k"
    "ohmyzsh/ohmyzsh"
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-completions"
)

echo "📦 Target iTerm2: $iterm2_app"
echo "📂 Oh My Zsh directory: $oh_my_zsh_dir"
echo "🎨 Installing themes: ${themes[*]}"
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

# === 2. Install iTerm2 ===
echo
echo "📥 Installing iTerm2..."
if [[ -d "$iterm2_app" ]]; then
  echo "✅ iTerm2 already installed."
else
  if command -v brew >/dev/null 2>&1; then
    brew install --cask iterm2
    if [[ $? -ne 0 ]]; then
      echo "❌ Failed to install iTerm2 via Homebrew."
      exit 1
    fi
  else
    echo "❌ Homebrew not available for iTerm2 installation."
    exit 1
  fi
fi

# === 3. Verify iTerm2 installation ===
if [[ -d "$iterm2_app" ]]; then
  echo "✅ iTerm2 successfully installed."
else
  echo "❌ iTerm2 installation failed."
  exit 1
fi

# === 4. Install Oh My Zsh ===
echo
echo "🧠 Installing Oh My Zsh..."
if [[ -d "$oh_my_zsh_dir" ]]; then
  echo "ℹ️  Oh My Zsh already exists. Updating..."
  cd "$oh_my_zsh_dir"
  git pull
  cd - > /dev/null
else
  echo "📥 Cloning Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  if [[ $? -ne 0 ]]; then
    echo "❌ Failed to install Oh My Zsh."
    exit 1
  fi
fi

# === 5. Install Powerlevel10k theme ===
echo
echo "🎨 Installing Powerlevel10k theme..."
powerlevel10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ -d "$powerlevel10k_dir" ]]; then
  echo "ℹ️  Powerlevel10k already installed. Updating..."
  git -C "$powerlevel10k_dir" pull
else
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$powerlevel10k_dir"
  if [[ $? -ne 0 ]]; then
    echo "❌ Failed to install Powerlevel10k theme."
    exit 1
  fi
fi

# === 6. Install additional plugins ===
echo
echo "🔌 Installing additional Zsh plugins..."

# zsh-syntax-highlighting
syntax_highlighting_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [[ ! -d "$syntax_highlighting_dir" ]]; then
  echo "📥 Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$syntax_highlighting_dir"
fi

# zsh-autosuggestions
autosuggestions_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [[ ! -d "$autosuggestions_dir" ]]; then
  echo "📥 Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$autosuggestions_dir"
fi

# zsh-completions
completions_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions"
if [[ ! -d "$completions_dir" ]]; then
  echo "📥 Installing zsh-completions..."
  git clone https://github.com/zsh-users/zsh-completions.git "$completions_dir"
fi

# === 7. Configure .zshrc ===
echo
echo "⚙️  Configuring .zshrc..."

# Backup existing .zshrc
if [[ -f "$zshrc_file" ]]; then
  cp "$zshrc_file" "${zshrc_file}.backup.$(date +%Y%m%d_%H%M%S)"
  echo "💾 Backed up existing .zshrc"
fi

# Create optimized .zshrc
cat > "$zshrc_file" << 'EOF'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
plugins=(
  git
  brew
  macos
  docker
  docker-compose
  vscode
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-completions
  colored-man-pages
  command-not-found
  extract
  history-substring-search
  web-search
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# User configuration
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS

# Auto-completion
autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

# Initialize Mise (language version manager) if available
if command -v mise >/dev/null 2>&1; then
  eval "$(/usr/local/bin/mise activate zsh)"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

echo "✅ .zshrc configured with Powerlevel10k and plugins"

# === 8. Install additional fonts (optional) ===
echo
echo "🔤 Installing Nerd Fonts for better icon support..."
if command -v brew >/dev/null 2>&1; then
  # Install popular Nerd Fonts
  brew tap homebrew/cask-fonts
  brew install --cask font-meslo-lg-nerd-font
  brew install --cask font-fira-code-nerd-font
  brew install --cask font-hack-nerd-font
  echo "✅ Nerd Fonts installed"
else
  echo "⚠️  Homebrew not available for font installation"
fi

# === 9. Create iTerm2 profile configuration ===
echo
echo "🎨 Setting up iTerm2 profile configuration..."

# Create iTerm2 profiles directory
iterm2_profiles_dir="$HOME/Library/Preferences"
mkdir -p "$iterm2_profiles_dir"

# Create a basic iTerm2 profile (this is a simplified version)
cat > "$iterm2_profiles_dir/com.googlecode.iterm2.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>New Bookmarks</key>
    <array>
        <dict>
            <key>Name</key>
            <string>Default</string>
            <key>Font</key>
            <string>MesloLGS Nerd Font</string>
            <key>Font Size</key>
            <real>12</real>
            <key>Use Bold Font</key>
            <true/>
            <key>Use Bright Bold</key>
            <true/>
            <key>Use Italic Font</key>
            <true/>
            <key>Use Non-ASCII Font</key>
            <true/>
            <key>Non-ASCII Font</key>
            <string>MesloLGS Nerd Font</string>
            <key>Non-ASCII Font Size</key>
            <real>12</real>
            <key>Background Color</key>
            <dict>
                <key>Red Component</key>
                <real>0.0</real>
                <key>Green Component</key>
                <real>0.0</real>
                <key>Blue Component</key>
                <real>0.0</real>
            </dict>
            <key>Foreground Color</key>
            <dict>
                <key>Red Component</key>
                <real>0.8</real>
                <key>Green Component</key>
                <real>0.8</real>
                <key>Blue Component</key>
                <real>0.8</real>
            </dict>
        </dict>
    </array>
</dict>
</plist>
EOF

echo "✅ iTerm2 profile configuration created"

# === 10. Verification ===
echo
echo "🧪 Verifying installation..."

# Check iTerm2
if [[ -d "$iterm2_app" ]]; then
  echo "✅ iTerm2: Installed"
else
  echo "❌ iTerm2: Not found"
fi

# Check Oh My Zsh
if [[ -d "$oh_my_zsh_dir" ]]; then
  echo "✅ Oh My Zsh: Installed"
else
  echo "❌ Oh My Zsh: Not found"
fi

# Check Powerlevel10k
if [[ -d "$powerlevel10k_dir" ]]; then
  echo "✅ Powerlevel10k: Installed"
else
  echo "❌ Powerlevel10k: Not found"
fi

# Check plugins
plugins_status=0
for plugin in "zsh-syntax-highlighting" "zsh-autosuggestions" "zsh-completions"; do
  plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin"
  if [[ -d "$plugin_dir" ]]; then
    echo "✅ Plugin $plugin: Installed"
  else
    echo "❌ Plugin $plugin: Not found"
    plugins_status=1
  fi
done

# === 11. Wrap-up ===
echo
echo "🎉 iTerm2 + Oh My Zsh + Themes installation complete!"
echo
echo "💡 Next steps:"
echo "   • Launch iTerm2: open -a iTerm"
echo "   • Configure Powerlevel10k: p10k configure"
echo "   • Restart terminal or run: source ~/.zshrc"
echo "   • Install additional themes: oh-my-zsh/tree/master/themes"
echo
echo "🔧 Configuration files:"
echo "   • Zsh config: ~/.zshrc"
echo "   • Powerlevel10k config: ~/.p10k.zsh (will be created on first run)"
echo "   • iTerm2 profiles: ~/Library/Preferences/com.googlecode.iterm2.plist"
echo
echo "🎨 Available themes:"
echo "   • Powerlevel10k (default, run 'p10k configure')"
echo "   • Many others in ~/.oh-my-zsh/themes/"
echo
echo "✨ Happy terminal customization!"
