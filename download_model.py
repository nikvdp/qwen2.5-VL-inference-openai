from transformers import Qwen2_5_VLForConditionalGeneration, AutoProcessor
import os
import torch
from accelerate import init_empty_weights
from accelerate.utils import load_and_quantize_model

MODEL_NAME = 'Qwen2.5-VL-7B-Instruct'
MODEL_DIR = f"models/{os.getenv('QWEN_MODEL', MODEL_NAME)}"

def download_model():
    print(f"Downloading model to {MODEL_DIR}...")
    
    # Create directory if it doesn't exist
    os.makedirs(MODEL_DIR, exist_ok=True)
    
    # Download and save processor first
    print("Downloading and saving processor...")
    processor = AutoProcessor.from_pretrained(f"Qwen/{MODEL_NAME}")
    processor.save_pretrained(MODEL_DIR)
    
    print("Downloading and saving model...")
    # Initialize model with better memory handling
    model = Qwen2_5_VLForConditionalGeneration.from_pretrained(
        f"Qwen/{MODEL_NAME}",
        torch_dtype=torch.float16,
        device_map="auto",
        offload_folder="offload",  # Temporary directory for offloading
        offload_state_dict=True,   # Enable state dict offloading
        low_cpu_mem_usage=True     # Enable low CPU memory usage
    )
    
    print("Saving model...")
    # Save with specific shard size to handle memory better
    model.save_pretrained(
        MODEL_DIR,
        safe_serialization=True,
        max_shard_size="2GB"
    )
    
    # Clean up offload folder if it exists
    if os.path.exists("offload"):
        import shutil
        shutil.rmtree("offload")
    
    print("Model downloaded and saved successfully!")

if __name__ == "__main__":
    download_model()
