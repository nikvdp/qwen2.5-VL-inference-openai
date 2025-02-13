# Stage 1: Build dependencies and install Python packages
FROM nvidia/cuda:12.3.1-devel-ubuntu22.04 AS builder

# Set working directory
WORKDIR /app

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Install required system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-dev \
    git \
    build-essential \
    ninja-build \
    curl \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --no-cache-dir --user packaging && \
    pip3 install --no-cache-dir --user --index-url https://download.pytorch.org/whl/cu121 torch torchvision && \
    pip3 install --no-cache-dir --user ninja && \
    pip3 install --no-cache-dir --user flash-attn --no-build-isolation && \
    pip3 install --no-cache-dir --user -r requirements.txt

# Copy model download script and set model argument
COPY download_model.py .
ARG QWEN_MODEL=Qwen2.5-VL-7B-Instruct
ENV QWEN_MODEL=${QWEN_MODEL}

# Download model (model will be included in final image)
RUN python3 download_model.py

# Stage 2: Minimal runtime image
FROM nvidia/cuda:12.3.1-runtime-ubuntu22.04

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda
ENV PATH="/root/.local/bin:${CUDA_HOME}/bin:${PATH}"
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

RUN apt-get update && apt-get install -y python3-pip

# Copy installed Python packages from builder stage
COPY --from=builder /root/.local /root/.local

# Copy model files from builder stage
COPY --from=builder /app/models /app/models

# Copy application code
COPY . .

# Expose port
EXPOSE 9192

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:9192/health || exit 1

# Start application
CMD ["python3", "app.py"]
