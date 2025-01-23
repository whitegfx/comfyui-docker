#!/bin/bash

set -euxo pipefail

echo "########################################"
echo "[INFO] Downloading Civitai and Hugging Face Models..."
echo "########################################"

# Models directory
cd /home/runner/ComfyUI/models

# Process Civitai Models
CIVITAI_FAILED=false
if [ -n "${CIVITAI_DOWNLOADS:-}" ]; then
    CIVITAI_INPUT_FILE="/home/scripts/civitai-download-models.txt"
    curl -o "$CIVITAI_INPUT_FILE" "$CIVITAI_DOWNLOADS" || {
        echo "[WARN] Failed to download Civitai models file from URL. Skipping Civitai models processing."
        CIVITAI_FAILED=true
    }
else
    echo "[WARN] CIVITAI_DOWNLOADS environment variable not set. Skipping Civitai models file download."
    CIVITAI_FAILED=true
fi

if [ "$CIVITAI_FAILED" = false ] && [ -f "$CIVITAI_INPUT_FILE" ]; then
    TOKEN="${CIVITAI_TOKEN:-}"
    if [ -z "$TOKEN" ]; then
        echo "[WARN] CIVITAI_TOKEN environment variable is not set. Skipping Civitai models processing."
        CIVITAI_FAILED=true
    else
        OUTPUT_FILE="/home/scripts/civitai-download-models-tk.txt"
        rm -f "$OUTPUT_FILE"

        while IFS= read -r line; do
            if [[ "$line" =~ ^https ]]; then
                echo "$line?token=$TOKEN" >> "$OUTPUT_FILE"
            else
                echo "$line" >> "$OUTPUT_FILE"
            fi
        done < "$CIVITAI_INPUT_FILE"

        echo "Processed file saved to $OUTPUT_FILE"

        if [ ! -f "/home/runner/.download-civitai-models-complete" ]; then
            aria2c --input-file="$OUTPUT_FILE" \
                --allow-overwrite=false --auto-file-renaming=false --continue=true \
                --max-connection-per-server=5 --max-file-not-found=100 || {
                echo "[WARN] Failed to download Civitai models. Continuing to Hugging Face models."
            }
            touch /home/runner/.download-civitai-models-complete
        fi
    fi
fi

# Process Hugging Face Models
if [ -n "${HF_DOWNLOADS:-}" ]; then
    HF_INPUT_FILE="/home/scripts/hf-download-models.txt"
    curl -o "$HF_INPUT_FILE" "$HF_DOWNLOADS" || {
        echo "[WARN] Failed to download Hugging Face models file from URL. Skipping Hugging Face models processing."
        HF_INPUT_FILE=""
    }
else
    echo "[WARN] HF_DOWNLOADS environment variable not set. Skipping Hugging Face file download."
    HF_INPUT_FILE=""
fi

if [ -n "$HF_INPUT_FILE" ] && [ -f "$HF_INPUT_FILE" ]; then
    if [ -z "${HF_TOKEN:-}" ]; then
        echo "Error: HF_TOKEN environment variable is not set. Skipping Hugging Face models processing."
    else
        if [ ! -f "/home/runner/.download-hf-models-complete" ]; then
            aria2c --input-file="$HF_INPUT_FILE" \
                --allow-overwrite=false --auto-file-renaming=false --continue=true \
                --max-connection-per-server=5 --max-file-not-found=100 \
                --header="Authorization: Bearer $HF_TOKEN" || {
                echo "[WARN] Failed to download Hugging Face models. Skipping."
            }
            touch /home/runner/.download-hf-models-complete
        fi
    fi
fi

# Final completion marker
touch /home/runner/.download-models-complete
