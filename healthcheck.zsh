#!/bin/zsh
# === health_check.zsh ===
# Purpose: Comprehensive health check for all macOS Ventura setup installations
# Shell: Zsh (default on macOS Ventura)
# Author: theoneandonlywoj (style inspired)

echo "🏥 macOS Ventura Setup Health Check"
echo "===================================="
echo

# === Configuration ===
LOG_FILE="/tmp/health_check_$(date +%Y%m%d_%H%M%S).log"
ERRORS=0
WARNINGS=0
TOTAL_CHECKS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# === Helper Functions ===
log_check() {
  local check_status="$1"
  local message="$2"
  local details="$3"
  
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  
  case "$check_status" in
    "PASS")
      echo -e "${GREEN}✅ $message${NC}"
      if [[ -n "$details" ]]; then
        echo -e "   ${BLUE}ℹ️  $details${NC}"
      fi
      ;;
    "FAIL")
      echo -e "${RED}❌ $message${NC}"
      if [[ -n "$details" ]]; then
        echo -e "   ${RED}💥 $details${NC}"
      fi
      ERRORS=$((ERRORS + 1))
      ;;
    "WARN")
      echo -e "${YELLOW}⚠️  $message${NC}"
      if [[ -n "$details" ]]; then
        echo -e "   ${YELLOW}⚠️  $details${NC}"
      fi
      WARNINGS=$((WARNINGS + 1))
      ;;
  esac
  
  # Log to file
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$check_status] $message" >> "$LOG_FILE"
  if [[ -n "$details" ]]; then
    echo "  Details: $details" >> "$LOG_FILE"
  fi
}

check_command() {
  local cmd="$1"
  local name="$2"
  local expected_path="$3"
  
  # Special handling for Mise-managed tools
  if [[ "$cmd" == "mix" || "$cmd" == "erl" || "$cmd" == "elixir" ]]; then
    if command -v mise >/dev/null 2>&1; then
      local version=""
      case "$cmd" in
        "mix") 
          if mise exec -- mix --version >/dev/null 2>&1; then
            version=$(mise exec -- mix --version | head -n1)
            log_check "PASS" "$name is installed" "$version"
          else
            log_check "FAIL" "$name is not installed" "Mise exec failed for $cmd"
          fi
          ;;
        "erl")
          # Use a safer method to check Erlang version
          if mise exec -- erl -eval 'io:format("~s", [erlang:system_info(otp_release)]), halt().' -noshell 2>/dev/null | grep -q '[0-9]'; then
            version=$(mise exec -- erl -eval 'io:format("~s", [erlang:system_info(otp_release)]), halt().' -noshell 2>/dev/null | tr -d '\n')
            log_check "PASS" "$name is installed" "Version: $version"
          else
            # Fallback: just check if erl command exists via mise
            if mise exec -- erl -version >/dev/null 2>&1; then
              log_check "PASS" "$name is installed" "Available via Mise"
            else
              log_check "FAIL" "$name is not installed" "Mise exec failed for $cmd"
            fi
          fi
          ;;
        "elixir")
          # Use a safer method to check Elixir version
          if mise exec -- elixir --version >/dev/null 2>&1; then
            version=$(mise exec -- elixir --version 2>/dev/null | grep "Elixir" | head -n1 | awk '{print $2}' || echo "Unknown")
            if [[ -n "$version" && "$version" != "Unknown" ]]; then
              log_check "PASS" "$name is installed" "Version: $version"
            else
              log_check "PASS" "$name is installed" "Available via Mise"
            fi
          else
            log_check "FAIL" "$name is not installed" "Mise exec failed for $cmd"
          fi
          ;;
      esac
    else
      log_check "FAIL" "$name is not installed" "Mise not available for $cmd"
    fi
    return
  fi
  
  # Regular command checking for non-Mise tools
  if command -v "$cmd" >/dev/null 2>&1; then
    local actual_path=$(which "$cmd")
    if [[ -n "$expected_path" && "$actual_path" != "$expected_path" ]]; then
      log_check "WARN" "$name is installed" "Expected: $expected_path, Found: $actual_path"
    else
      local version=""
      case "$cmd" in
        "brew") version=$(brew --version | head -n1) ;;
        "git") version=$(git --version) ;;
        "docker") version=$(docker --version) ;;
        "node") version=$(node --version) ;;
        "emacs") version=$(emacs --version | head -n1) ;;
        "mise") version=$(mise --version | head -n1) ;;
      esac
      log_check "PASS" "$name is installed" "$version"
    fi
  else
    log_check "FAIL" "$name is not installed" "Command '$cmd' not found in PATH"
  fi
}

