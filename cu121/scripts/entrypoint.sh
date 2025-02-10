#!/bin/bash

set -uxo pipefail  # Enable strict error handling

# Install ComfyUI
cd /home/runner || true
if [ ! -f "/home/runner/.download-complete" ] ; then
    chmod +x /home/scripts/download.sh
    bash /home/scripts/download.sh || true
fi ;

# Start File Browser
# Define environment variables for the File Browser configuration
FILEBROWSER_CONFIG_DIR="/home/runner/filebrowser"
UPLOAD_DIRECTORY="/home/runner/ComfyUI"

if [ -n "${FILEBROWSER_USER:-}" ] && [ -n "${FILEBROWSER_PASS:-}" ]; then
    if [ ! -f "/home/runner/.browser-complete" ] ; then
        # Create the necessary directories
        mkdir -p $FILEBROWSER_CONFIG_DIR
        mkdir -p $UPLOAD_DIRECTORY

        # Initialize File Browser configuration
        echo "Initializing File Browser configuration..."
        filebrowser config init --database $FILEBROWSER_CONFIG_DIR/filebrowser.db
        filebrowser -d --database $FILEBROWSER_CONFIG_DIR/filebrowser.db config set --log /home/runner/filebrowser.log
        # Add or update the admin user for File Browser
        echo "Adding or updating admin user in File Browser..."
        filebrowser users update $FILEBROWSER_USER --database $FILEBROWSER_CONFIG_DIR/filebrowser.db --perm.admin || \
        filebrowser users add $FILEBROWSER_USER $FILEBROWSER_PASS --database $FILEBROWSER_CONFIG_DIR/filebrowser.db --perm.admin

        # Start File Browser
        echo "Starting File Browser..."
        nohup filebrowser -a 0.0.0.0 -r $UPLOAD_DIRECTORY -p 8080 --database $FILEBROWSER_CONFIG_DIR/filebrowser.db &
        touch /home/runner/.browser-complete
        # Wait for a few seconds to ensure File Browser starts properly
        sleep 5
    fi ;
else
    echo "FILEBROWSER_USER or FILEBROWSER_PASS is not set or is empty"
fi ;


# Run user's pre-start script
cd /home/runner || true
if [ -f "/home/runner/scripts/pre-start.sh" ] ; then
    echo "[INFO] Running pre-start script..."
    chmod +x /home/runner/scripts/pre-start.sh
    source /home/runner/scripts/pre-start.sh
else
    echo "[INFO] No pre-start script found. Skipping."
fi ;


# Download mmodels
cd /home/runner || true
if [ ! -f "/home/runner/.download-models-complete" ] ; then
    chmod +x /home/scripts/download-models.sh
#    bash /home/scripts/download-models.sh || true
    nohup bash /home/scripts/download-models.sh > /home/runner/download.log 2>&1 &
fi ;

export PATH="${PATH}:/home/runner/.local/bin"
export PYTHONPYCACHEPREFIX="/home/runner/.cache/pycache"

cd /home/runner || true

# Cleanup
if [ ! -f "/home/runner/.zypper-cleanup-complete" ] ; then
    echo "[INFO] Running zypper-cleanup script..."
    chmod +x /home/scripts/zypper-cleanup.sh
    bash /home/scripts/zypper-cleanup.sh || true
fi ;

cd /home/runner  || true
if [ ! -f "/home/runner/.download-zip-complete" ] ; then
    echo "[INFO] Running download-and-extract script..."
    chmod +x /home/scripts/download-and-extract.sh
    bash /home/scripts/download-and-extract.sh || true
fi ;

# Retry loop to restart ComfyUI if it fails
while true; do
    echo "[INFO] Starting ComfyUI..."
    exec python3 ./ComfyUI/main.py --listen --port 8188 ${CLI_ARGS}
    echo "ComfyUI crashed, restarting..."
    sleep 5  # Optionally wait before restarting
done
#CMD ["tail", "-f", "/dev/null"]
