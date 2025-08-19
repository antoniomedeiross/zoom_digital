from PIL import Image
import numpy as np

# --- CONFIGURAÇÕES ---
IMG_PATH = r"C:\\Users\Antonio\\OneDrive\Documentos\\universidade\\PBL\\hardware\\SD\\p1\\codigos\\images\\frieren-orig.jpeg"
WIDTH, HEIGHT = 320, 240   # resolução da VGA
OUTPUT_HEX = "image.hex"

# --- ABRIR E CONVERTER A IMAGEM ---
img = Image.open(IMG_PATH).convert("L")  # grayscale 8 bits
img = img.resize((WIDTH, HEIGHT))        # redimensiona
pixels = np.array(img, dtype=np.uint8)   # matriz (H x W)

# --- FLATTEN EM UMA LISTA ---
pixel_list = pixels.flatten()  # vira 1D

# --- GERAR O ARQUIVO .HEX ---
with open(OUTPUT_HEX, "w") as f:
    for val in pixel_list:
        f.write(f"{val:02X}\n")  # escreve cada pixel em hexadecimal

print(f"Arquivo .hex gerado: {OUTPUT_HEX}")

