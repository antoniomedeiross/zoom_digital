import cv2   # OpenCV para processamento de imagens
import numpy as np  # NumPy para manipulação de matrizes/arrays
import os


def vizinho_reducao(img):
    largura = img.shape[0]  # Altura
    altura = img.shape[1]   # Largura
    
    matriz_nova = np.zeros((int(largura/2), int(altura/2), img.shape[2]), dtype=np.uint8)
    
    aux_l = 0
    aux_a = 0
    
    for i in range(0, int(largura/2)):
        aux_l = 0
        for j in range(0, int(altura/2)):
            matriz_nova[i][j] = img[aux_a][aux_l]
            aux_l += 2
        aux_a += 2
    
    return matriz_nova


def vizinho_amplia(img):
    largura = img.shape[0]
    altura = img.shape[1]
    
    n_largura = largura * 2
    n_altura = altura * 2
    
    matriz_nova = np.zeros((n_largura, n_altura, img.shape[2]), dtype=np.uint8)
    
    for i in range(0, n_largura - 1, 2):
        for j in range(0, n_altura - 1, 2):
            pixel = img[i//2][j//2]
            
            matriz_nova[i, j] = pixel
            matriz_nova[i, j+1] = pixel
            matriz_nova[i+1, j] = pixel
            matriz_nova[i+1, j+1] = pixel
    
    return matriz_nova


def main(caminho_imagem):
    # Carrega a imagem usando o caminho informado
    img = cv2.imread(caminho_imagem)
    
    if img is None:
        print("Erro: Imagem não encontrada! Verifique o caminho.")
        return
    
    img_reduzida = vizinho_reducao(img)
    img_ampliada = vizinho_amplia(img)
    
    os.makedirs('./images', exist_ok=True)
    
    cv2.imwrite('./images/reduzida.png', img_reduzida)
    cv2.imwrite('./images/ampliada.png', img_ampliada)
    print("Imagens salvas com sucesso em './images/'!")


if __name__ == '__main__':
    # Você pode passar o caminho direto aqui 👇
    caminho = input("Digite o caminho da imagem: ")
    main(caminho)
