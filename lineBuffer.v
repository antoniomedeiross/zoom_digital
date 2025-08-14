// Codigo que faz o buffer de linha

module lineBuffer(
    input clk_in, 
    input rst_in,
    input [7:0] data_in, // dado de entrada
    input data_valida_in, // indica se o dado de entrada é válido
    output [23:0] data_out, // dado de saída
    input rd_data_in
);

reg[7:0] line []; // buffer da linha 1

endmodule