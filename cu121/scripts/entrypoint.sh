#!/bin/bash

set -euxo pipefail

#echo "An error occurred" >&2

# Run user's set-proxy script
cd /home/runner
if [ -f "/home/runner/scripts/set-proxy.sh" ] ; then
    echo "[INFO] Running set-proxy script..."

    chmod +x /home/runner/scripts/set-proxy.sh
    source /home/runner/scripts/set-proxy.sh
fi ;

# Install ComfyUI
cd /home/runner
if [ ! -f "/home/runner/.download-complete" ] ; then
    chmod +x /home/scripts/download.sh
    bash /home/scripts/download.sh
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

        # Add or update the admin user for File Browser
        echo "Adding or updating admin user in File Browser..."
        filebrowser users update $FILEBROWSER_USER $FILEBROWSER_PASS --database $FILEBROWSER_CONFIG_DIR/filebrowser.db --perm.admin || \
        filebrowser users add $FILEBROWSER_USER $FILEBROWSER_PASS --database $FILEBROWSER_CONFIG_DIR/filebrowser.db --perm.admin

        # Start File Browser
        echo "Starting File Browser..."
        nohup filebrowser -a 0.0.0.0 -r $UPLOAD_DIRECTORY --database $FILEBROWSER_CONFIG_DIR/filebrowser.db &
        touch /home/runner/.browser-complete
        # Wait for a few seconds to ensure File Browser starts properly
        sleep 5
    fi ;
else
    echo "FILEBROWSER_USER or FILEBROWSER_PASS is not set or is empty"
fi ;


# Run user's pre-start script
cd /home/runner
if [ -f "/home/runner/scripts/pre-start.sh" ] ; then
    echo "[INFO] Running pre-start script..."

    chmod +x /home/runner/scripts/pre-start.sh
    source /home/runner/scripts/pre-start.sh
else
    echo "[INFO] No pre-start script found. Skipping."
fi ;

# Download mmodels
cd /home/runner
if [ ! -f "/home/runner/.download-models-complete" ] ; then
    chmod +x /home/scripts/download-models.sh
    bash /home/scripts/download-models.sh
fi ;

echo "########################################"
echo "[INFO] Starting ComfyUI..."
echo "########################################"

export PATH="${PATH}:/home/runner/.local/bin"
export PYTHONPYCACHEPREFIX="/home/runner/.cache/pycache"

cd /home/runner

python3 ./ComfyUI/main.py --listen --port 8188 ${CLI_ARGS}
