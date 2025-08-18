from PIL import Image
import numpy as np

# --- CONFIGURAÇÕES ---
IMG_PATH = r"C:\\Users\\felip\\Documents\\uefs\\hardware\\sd\\zoom_digital\\images\\frieren-orig.jpeg"
WIDTH, HEIGHT = 320, 240   # resolução da VGA
OUTPUT_MIF = "image.mif"

# --- ABRIR E CONVERTER A IMAGEM ---
img = Image.open(IMG_PATH).convert("L")  # grayscale 8 bits
img = img.resize((WIDTH, HEIGHT))        # redimensiona
pixels = np.array(img, dtype=np.uint8)   # matriz (H x W)

# --- FLATTEN EM UMA LISTA ---
pixel_list = pixels.flatten()  # vira 1D

# --- GERAR O CABEÇALHO DO .MIF ---
with open(OUTPUT_MIF, "w") as f:
    f.write(f"WIDTH=8;\n")                 # cada pixel tem 8 bits
    f.write(f"DEPTH={WIDTH*HEIGHT};\n")    # total de pixels
    f.write("ADDRESS_RADIX=DEC;\n")        # endereços em decimal
    f.write("DATA_RADIX=HEX;\n")           # dados em hexadecimal
    f.write("CONTENT BEGIN\n")

    # escreve cada pixel no .mif
    for addr, val in enumerate(pixel_list):
        f.write(f"    {addr} : {val:02X};\n")  # endereço : valor_hex;

    f.write("END;\n")

print(f"Arquivo .mif gerado: {OUTPUT_MIF}")
