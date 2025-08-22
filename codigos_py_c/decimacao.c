#include <stdio.h>

void decimation(int *dataVector, int rows, int cols, int factor, int *outVector);

int main() {
    int vetor6x6[6][6] = {
        {1, 2, 3, 4, 5, 6},
        {7, 8, 9,10,11,12},
        {13,14,15,16,17,18},
        {19,20,21,22,23,24},
        {25,26,27,28,29,30},
        {31,32,33,34,35,36}
    };

    int newRows = 6 / 2; // fator 2
    int newCols = 6 / 2;
    int saida[3][3];

    decimation(&vetor6x6[0][0], 6, 6, 2, &saida[0][0]);

    printf("==== Decimação (factor 2) ======\n");
    for (int i = 0; i < newRows; i++) {
        for (int j = 0; j < newCols; j++) {
            printf("%2d ", saida[i][j]);
        }
        printf("\n");
    }

    return 0;
}

void decimation(int *dataVector, int rows, int cols, int factor, int *outVector) {
    int newRows = rows / factor;
    int newCols = cols / factor;

    for (int outIndex = 0; outIndex < newRows * newCols; outIndex++) {
        // coordenadas da saída
        int outRow = outIndex / newCols;
        int outCol = outIndex % newCols;

        // escolhe o pixel original correspondente
        int inRow = outRow * factor;
        int inCol = outCol * factor;

        // copia para saída
        outVector[outIndex] = dataVector[inRow * cols + inCol];
    }
}
