#!/bin/bash

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
touch /home/runner/.zypper-cleanup-complete
echo "Zypper cleanup complete!"
