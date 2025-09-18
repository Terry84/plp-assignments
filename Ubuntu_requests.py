import os
import requests
from urllib.parse import urlparse
import uuid

def fetch_image():
    # Prompt for the image URL
    url = input("Enter the image URL: ").strip()

    # Directory for saving images
    save_dir = "Fetched_Images"
    os.makedirs(save_dir, exist_ok=True)

    try:
        # Fetch the image
        response = requests.get(url, timeout=10)
        response.raise_for_status()  # Raise HTTPError for bad responses

        # Extract filename from URL
        parsed_url = urlparse(url)
        filename = os.path.basename(parsed_url.path)

        # If filename is missing or invalid, generate one
        if not filename or "." not in filename:
            filename = f"image_{uuid.uuid4().hex}.jpg"

        # Full save path
        save_path = os.path.join(save_dir, filename)

        # Save image in binary mode
        with open(save_path, "wb") as f:
            f.write(response.content)

        print(f"✅ Image saved successfully as: {save_path}")

    except requests.exceptions.HTTPError as e:
        print(f"❌ HTTP error occurred: {e}")
    except requests.exceptions.ConnectionError:
        print("❌ Connection error. Please check your network or URL.")
    except requests.exceptions.Timeout:
        print("❌ Request timed out.")
    except requests.exceptions.RequestException as e:
        print(f"❌ An error occurred: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

if __name__ == "__main__":
    fetch_image()
