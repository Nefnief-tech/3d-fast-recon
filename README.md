# 3D Fast Reconstruction (Fast3R Dockerized)

This repository provides a Dockerized setup for [Fast3R](https://github.com/facebookresearch/fast3r), allowing for easier deployment and usage of the 3D reconstruction model.

## Features

- **Containerized Environment:** Run Fast3R without messing up your local Python environment.
- **GPU Acceleration:** Configured for NVIDIA GPUs with CUDA support.
- **Persistent Cache:** Models are downloaded once and stored locally.
- **High Quality Settings:** Configured for 32-bit precision and maximum view processing.

## Prerequisites

- Linux with NVIDIA GPU
- Container Runtime: `podman` or `docker`
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

## Quick Start

### 1. Build the Image

```bash
podman build -t fast3r .
```

### 2. Run the Container

Use the following command to run the container. This mounts the necessary GPU devices, sets shared memory, and persists model weights.

```bash
# Create cache directory if it doesn't exist
mkdir -p fast3r_cache

# Run the container
podman run --rm -it \
  --device nvidia.com/gpu=all \
  --shm-size=8g \
  -p 7860:7860 \
  -p 8020:8020 \
  -v $(pwd)/fast3r_cache:/root/.cache/huggingface \
  fast3r
```

Access the Web UI at: **http://localhost:7860**

## Configuration

### Performance vs Quality

The current configuration is set to **High Quality**:
- Precision: `float32`
- Max Parallel Views: `25`

**Warning:** This requires significant VRAM (typically >8GB). If you experience "CUDA out of memory" crashes:

1. **Reduce Image Count:** Try processing fewer than 10 images.
2. **Switch to Performance Mode:**
   - In `fast3r/viz/demo.py`: Change `dtype=torch.float32` to `dtype=torch.bfloat16`.
   - In `fast3r/models/fast3r.py`: Reduce `self.max_parallel_views_for_head` to `12` or `6`.

## Troubleshooting

### WebSocket/Connection Errors
If you see "Connection reset" or WebSocket errors, ensure you are accessing via `http://localhost:7860`. Do not use the `gradio.live` public link, as the internal 3D viewer (Viser) is not exposed through that tunnel.

### GPU Not Found
If you see "NVIDIA Driver was not detected":
- Ensure you are using the `--device nvidia.com/gpu=all` flag.
- If using Podman, check your CDI configuration in `/etc/cdi/nvidia.yaml` to ensure it points to the correct `/dev/dri/cardX` device.
