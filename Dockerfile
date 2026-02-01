FROM docker.io/pytorch/pytorch:2.4.0-cuda12.4-cudnn9-devel

ENV GRADIO_SERVER_NAME 0.0.0.0
ARG DEBIAN_FRONTEND=noninteractive

ARG FORCE_CUDA=1
ENV FORCE_CUDA=${FORCE_CUDA}

ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics
ARG TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6+PTX"

RUN apt-get update -y && apt-get install -y git wget
RUN apt install -y libgl1-mesa-glx libglib2.0-0 libsm6 libxrender1 libxext6

WORKDIR /fast3r
COPY . /fast3r
RUN pip install -r requirements.txt
RUN pip install -e .

ENV CUDA_VISIBLE_DEVICES=0
ENV PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512,garbage_collection_threshold:0.8

EXPOSE 7860

CMD ["python", "fast3r/viz/demo.py"]
