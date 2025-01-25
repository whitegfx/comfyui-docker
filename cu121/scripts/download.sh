#!/bin/bash

echo "########################################"
echo "[INFO] Downloading ComfyUI & Manager..."
echo "########################################"

set -euxo pipefail

# ComfyUI
# Using stable version (has a release tag)
cd /home/runner
(
    git clone https://github.com/comfyanonymous/ComfyUI.git &&
    cd ComfyUI &&
    git reset --hard "$(git tag | grep -e '^v' | sort -V | tail -1)"
) ||
# If fails, try git-pull
(
    cd /home/runner/ComfyUI && git pull
)

touch /home/runner/.download-complete

mkdir -p /home/runner/ComfyUI/user/default /home/runner/ComfyUI/models/BiRefNet \
/home/runner/ComfyUI/models/loras/sdxl /home/runner/ComfyUI/models/loras/sd1.5 \
/home/runner/ComfyUI/models/checkpoints/sdxl /home/runner/ComfyUI/models/checkpoints/sd1.5

touch /home/runner/ComfyUI/user/default comfyui.log
touch /home/runner/ComfyUI/comfyui.log


# ComfyUI Manager
cd /home/runner/ComfyUI/custom_nodes
git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules \
    https://github.com/ltdrdata/ComfyUI-Manager.git \
    || (cd /home/runner/ComfyUI/custom_nodes/ComfyUI-Manager && git pull)
