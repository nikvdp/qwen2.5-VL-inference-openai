# Qwen2.5-VL API Server

## Running the container directly
This is a fork of https://github.com/phildougherty/qwen2.5-VL-inference-openai
which has been updated to include the model in the docker image itself so that
it can be run directly from the docker container and to support the 3b and 72b
variants (in addition to the 7b variant that was originally) 

To use the prebuilt versions you can clone this repo and use the docker-compose
file, or just run it with a docker incantation like the following:

```bash
docker run -d --gpus all \
  -p 9192:9192 \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e DEV_MODE=true \
  --shm-size=8gb \
  --restart unless-stopped \
  ghcr.io/nikvdp/qwen-vl
```

You can also specify which variant to run using docker tags (`:7b` is the
default, also aliased as `:latest`). 

Valid tags are:

```
ghcr.io/nikvdp/qwen-vl:3b
ghcr.io/nikvdp/qwen-vl:7b
ghcr.io/nikvdp/qwen-vl:72b
```

## Buliding the container locally

If you want to build your own version of the container locally, you can do so
by cloning this repo and then running `docker-compose build`. This will build
the `7b` variant by default, but if you want to build a different variant you
can set the model names using the `QWEN_MODEL` env var to any of the variants
available in the [huggingface collection](https://huggingface.co/collections/Qwen/qwen25-vl-6795ffac22b334a837c0f9a5). 

At the time of writing the valid values for `QWEN_MODEL` are;

- `Qwen2.5-VL-3B-Instruct`
- `Qwen2.5-VL-7B-Instruct`
- `Qwen2.5-VL-72B-Instruct`

So to build the 3b variant you could do something like:

```bash
export QWEN_MODEL="Qwen2.5-VL-3B-Instruct"
docker-compose build
```


# Original README

An OpenAI-compatible API server for the Qwen2.5-VL vision-language model, enabling multimodal conversations with image understanding capabilities.

## Features

- OpenAI-compatible API endpoints
- Support for vision-language tasks
- Image analysis and description
- Base64 image handling
- JSON response formatting
- System resource monitoring
- Health check endpoint
- CUDA/GPU support with Flash Attention 2
- Docker containerization

## Prerequisites

- Docker and Docker Compose
- NVIDIA GPU with CUDA support (recommended)
- NVIDIA Container Toolkit
- At least 24GB GPU VRAM (for 7B model)
- 32GB+ system RAM recommended

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/yourusername/qwen-vision.git
cd qwen-vision
```

2. Download the model:
```bash
mkdir -p models
./download_model.py
```

3. Start the service:
```bash
docker-compose up -d
```

4. Test the API:
```bash
curl http://localhost:9192/health
```

## API Endpoints

### GET /v1/models
Lists available models and their capabilities.

```bash
curl http://localhost:9192/v1/models | jq .
```

### POST /v1/chat/completions
Main endpoint for chat completions with vision support.

Example with text:
```bash
curl -X POST http://localhost:9192/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen2.5-VL-7B-Instruct",
    "messages": [
      {
        "role": "user",
        "content": "What is the capital of France?"
      }
    ]
  }'
```

Example with image:
```bash
curl -X POST http://localhost:9192/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen2.5-VL-7B-Instruct",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": "What do you see in this image?"
          },
          {
            "type": "image_url",
            "image_url": {
              "url": "data:image/jpeg;base64,..."
            }
          }
        ]
      }
    ]
  }'
```

### GET /health
Health check endpoint providing system information.

```bash
curl http://localhost:9192/health
```

## Configuration

Environment variables in docker-compose.yml:
- `NVIDIA_VISIBLE_DEVICES`: GPU device selection
- `MODEL_DIR`: Model directory path
- `PORT`: API port (default: 9192)

## Integration with OpenWebUI

1. In OpenWebUI admin panel, add a new API endpoint:
   - Base URL: `http://localhost:9192`
   - API Key: (leave blank)
   - Model: `Qwen2.5-VL-7B-Instruct`

2. The model will appear in the model selection dropdown with vision capabilities enabled.

## System Requirements

Minimum:
- NVIDIA GPU with 24GB VRAM
- 16GB System RAM
- 50GB disk space

Recommended:
- NVIDIA RTX 3090 or better
- 32GB System RAM
- 100GB SSD storage

## Docker Compose Configuration

```yaml
services:
  qwen-vl-api:
    build: .
    ports:
      - "9192:9192"
    volumes:
      - ./models:/app/models
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
    shm_size: '8gb'
    restart: unless-stopped
```

## Development

To run in development mode:

```bash
# Install dependencies
pip install -r requirements.txt

# Run the server
python app.py
```

## Monitoring

The API includes comprehensive logging and monitoring:
- System resource usage
- GPU utilization
- Request/response timing
- Error tracking

View logs:
```bash
docker-compose logs -f
```

## Error Handling

The API includes robust error handling for:
- Invalid requests
- Image processing errors
- Model errors
- System resource issues

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Qwen team for the base model
- FastAPI for the web framework
- Transformers library for model handling

## Support

For issues and feature requests, please use the GitHub issue tracker.
```

This README provides:
1. Clear installation instructions
2. API documentation
3. Configuration options
4. System requirements
5. Usage examples
6. Development guidelines
7. Monitoring information
8. Error handling details
9. Contributing guidelines

You may want to customize:
- Repository URLs
- License information
- Specific system requirements based on your deployment
- Additional configuration options
- Any specific deployment instructions for your environment
