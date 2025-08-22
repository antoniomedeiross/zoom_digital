#include <stdio.h>

void blockAveraging2x2(int *dataVector, int rows, int cols, int *outVector);

int main() {
    int vetor4x4[4][4] = {
        {1, 2, 3, 4},
        {5, 6, 7, 8},
        {9,10,11,12},
        {13,14,15,16}
    };

    int saida[2][2];
    blockAveraging2x2(&vetor4x4[0][0], 4, 4, &saida[0][0]);

    printf("==== Bloco de Média (2x2) ======\n");
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            printf("%2d ", saida[i][j]);
        }
        printf("\n");
    }

    return 0;
}

void blockAveraging2x2(int *dataVector, int rows, int cols, int *outVector) {
    int newRows = rows / 2;
    int newCols = cols / 2;

    for (int outIndex = 0; outIndex < newRows * newCols; outIndex++) {
        int outRow = outIndex / newCols;
        int outCol = outIndex % newCols;

        int baseIndex = (outRow * 2) * cols + (outCol * 2);

        int sum =
            dataVector[baseIndex] +
            dataVector[baseIndex + 1] +
            dataVector[baseIndex + cols] +
            dataVector[baseIndex + cols + 1];

        outVector[outIndex] = sum / 4;
    }
}
