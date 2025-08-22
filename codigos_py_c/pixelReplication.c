#include <stdio.h>

void pixelReplication(int *dataVector, int rows, int cols, int factor, int *outVector);

int main() {
    int vetor3x3[3][3] = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    };

    int newRows = 3 * 2; // factor = 2
    int newCols = 3 * 2;
    int saida[6][6];

    pixelReplication(&vetor3x3[0][0], 3, 3, 2, &saida[0][0]);

    printf("==== Pixel Replication (2x) ======\n");
    for (int i = 0; i < newRows; i++) {
        for (int j = 0; j < newCols; j++) {
            printf("%d ", saida[i][j]);
        }
        printf("\n");
    }

    return 0;
}

void pixelReplication(int *dataVector, int rows, int cols, int factor, int *outVector) {
    int newRows = rows * factor;
    int newCols = cols * factor;

    for (int outIndex = 0; outIndex < newRows * newCols; outIndex++) {
        // coordenadas na imagem de saída
        int outRow = outIndex / newCols;
        int outCol = outIndex % newCols;

        // coordenadas equivalentes na imagem original
        int inRow = outRow / factor;
        int inCol = outCol / factor;

        // copia pixel correspondente
        outVector[outIndex] = dataVector[inRow * cols + inCol];
    }
}
