#include <stdio.h>

void nearestNeighbor2x(int *dataVector, int rows, int cols, int *outVector);
void nearestNeighborHalf(int *dataVector, int rows, int cols, int *outVector);

int main() {
    int vetor3x3[3][3] = {
        {0, 1, 2},
        {3, 4, 5},
        {6, 7, 8}
    };

    int saida[6][6];
    nearestNeighbor2x(&vetor3x3[0][0], 3, 3, &saida[0][0]);

    printf("==== Amplia 2x ======\n");
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
            printf("%d ", saida[i][j]);
        }
        printf("\n");
    }

    int vetorMenor[3][3];
    nearestNeighborHalf(&saida[0][0], 6, 6, &vetorMenor[0][0]);
    printf("==== Reduz 2x ======\n");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            printf("%d ", vetorMenor[i][j]);
        }
        printf("\n");
    }   

    return 0;
}

void nearestNeighbor2x(int *dataVector, int rows, int cols, int *outVector) {
    int newRows = rows * 2; // Dobra o número de linhas
    int newCols = cols * 2; // Dobra o número de colunas
    int totalPixels = newRows * newCols; // Total de pixels na imagem ampliada

    for (int idx = 0; idx < totalPixels; idx++) {
        // i = linha na imagem de saída
        int i = idx / newCols; 
        // j = coluna na imagem de saída
        int j = idx % newCols;

        // índice do pixel original mais próximo
        int orig_i = i / 2;
        int orig_j = j / 2;
        int origIndex = orig_i * cols + orig_j;

        outVector[idx] = dataVector[origIndex];
    }
}


void nearestNeighborHalf(int *dataVector, int rows, int cols, int *outVector) {
    int newRows = rows / 2;
    int newCols = cols / 2;
    int totalPixels = newRows * newCols;

    for (int idx = 0; idx < totalPixels; idx++) {
        // linha e coluna na imagem reduzida
        int i = idx / newCols;
        int j = idx % newCols;

        // índice correspondente na imagem original (pega cada 2 pixels)
        int orig_i = i * 2;
        int orig_j = j * 2;
        int origIndex = orig_i * cols + orig_j;

        outVector[idx] = dataVector[origIndex];
    }
}

