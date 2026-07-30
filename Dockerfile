FROM runpod/worker-comfyui:5.8.4-base

ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------------------------------
# Hugging Face
# -----------------------------------------------------------------------------

RUN pip install --no-cache-dir "huggingface_hub[cli]"

# -----------------------------------------------------------------------------
# Custom Nodes
# -----------------------------------------------------------------------------

RUN git clone https://github.com/yolain/ComfyUI-Easy-Use.git \
    /comfyui/custom_nodes/comfyui-easy-use

RUN git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git \
    /comfyui/custom_nodes/comfyui_ipadapter_plus

RUN git clone https://github.com/rgthree/rgthree-comfy.git \
    /comfyui/custom_nodes/rgthree-comfy

RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git \
    /comfyui/custom_nodes/ComfyUI_Comfyroll_CustomNodes

# -----------------------------------------------------------------------------
# Install requirements
# -----------------------------------------------------------------------------

RUN find /comfyui/custom_nodes -name requirements.txt \
    -exec pip install --no-cache-dir -r {} \;

# -----------------------------------------------------------------------------
# Checkpoint
# -----------------------------------------------------------------------------

RUN hf download wilsinsantos/wsn \
    epicrealismXL_vxviLastfameDMD2.safetensors \
    --local-dir /comfyui/models/checkpoints

# -----------------------------------------------------------------------------
# CLIP Vision
# -----------------------------------------------------------------------------

RUN hf download h94/IP-Adapter \
    models/image_encoder/model.safetensors \
    --local-dir /tmp/clip_sd15 && \
    mv /tmp/clip_sd15/models/image_encoder/model.safetensors \
    /comfyui/models/clip_vision/CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors && \
    rm -rf /tmp/clip_sd15

RUN hf download h94/IP-Adapter \
    sdxl_models/image_encoder/model.safetensors \
    --local-dir /tmp/clip_sdxl && \
    mv /tmp/clip_sdxl/sdxl_models/image_encoder/model.safetensors \
    /comfyui/models/clip_vision/CLIP-ViT-bigG-14-laion2B-39B-b160k.safetensors && \
    rm -rf /tmp/clip_sdxl

# -----------------------------------------------------------------------------
# IPAdapter
# -----------------------------------------------------------------------------

RUN hf download h94/IP-Adapter-FaceID \
    ip-adapter-faceid-plusv2_sd15.bin \
    --local-dir /comfyui/models/ipadapter

RUN hf download h94/IP-Adapter-FaceID \
    ip-adapter-faceid-plusv2_sdxl.bin \
    --local-dir /comfyui/models/ipadapter

# -----------------------------------------------------------------------------
# LoRAs
# -----------------------------------------------------------------------------

RUN hf download h94/IP-Adapter-FaceID \
    ip-adapter-faceid-plusv2_sd15_lora.safetensors \
    --local-dir /comfyui/models/loras

RUN hf download h94/IP-Adapter-FaceID \
    ip-adapter-faceid-plusv2_sdxl_lora.safetensors \
    --local-dir /comfyui/models/loras

# -----------------------------------------------------------------------------
# InsightFace Buffalo_L
# -----------------------------------------------------------------------------

RUN mkdir -p /comfyui/models/insightface/models/buffalo_l

RUN hf download yolkailtd/face-swap-models \
    insightface/models/buffalo_l/1k3d68.onnx \
    --local-dir /tmp/buffalo

RUN hf download yolkailtd/face-swap-models \
    insightface/models/buffalo_l/2d106det.onnx \
    --local-dir /tmp/buffalo

RUN hf download yolkailtd/face-swap-models \
    insightface/models/buffalo_l/det_10g.onnx \
    --local-dir /tmp/buffalo

RUN hf download yolkailtd/face-swap-models \
    insightface/models/buffalo_l/genderage.onnx \
    --local-dir /tmp/buffalo

RUN hf download yolkailtd/face-swap-models \
    insightface/models/buffalo_l/w600k_r50.onnx \
    --local-dir /tmp/buffalo

RUN cp -r /tmp/buffalo/insightface/models/buffalo_l/* \
    /comfyui/models/insightface/models/buffalo_l/

RUN rm -rf /tmp/buffalo

# -----------------------------------------------------------------------------
# Upscaler
# -----------------------------------------------------------------------------

RUN hf download gemasai/4x_NMKD-Superscale-SP_178000_G \
    4x_NMKD-Superscale-SP_178000_G.pth \
    --local-dir /comfyui/models/upscale_models


RUN pip install --no-cache-dir insightface==0.7.3

RUN pip install --no-cache-dir onnxruntime-gpu
