################################################################################
# Dockerfile that builds 'yanwk/comfyui-boot:cu121'
# A runtime environment for https://github.com/comfyanonymous/ComfyUI
# Using CUDA 12.1& Python 3.11
################################################################################
# === STAGE 1: Build File Browser ===
FROM opensuse/tumbleweed:latest@sha256:5b7c53d68e9d19c3972e6c8b2aa175e4c3b3f8fa49fe8e9241e48276dd49911c AS builder

# Set necessary environment variables
ENV GO_VERSION=1.23.5
ENV PATH="/usr/local/go/bin:$PATH"

# Install required dependencies
RUN zypper --non-interactive install -y \
    git wget tar curl nodejs npm make && \
    zypper clean --all

# Install Go
RUN wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O go.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    go version

# Clone File Browser source code
WORKDIR /build
RUN git clone https://github.com/filebrowser/filebrowser.git && \
    cd filebrowser && \
    sed -i "s/^go .*/go ${GO_VERSION}/" go.mod

# Update dependencies to ensure you're using the latest secure versions
RUN cd /build/filebrowser && \
    go get -u ./... && \
    go mod tidy && \
    go mod vendor  # Lock dependencies

# Install pnpm manually & ensure it's in PATH
RUN curl -fsSL https://get.pnpm.io/install.sh | sh - && \
    ln -s /root/.local/share/pnpm/pnpm /usr/local/bin/pnpm

# Verify pnpm installation
RUN pnpm --version

# Build frontend & backend
WORKDIR /build/filebrowser
RUN make build


FROM opensuse/tumbleweed:latest@sha256:5b7c53d68e9d19c3972e6c8b2aa175e4c3b3f8fa49fe8e9241e48276dd49911c AS final

LABEL maintainer="code@yanwk.fun"

# Copy only the built binary
COPY --from=builder /build/filebrowser/filebrowser /usr/local/bin/filebrowser

# Set execution permissions
RUN chmod +x /usr/local/bin/filebrowser

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
        Mesa-libGL1 libgthread-2_0-0 mc wget curl unzip \
    && rm /usr/lib64/python3.11/EXTERNALLY-MANAGED \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 100

#RUN --mount=type=cache,target=/var/cache/zypp \
#    set -eu \
#    && zypper --gpg-auto-import-keys \
#    install --no-confirm --no-recommends \
#    nodejs

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install \
        --upgrade pip wheel setuptools

# Install xFormers (stable version, will specify PyTorch version),
# and Torchvision + Torchaudio (will downgrade to match xFormers' PyTorch version).
# Break down the steps, so we have more but smaller image layers.

ARG PIP_INDEX_URL="https://download.pytorch.org/whl/cu121"
ARG PIP_EXTRA_INDEX_URL="https://pypi.org/simple"

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install \
        xformers torch torchvision torchaudio

# Dependencies for frequently-used
# (Do this firstly so PIP won't be solving too many deps at one time)
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install \
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
:/usr/local/lib/python3.11/site-packages/nvidia/cufft/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/cublas/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/cuda_nvrtc/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/curand/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/cusolver/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/cusparse/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/nccl/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/nvjitlink/lib\
:/usr/local/lib/python3.11/site-packages/cusparselt/lib\
:/usr/local/lib/python3.11/site-packages/nvidia/nvtx/lib"

# Expose the ports for both applications
EXPOSE 8188 8080

# Create a low-privilege user
RUN printf 'CREATE_MAIL_SPOOL=no' >> /etc/default/useradd \
    && mkdir -p /home/runner /home/scripts /home/runner/scripts \
    && groupadd runner \
    && useradd runner -g runner -d /home/runner \
    && chown runner:runner /home/runner /home/scripts /home/runner/scripts

COPY --chown=runner:runner scripts/. /home/scripts/
COPY --chown=runner:runner storage/scripts/. /home/runner/scripts/
RUN chmod +x /home/scripts/*.sh

USER runner:runner
VOLUME /home/runner
WORKDIR /home/runner

ARG CLI_ARGS
ENV CLI_ARGS=${CLI_ARGS}

# Start the stuff
ENTRYPOINT ["/bin/bash", "/home/scripts/entrypoint.sh"]
#CMD ["tail", "-f", "/dev/null"]