check_app() {
  local app_path="$1"
  local app_name="$2"
  
  if [[ -d "$app_path" ]]; then
    local version=""
    if [[ -f "$app_path/Contents/Info.plist" ]]; then
      version=$(defaults read "$app_path/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
    fi
    log_check "PASS" "$app_name is installed" "Version: $version"
  else
    log_check "FAIL" "$app_name is not installed" "Not found at $app_path"
  fi
}

check_file() {
  local file_path="$1"
  local file_name="$2"
  local required="$3"
  
  if [[ -f "$file_path" ]]; then
    local size=$(ls -lh "$file_path" | awk '{print $5}')
    log_check "PASS" "$file_name exists" "Size: $size"
  else
    if [[ "$required" == "true" ]]; then
      log_check "FAIL" "$file_name is missing" "Required file not found at $file_path"
    else
      log_check "WARN" "$file_name is missing" "Optional file not found at $file_path"
    fi
  fi
}

check_directory() {
  local dir_path="$1"
  local dir_name="$2"
  local required="$3"
  
  if [[ -d "$dir_path" ]]; then
    local count=$(find "$dir_path" -type f | wc -l | tr -d ' ')
    log_check "PASS" "$dir_name exists" "Contains $count files"
  else
    if [[ "$required" == "true" ]]; then
      log_check "FAIL" "$dir_name is missing" "Required directory not found at $dir_path"
    else
      log_check "WARN" "$dir_name is missing" "Optional directory not found at $dir_path"
    fi
  fi
}

# === System Information ===
echo "🖥️  System Information"
echo "----------------------"
log_check "PASS" "macOS Version" "$(sw_vers -productName) $(sw_vers -productVersion)"
log_check "PASS" "Architecture" "$(uname -m)"
log_check "PASS" "Shell" "$SHELL"
log_check "PASS" "User" "$(whoami)"
echo

# === Core & Development Tools / Script Success Verification ===
echo "🔧 Essential Tools and Applications"
echo "-----------------------------------"

# CLI Tools (core/development)
check_command "brew" "Homebrew" "/opt/homebrew/bin/brew"
check_command "git" "Git"
check_command "curl" "cURL"
check_command "wget" "Wget" # Optional
check_command "mise" "Mise (Version Manager)"
check_command "node" "Node.js"
check_command "python3" "Python 3" # Optional
custom_check_docker
check_command "docker-compose" "Docker Compose"
check_command "gh" "GitHub CLI"
check_command "podman" "Podman"
# Elixir/Erlang/Mix (handles Mise)
check_command "mix" "Mix (Elixir)"
check_command "elixir" "Elixir"
check_command "erl" "Erlang"

echo
# GUI Apps
echo "📱 Applications"
echo "--------------"
check_app "/Applications/Google Chrome.app" "Google Chrome"
check_app "/Applications/Slack.app" "Slack"
check_app "/Applications/Cursor.app" "Cursor IDE"
check_app "/Applications/iTerm.app" "iTerm2"
check_app "/Applications/Emacs.app" "Emacs"
check_app "/Applications/DBeaver.app" "DBeaver"
check_app "/Applications/Postman.app" "Postman"
check_app "/Applications/1Password.app" "1Password"

echo

# === Shell Configuration ===
echo "🐚 Shell Configuration"
echo "---------------------"
check_file "$HOME/.zshrc" "Zsh Configuration" "true"
check_file "$HOME/.zprofile" "Zsh Profile" "false"
check_file "$HOME/.oh-my-zsh/oh-my-zsh.sh" "Oh My Zsh" "false"
check_file "$HOME/.p10k.zsh" "Powerlevel10k Config" "false"
check_directory "$HOME/.oh-my-zsh" "Oh My Zsh Directory" "false"
check_directory "$HOME/.oh-my-zsh/custom" "Oh My Zsh Custom" "false"
echo

# === SSH Configuration ===
echo "🔐 SSH Configuration"
echo "-------------------"
check_file "$HOME/.ssh/id_ed25519" "SSH Private Key" "false"
check_file "$HOME/.ssh/id_ed25519.pub" "SSH Public Key" "false"
check_file "$HOME/.ssh/config" "SSH Config" "false"
echo

# === Mise Configuration ===
echo "🔧 Mise Configuration"
echo "--------------------"
check_file "$HOME/.config/mise/config.toml" "Mise Global Config" "false"
check_file "mise.toml" "Mise Project Config" "false"
check_directory "$HOME/.local/share/mise" "Mise Data Directory" "false"
echo

# === Doom Emacs Configuration ===
echo "🧠 Doom Emacs Configuration"
echo "--------------------------"
check_directory "$HOME/.emacs.d" "Doom Emacs Directory" "false"
check_directory "$HOME/.doom.d" "Doom Config Directory" "false"
check_file "$HOME/.emacs.d/bin/doom" "Doom Binary" "false"
echo

# === Dock Configuration ===
echo "🧭 Dock Configuration"
echo "--------------------"
check_file "$HOME/Desktop/com.apple.dock.backup.plist" "Dock Backup" "false"
check_file "$HOME/Desktop/com.apple.dock.backup.cursor.plist" "Cursor Dock Backup" "false"
echo

# === Environment Variables ===
echo "🌍 Environment Variables"
echo "-----------------------"
if [[ -n "$PATH" ]]; then
  log_check "PASS" "PATH is set" "Length: ${#PATH} characters"
else
  log_check "FAIL" "PATH is not set" "Critical environment variable missing"
fi

if [[ -n "$HOME" ]]; then
  log_check "PASS" "HOME is set" "$HOME"
else
  log_check "FAIL" "HOME is not set" "Critical environment variable missing"
fi

if [[ -n "$SHELL" ]]; then
  log_check "PASS" "SHELL is set" "$SHELL"
else
  log_check "WARN" "SHELL is not set" "Shell environment variable missing"
fi
echo

# === Network Connectivity ===
echo "🌐 Network Connectivity"
echo "----------------------"
if ping -c 1 google.com >/dev/null 2>&1; then
  log_check "PASS" "Internet connectivity" "Can reach google.com"
else
  log_check "FAIL" "Internet connectivity" "Cannot reach google.com"
fi

if ping -c 1 github.com >/dev/null 2>&1; then
  log_check "PASS" "GitHub connectivity" "Can reach github.com"
else
  log_check "WARN" "GitHub connectivity" "Cannot reach github.com"
fi
echo

# === File Permissions ===
echo "🔒 File Permissions"
echo "------------------"
if [[ -r "$HOME/.zshrc" ]]; then
  log_check "PASS" "Zsh config readable" "~/.zshrc is readable"
else
  log_check "FAIL" "Zsh config readable" "~/.zshrc is not readable"
fi

if [[ -w "$HOME/.zshrc" ]]; then
  log_check "PASS" "Zsh config writable" "~/.zshrc is writable"
else
  log_check "WARN" "Zsh config writable" "~/.zshrc is not writable"
fi

if [[ -x "$HOME/.oh-my-zsh" ]]; then
  log_check "PASS" "Oh My Zsh executable" "~/.oh-my-zsh is executable"
else
  log_check "WARN" "Oh My Zsh executable" "~/.oh-my-zsh is not executable"
fi
echo

# === Performance Check ===
echo "⚡ Performance Check"
echo "-------------------"
# Check disk space
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [[ $disk_usage -lt 80 ]]; then
  log_check "PASS" "Disk space" "Usage: ${disk_usage}% (Good)"
elif [[ $disk_usage -lt 90 ]]; then
  log_check "WARN" "Disk space" "Usage: ${disk_usage}% (Getting full)"
else
  log_check "FAIL" "Disk space" "Usage: ${disk_usage}% (Critical)"
fi

# Check memory
memory_usage=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
if [[ $memory_usage -gt 1000000 ]]; then
  log_check "PASS" "Memory" "Free pages: $memory_usage (Good)"
else
  log_check "WARN" "Memory" "Free pages: $memory_usage (Low)"
fi
echo

# === Summary ===
echo "📊 Health Check Summary"
echo "======================="
echo -e "Total checks: ${BLUE}$TOTAL_CHECKS${NC}"
echo -e "Passed: ${GREEN}$((TOTAL_CHECKS - ERRORS - WARNINGS))${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo

if [[ $ERRORS -eq 0 ]]; then
  if [[ $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}🎉 All systems are healthy! No issues found.${NC}"
  else
    echo -e "${YELLOW}⚠️  System is mostly healthy with $WARNINGS warning(s).${NC}"
  fi
else
  echo -e "${RED}❌ System has $ERRORS error(s) that need attention.${NC}"
fi

echo
echo "📋 Detailed log saved to: $LOG_FILE"
echo "💡 Run specific checks by examining the log file for details."

# === Recommendations ===
if [[ $ERRORS -gt 0 || $WARNINGS -gt 0 ]]; then
  echo
  echo "🔧 Recommendations:"
  echo "------------------"
  
  if [[ $ERRORS -gt 0 ]]; then
    echo "❌ Critical issues to fix:"
    grep "\[FAIL\]" "$LOG_FILE" | sed 's/.*\[FAIL\] /  • /'
  fi
  
  if [[ $WARNINGS -gt 0 ]]; then
    echo "⚠️  Warnings to consider:"
    grep "\[WARN\]" "$LOG_FILE" | sed 's/.*\[WARN\] /  • /'
  fi
fi

echo
echo "🏥 Health check complete!"
