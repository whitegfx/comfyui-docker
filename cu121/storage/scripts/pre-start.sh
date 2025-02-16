#!/bin/bash

cd /home/runner/ComfyUI/custom_nodes/
gcs='git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'

#sed 's/level = normal/level = weak/g' </home/runner/ComfyUI/user/default/ComfyUI-Manager/config.ini > tmp_config.ini
#mv tmp_config.ini /home/runner/ComfyUI/user/default/ComfyUI-Manager/config.ini

## Nodes
#s$gcs https://github.com/chengzeyi/Comfy-WaveSpeed.git

$gcs https://github.com/cubiq/ComfyUI_essentials.git
$gcs https://github.com/kijai/ComfyUI-KJNodes.git
$gcs https://github.com/rgthree/rgthree-comfy.git
$gcs https://github.com/Layer-norm/comfyui-lama-remover.git
$gcs https://github.com/kijai/ComfyUI-IC-Light.git
$gcs https://github.com/spacepxl/ComfyUI-Image-Filters.git
$gcs https://github.com/crystian/ComfyUI-Crystools.git
$gcs https://github.com/Fuwuffyi/ComfyUI-VisualArea-Nodes.git
$gcs https://github.com/chflame163/ComfyUI_LayerStyle.git
$gcs https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git
$gcs https://github.com/ArtBot2023/CharacterFaceSwap.git
$gcs https://github.com/WASasquatch/was-node-suite-comfyui.git
$gcs https://github.com/Fannovel16/comfyui_controlnet_aux.git
$gcs https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
$gcs https://github.com/VykosX/ControlFlowUtils.git
$gcs https://github.com/lldacing/comfyui-easyapi-nodes.git
$gcs https://github.com/ZHO-ZHO-ZHO/ComfyUI-BiRefNet-ZHO.git
$gcs https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git
$gcs https://github.com/evanspearman/ComfyMath.git
$gcs https://github.com/ethansmith2000/comfy-todo.git
#$gcs https://github.com/TheMistoAI/ComfyUI-Anyline
$gcs https://github.com/cubiq/ComfyUI_IPAdapter_plus.git

cd /home/runner/ComfyUI/custom_nodes/ComfyUI-BiRefNet-ZHO
mv utils.py myutils.py
sed 's/from utils import path_to_image/from myutils import path_to_image/g' <dataset.py >tmpdataset.py
mv tmpdataset.py dataset.py
