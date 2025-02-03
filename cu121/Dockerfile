################################################################################
# Dockerfile that builds 'yanwk/comfyui-boot:cu121'
# A runtime environment for https://github.com/comfyanonymous/ComfyUI
# Using CUDA 12.1& Python 3.11
################################################################################

FROM opensuse/tumbleweed:latest@sha256:04c64f84b82c06c57ffb0b7bf21cccf487ada1784c4e67420181f09729e5d77d

LABEL maintainer="code@yanwk.fun"

# Note: GCC for InsightFace;
#       FFmpeg for video (pip[imageio-ffmpeg] will use system FFmpeg instead of bundled).
# Note: CMake may use different version of Python. Using 'update-alternatives' to ensure default version.
RUN --mount=type=cache,target=/var/cache/zypp \
    set -eu \
    && zypper addrepo --check --refresh --priority 90 \
        'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/Essentials/' packman-essentials \
    && zypper --gpg-auto-import-keys \
            install --no-confirm --no-recommends \
        python311 python311-pip python311-wheel python311-setuptools \
        python311-devel python311-Cython gcc-c++ python311-py-build-cmake \
        python311-numpy1 python311-opencv \
        python311-ffmpeg-python ffmpeg x264 x265 \
        python311-dbm \
        google-noto-sans-fonts google-noto-sans-cjk-fonts google-noto-coloremoji-fonts \
        shadow git aria2 \
        Mesa-libGL1 libgthread-2_0-0 mc wget curl unzip coreutils \
    && rm /usr/lib64/python3.11/EXTERNALLY-MANAGED \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 100

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir \
        --upgrade pip wheel setuptools

# Install xFormers (stable version, will specify PyTorch version),
# and Torchvision + Torchaudio (will downgrade to match xFormers' PyTorch version).
# Break down the steps, so we have more but smaller image layers.

ARG PIP_INDEX_URL="https://download.pytorch.org/whl/cu121"
#ARG PIP_INDEX_URL="https://download.pytorch.org/whl/nightly/cu121"
ARG PIP_EXTRA_INDEX_URL="https://pypi.org/simple"

#RUN --mount=type=cache,target=/root/.cache/pip \
#    pip install \
#        --dry-run xformers torchvision torchaudio
#
#RUN --mount=type=cache,target=/root/.cache/pip \
#    pip install \
#        --no-deps xformers torch torchvision torchaudio
#
#RUN --mount=type=cache,target=/root/.cache/pip \
#    pip install \
#        xformers torchvision torchaudio

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir \
        xformers torch torchvision torchaudio

# Dependencies for frequently-used
# (Do this firstly so PIP won't be solving too many deps at one time)
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir \
        -r https://raw.githubusercontent.com/comfyanonymous/ComfyUI/master/requirements.txt \
        -r https://raw.githubusercontent.com/crystian/ComfyUI-Crystools/main/requirements.txt \
        -r https://raw.githubusercontent.com/cubiq/ComfyUI_essentials/main/requirements.txt \
        -r https://raw.githubusercontent.com/Fannovel16/comfyui_controlnet_aux/main/requirements.txt \
        -r https://raw.githubusercontent.com/jags111/efficiency-nodes-comfyui/main/requirements.txt \
        -r https://raw.githubusercontent.com/ltdrdata/ComfyUI-Impact-Pack/Main/requirements.txt \
        -r https://raw.githubusercontent.com/ltdrdata/ComfyUI-Impact-Subpack/main/requirements.txt \
        -r https://raw.githubusercontent.com/ltdrdata/ComfyUI-Inspire-Pack/main/requirements.txt \
        -r https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main/requirements.txt \
        -r https://raw.githubusercontent.com/kijai/ComfyUI-IC-Light/refs/heads/main/requirements.txt \
        -r https://raw.githubusercontent.com/chflame163/ComfyUI_LayerStyle/refs/heads/main/requirements.txt \
        -r https://raw.githubusercontent.com/kijai/ComfyUI-KJNodes/main/requirements.txt \
        -r https://raw.githubusercontent.com/chflame163/ComfyUI_LayerStyle/refs/heads/main/requirements.txt \
        -r https://raw.githubusercontent.com/ZHO-ZHO-ZHO/ComfyUI-BiRefNet-ZHO/refs/heads/main/requirements.txt \
        -r https://raw.githubusercontent.com/WASasquatch/was-node-suite-comfyui/refs/heads/main/requirements.txt \
        -r https://raw.githubusercontent.com/lldacing/comfyui-easyapi-nodes/refs/heads/master/requirements.txt \
        python-ffmpeg facexlib

# Fix for libs (.so files)
ENV LD_LIBRARY_PATH="/usr/local/lib64/python3.11/site-packages/torch/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/cuda_cupti/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/cuda_runtime/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/cudnn/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/cufft/lib"

# More libs (not necessary, just in case)
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}\
:/usr/local/lib/python3.11/site-packages/nvidia/cublas/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/cuda_nvrtc/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/curand/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/cusolver/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/cusparse/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/nccl/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/nvjitlink/lib\
:/usr/local/lib/python3.11/site-packages/cusparselt/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/nvtx/lib"

# Install File Browser
RUN wget -qO- https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz | tar xz -C /usr/local/bin

# Expose the ports for both applications
EXPOSE 8080

# Create a low-privilege user
RUN printf 'CREATE_MAIL_SPOOL=no' >> /etc/default/useradd \
    && mkdir -p /home/runner /home/scripts /home/runner/scripts \
    && groupadd runner \
    && useradd runner -g runner -d /home/runner \
    && chown runner:runner /home/runner /home/scripts /home/runner/scripts

COPY --chown=runner:runner scripts/. /home/scripts/
COPY --chown=runner:runner storage/scripts/. /home/runner/scripts/

USER runner:runner
VOLUME /home/runner
WORKDIR /home/runner
EXPOSE 8188
EXPOSE 8080
ARG CLI_ARGS
ENV CLI_ARGS=${CLI_ARGS}

# Start systemd and rsyslog inside the container
CMD ["/bin/bash", "/home/scripts/entrypoint.sh"]

#CMD ["bash","/home/scripts/entrypoint.sh"]
#CMD ["tail", "-f", "/dev/null"]
