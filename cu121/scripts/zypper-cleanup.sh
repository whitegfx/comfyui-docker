#!/bin/bash

set -uxo pipefail  # Enable strict error handling

echo "Starting zypper cleanup..."

# 1. Clean package cache
echo "Cleaning package cache..."
zypper clean --all

# 2. Remove orphaned packages
echo "Removing orphaned packages..."
orphans=$(zypper packages --orphaned | awk 'NR>2 {print $5}')
if [[ -n "$orphans" ]]; then
    zypper remove --clean-deps $orphans
else
    echo "No orphaned packages found."
fi

# 3. Remove old snapshots (for Btrfs users)
if [ -d "/.snapshots" ]; then
    echo "Cleaning old Btrfs snapshots..."
    snapper list
    read -p "Enter snapshot numbers to delete (e.g., 5 6 7) or press Enter to skip: " snapshots
    if [[ -n "$snapshots" ]]; then
        snapper delete $snapshots
    else
        echo "Skipping snapshot cleanup."
    fi
else
    echo "Btrfs not detected, skipping snapshot cleanup."
fi

# 4. Uninstall Go
if command -v go &>/dev/null; then
    echo "Uninstalling Go to free up space..."
    rm -rf /usr/local/go
    sed -i '/export PATH=\$PATH:\/usr\/local\/go\/bin/d' ~/.bashrc
else
    echo "Go is not installed, skipping removal."
fi

# 5. Uninstall Node.js & npm
if command -v node &>/dev/null || command -v npm &>/dev/null; then
    echo "Uninstalling Node.js and npm..."
    zypper remove --clean-deps -y nodejs npm
else
    echo "Node.js is not installed, skipping removal."
fi

# 6. Remove pnpm (if installed via curl)
if [ -f ~/.local/bin/pnpm ]; then
    echo "Removing pnpm..."
    rm -rf ~/.local/share/pnpm ~/.local/bin/pnpm ~/.pnpm-store
else
    echo "pnpm is not installed, skipping removal."
fi

touch /home/runner/.zypper-cleanup-complete
echo "Zypper cleanup complete!"
