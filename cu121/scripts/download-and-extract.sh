#!/bin/bash
set -euxo pipefail  # Enable strict error handling

if [ -n "${ZIP_URL:-}" ]; then
  # Define variables
  DEST_DIR="/home/runner/ComfyUI"
  TEMP_ZIP="/tmp/downloaded_file.zip"
  TEMP_EXTRACT_DIR="/tmp/unzip_temp"

  # Create the destination directory if it doesn't exist
  mkdir -p "$DEST_DIR"
  mkdir -p "$DEST_DIR"/custom_nodes/

  # Download the ZIP file
  echo "Downloading ZIP file from $ZIP_URL..."
  curl -L -o "$TEMP_ZIP" "$ZIP_URL"

  # Extract files
  unzip -o "$TEMP_ZIP" -d "$TEMP_EXTRACT_DIR"
  cp -r "$TEMP_EXTRACT_DIR"/input/* "$DEST_DIR"/input/
  cp -r "$TEMP_EXTRACT_DIR"/output/* "$DEST_DIR"/output/
  cp -r "$TEMP_EXTRACT_DIR"/custom_nodes/* "$DEST_DIR"/custom_nodes/
  # Cleanup: Remove the ZIP file
  rm "$TEMP_ZIP"

  echo "✅ Download and extraction complete! (Merged input folders)"
  touch /home/runner/.download-zip-complete
else
    echo "[WARN] ZIP_URL environment variable not set. Skipping  file download."
fi
