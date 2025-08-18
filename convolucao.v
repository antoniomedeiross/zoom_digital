module convolucao (
    input clk_in,
    input [71:0]     pixel_data_in,
    input            pixel_data_valid_in,
    output reg [7:0] pixel_conv_out,
    output reg       pixel_conv_valid_out   
);

    integer i;
    reg [7:0] kernel [8:0]; // kernel 3x3
    reg [15:0] mutiply [8:0]; // multiplicação dos pixels pelos valores do kernel
    reg [15:0] sumDataIntermed; // soma intermediária dos valores multiplicados
    reg [15:0] sumData; // soma final dos valores multiplicados
    reg multDataValid; // sinal de validação da multiplicação
    reg sumDataValid; // sinal de validação da soma final
    reg pixel_conv_valid; // sinal de validação da saída do convolutor

    initial begin
        for (i=0; i<9; i++) begin
             kernel[i] = 8'b00000001; // kernel 3x3 com todos os valores iguais a 1 (blur)  
        end
    end
        

    always @(posedge clk_in) begin
        for (i=0; i<9; i=i+1) begin
            mutiply[i] <= kernel[i] * pixel_data_in[i*8 +: 8];  // multiplicação dos pixels pelos valores do kernel
        end
        multDataValid <= pixel_data_valid_in;
    end

    always @(*) begin
        sumDataIntermed = 0;
        for (i=1; i<9; i=i+1) begin
            sumDataIntermed = sumDataIntermed + mutiply[i]; // soma dos valores multiplicados
        end
    end

    always @(posedge clk_in) begin
        sumData <= sumDataIntermed; // atribuição da soma intermediária à soma final
        sumDataValid <= multDataValid;
    end

    /* ========================================================================
    PRO FILTRO DE BLUR É PRECISO DIVIDIR A SOMA FINAL POR 9 (TAMANHO DO KERNEL)
    */
    always @(posedge clk_in) begin
        pixel_conv_out <= sumData / 9; // média dos valores multiplicados
        pixel_conv_valid_out <= sumDataValid; // sinal de validação da saída
    end

endmodule