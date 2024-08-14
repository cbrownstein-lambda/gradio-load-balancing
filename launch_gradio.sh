#!/bin/bash
set -ex

FLUX_REPO_URL=https://github.com/cbrownstein-lambda/flux.git
FLUX_MODEL=flux-schnell

CUDA_DEVICES=(0 1 2 3 4 5 6 7)

# export GRADIO_SERVER_NAME=127.0.0.1

cd "${PWD}"
git clone "${FLUX_REPO_URL}" flux && cd flux

python3 -m venv .venv
source .venv/bin/activate
pip install -e '.[gradio]'

huggingface-cli download Falconsai/nsfw_image_detection
huggingface-cli download black-forest-labs/FLUX.1-schnell
huggingface-cli download google/t5-v1_1-xxl
huggingface-cli download openai/clip-vit-large-patch14

for device in "${CUDA_DEVICES[@]}"
do
        python3 demo_gr.py --name "${FLUX_MODEL}" --device "cuda:${device}" &> "log_${device}.txt" &
done
