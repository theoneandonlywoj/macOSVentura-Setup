#!/bin/zsh
# === cursor_ide.zsh ===
# Purpose: Install Cursor AI code editor on macOS Ventura and add to Dock after Slack
# Shell: Zsh (default on macOS Ventura)
# Author: theoneandonlywoj

echo "🚀 Starting installation of Cursor AI (the vibe-coding editor) on macOS Ventura..."
echo

# === Configuration ===
cursor_dmg_url="https://api2.cursor.sh/updates/download/golden/darwin-x64/cursor/1.7"
cursor_dmg_tmp="/tmp/CursorAI.dmg"
cursor_app="/Applications/Cursor.app"
dock_add="yes"                                             # set to "yes" to add to Dock
dock_after_app="Slack"                                     # Dock app after which Cursor should appear
echo "📌 Will download from: $cursor_dmg_url"
echo "📂 Target installation path: $cursor_app"
echo "🎯 Add to Dock?   $dock_add (after $dock_after_app)"
echo

# === 1. Check if Cursor is already installed ===
if [[ -d "$cursor_app" ]]; then
  echo "✅ Cursor is already installed at $cursor_app"
else
  # === 2. Download the DMG installer ===
  echo "📥 Downloading Cursor DMG..."
  curl -L -o "$cursor_dmg_tmp" "$cursor_dmg_url"
  if [[ $? -ne 0 ]]; then
    echo "❌ Failed to download Cursor DMG."
    exit 1
  fi

  # === 3. Attempt to mount DMG, fallback if ZIP ===
  echo "💿 Mounting or extracting installer..."

  # Try mounting DMG
  mount_output=$(hdiutil attach "$cursor_dmg_tmp" -nobrowse 2>/dev/null)
  if [[ $? -eq 0 ]]; then
    volume_path=$(echo "$mount_output" | grep -o "/Volumes/[^$]*" | head -n1)
    if [[ -d "$volume_path/Cursor.app" ]]; then
      echo "📁 Installing Cursor from mounted volume: $volume_path"
      cp -R "$volume_path/Cursor.app" /Applications/
      echo "✅ Cursor installed into /Applications"
    else
      echo "⚠️ Could not find Cursor.app inside mounted volume. Checking for ZIP fallback..."
      hdiutil detach "$volume_path" -quiet
      unzip -q "$cursor_dmg_tmp" -d /tmp/cursor_extract
      if [[ -d /tmp/cursor_extract/Cursor.app ]]; then
        echo "📦 Copying Cursor.app to /Applications..."
        cp -R /tmp/cursor_extract/Cursor.app /Applications/
      else
        echo "❌ Cursor.app not found in the archive."
        rm -rf /tmp/cursor_extract "$cursor_dmg_tmp"
        exit 1
      fi
      rm -rf /tmp/cursor_extract
    fi
    echo "🧹 Cleaning up..."
    hdiutil detach "$volume_path" -quiet
    rm -f "$cursor_dmg_tmp"
    echo "✅ DMG unmounted and removed"
  else
    echo "⚠️ DMG mount failed — treating file as ZIP or direct app bundle..."
    mkdir -p /tmp/cursor_extract
    unzip -q "$cursor_dmg_tmp" -d /tmp/cursor_extract
    if [[ -d /tmp/cursor_extract/Cursor.app ]]; then
      echo "📦 Copying Cursor.app to /Applications..."
      cp -R /tmp/cursor_extract/Cursor.app /Applications/
    else
      echo "❌ Could not find Cursor.app inside the downloaded archive."
      rm -rf /tmp/cursor_extract "$cursor_dmg_tmp"
      exit 1
    fi
    rm -rf /tmp/cursor_extract
    rm -f "$cursor_dmg_tmp"
    echo "✅ Cursor installed and temporary files removed"
  fi

  # === 4. Copy application into /Applications ===
  echo "🧩 Installing Cursor..."
  cp -R "/Volumes/$volume_name/Cursor.app" /Applications/
  if [[ $? -ne 0 ]]; then
    echo "❌ Failed to copy Cursor.app into /Applications."
    hdiutil detach "/Volumes/$volume_name" -quiet
    rm -f "$cursor_dmg_tmp"
    exit 1
  fi
  echo "✅ Cursor installed into /Applications"

  # === 5. Clean up installer ===
  echo "🧹 Cleaning up..."
  hdiutil detach "/Volumes/$volume_name" -quiet
  rm -f "$cursor_dmg_tmp"
  echo "✅ DMG unmounted and installer removed"
fi

# === 6. Optionally add Cursor to Dock after Slack ===
if [[ "$dock_add" = "yes" ]]; then
  echo
  echo "🧭 Configuring Dock to include Cursor after $dock_after_app..."

  # Backup current Dock preferences
  defaults export com.apple.dock - > ~/Desktop/com.apple.dock.backup.cursor.plist 2>/dev/null
  echo "💾 Dock preference backup saved to ~/Desktop/com.apple.dock.backup.cursor.plist"

  # Build new Dock array
  dock_apps=($(defaults read com.apple.dock persistent-apps | grep _CFURLString | awk -F'"' '{print $2}'))
  new_dock=()
  inserted=false

  for app_path in "${dock_apps[@]}"; do
    new_dock+=("$app_path")
    if [[ "$app_path" == *"$dock_after_app.app"* && "$inserted" = false ]]; then
      new_dock+=("$cursor_app")
      inserted=true
    fi
  done

  if [[ "$inserted" = false ]]; then
    echo "⚠️ Target app ($dock_after_app) not found in Dock. Adding Cursor at the end."
    new_dock+=("$cursor_app")
  fi

  # Clear existing Dock apps and rewrite
  defaults write com.apple.dock persistent-apps -array
  for app in "${new_dock[@]}"; do
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict><key>tile-type</key><string>file-tile</string></dict>"
  done

  # Restart Dock
  echo "🔄 Restarting Dock..."
  killall Dock 2>/dev/null
  echo "✅ Dock updated"
fi

# === 7. Verification and wrap-up ===
echo
echo "🧪 Verifying installation..."
if [[ -d "$cursor_app" ]]; then
  echo "✅ Cursor installation confirmed at $cursor_app"
  if [[ "$dock_add" = "yes" ]]; then
    echo "📍 Cursor should now appear in your Dock after $dock_after_app."
  fi
else
  echo "❌ Cursor installation failed. Please check the error logs above."
  exit 1
fi

echo
echo "🎉 Cursor AI installation complete!"
echo
echo "💡 Next steps:"
echo "   • Launch Cursor via Launchpad or Spotlight (⌘ Space → 'Cursor')"
echo "   • Enjoy your AI-powered coding environment!"

