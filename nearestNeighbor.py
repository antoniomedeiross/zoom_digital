import numpy as np

# matriz original 5x5
original = np.array([
    [1, 2, 3, 4, 5],
    [6, 7, 8, 9, 10],
    [11, 12, 13, 14, 15],
    [16, 17, 18, 19, 20],
    [21, 22, 23, 24, 25]
])


# fator de escala
scale = 2
rows, cols = original.shape # (5, 5)

# nova matriz (10x10)
new_rows, new_cols = rows * scale, cols * scale # (5*scale, 5*scale)

resized = np.zeros((new_rows, new_cols), dtype=int) # nova matrix tamanho maior 10x10

for i in range(new_rows):
    
    for j in range(new_cols):
        # mapeia para o índice mais próximo da matriz original
        orig_i = i // scale  
        orig_j = j // scale
        resized[i, j] = original[orig_i, orig_j]

print(resized)


'''
  1//2 = 0
  1//2 = 0
  2//2 = 1
  3//2 = 1
  4//2 = 2
  5//2 = 2
  6//2 = 3
'''