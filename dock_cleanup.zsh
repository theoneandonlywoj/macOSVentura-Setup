#!/bin/zsh
# === dock_cleanup.zsh ===
# Purpose: Safely remove specific default macOS apps from Dock (Ventura) using dockutil
# Author: theoneandonlywoj
# Requirements: brew install dockutil

apps_to_remove=(
  "Siri"
  "Safari"
  "Mail"
  "Contacts"
  "Maps"
  "Photos"
  "Messages"
  "FaceTime"
  "Music"
  "Books"
)

backup_plist=~/Desktop/com.apple.dock.backup.plist

echo "🚀 Starting Dock cleanup with dockutil..."

# Check if dockutil is installed
if ! command -v dockutil >/dev/null 2>&1; then
  echo "⚠️  dockutil not found! Install with: brew install dockutil"
  exit 1
fi

# Backup current Dock plist
echo "💾 Backing up current Dock plist to $backup_plist..."
cp ~/Library/Preferences/com.apple.dock.plist "$backup_plist"
if [[ $? -eq 0 ]]; then
  echo "✅ Backup complete!"
else
  echo "⚠️  Backup failed, aborting."
  exit 1
fi

removed_apps=()
skipped_apps=()

# Loop through apps and remove if present
for app in $apps_to_remove; do
  if dockutil --find "$app" >/dev/null 2>&1; then
    echo "🗑️  Removing $app from Dock..."
    dockutil --remove "$app" --no-restart
    removed_apps+=("$app")
  else
    skipped_apps+=("$app")
  fi
done

# Restart Dock to apply changes
killall Dock

# Summary
echo
echo "✨ Dock cleanup complete!"
echo "📌 Summary:"
echo "   ✅ Removed apps:"
for app in ${(u)removed_apps}; do
  echo "      • $app"
done
echo "   ℹ️ Skipped apps (not found in Dock):"
for app in ${(u)skipped_apps}; do
  echo "      • $app"
done

echo
echo "📂 Backup saved at: $backup_plist"
echo "🧭 To restore, run:"
echo "   defaults import com.apple.dock $backup_plist && killall Dock"
echo
echo "🚀 Enjoy your minimalist Dock!"

