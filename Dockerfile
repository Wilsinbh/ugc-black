# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG HF_TOKEN=""

# install custom nodes into comfyui
RUN comfy node install --exit-on-fail comfyui-easy-use@1.3.6 --mode remote || (echo "WARN: comfyui-easy-use@1.3.6 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail comfyui-easy-use --mode remote)
RUN comfy node install --exit-on-fail comfyui_ipadapter_plus@2.0.0 || (echo "WARN: comfyui_ipadapter_plus@2.0.0 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail comfyui_ipadapter_plus)
RUN git clone https://github.com/rgthree/rgthree-comfy /comfyui/custom_nodes/rgthree-comfy && cd /comfyui/custom_nodes/rgthree-comfy && (git checkout 6b76ee6f2c5a007710b5a16f97c94330d6ecc871 2>/dev/null || (git fetch origin 6b76ee6f2c5a007710b5a16f97c94330d6ecc871 --depth=1 && git checkout 6b76ee6f2c5a007710b5a16f97c94330d6ecc871) || echo "WARN: commit 6b76ee6f2c5a007710b5a16f97c94330d6ecc871 unreachable in https://github.com/rgthree/rgthree-comfy, falling back to default branch HEAD")
RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes /comfyui/custom_nodes/ComfyUI_Comfyroll_CustomNodes && cd /comfyui/custom_nodes/ComfyUI_Comfyroll_CustomNodes && (git checkout d78b780ae43fcf8c6b7c6505e6ffb4584281ceca 2>/dev/null || (git fetch origin d78b780ae43fcf8c6b7c6505e6ffb4584281ceca --depth=1 && git checkout d78b780ae43fcf8c6b7c6505e6ffb4584281ceca) || echo "WARN: commit d78b780ae43fcf8c6b7c6505e6ffb4584281ceca unreachable in https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes, falling back to default branch HEAD")

# download models into comfyui
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors' --relative-path models/clip_vision --filename 'sd1.5_clipvision.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth' --relative-path models/Unknown --filename '4x_NMKD-Superscale-SP_178000_G.pth' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/wilsinsantos/wsn/resolve/main/epicrealismXL_vxviLastfameDMD2.safetensors' --relative-path models/checkpoints --filename 'epicrealismXL_vxviLastfameDMD2.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/

# user-provided inputs override the auto-generated placeholders above.
RUN wget --progress=dot:giga -O '/comfyui/input/VhjmHRgWfYBO1IyTxpfGG_iiffQJwj.png' "https://cool-anteater-319.convex.cloud/api/storage/26946503-ff60-4ba7-81ba-6c40110cf6e5"
