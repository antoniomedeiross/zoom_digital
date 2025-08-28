// Codigo que faz o buffer de linha

module line_Buffer(
    input clk_in, 
    input rst_in,
    input [7:0] data_in, // dado de entrada
    input data_valida_in, // indica se o dado de entrada é válido
    output [7:0] data_out_zoom, // dado de saída do zoom
    output [23:0] data_out_convolucao, // dado de saída da convolução (3 pixels)

    input rd_data_in, // indica se a leitura dos dados é válida

    input repeat_line_buffer,
    output end_line
);


// Buffer da linha: armazena 320 pixels de uma linha
reg[7:0] line [319:0]; 
reg[8:0] wr_ptr; // ponteiro de escrita
reg[8:0] rd_ptr; // ponteiro de leitura


// Saída de 1 pixels    
assign data_out_zoom = {line[rd_ptr]}; 
// Concatena os 3 pixels para formar a janela de saída 
assign data_out_convolucao = {line[rd_ptr], line[rd_ptr + 1], line[rd_ptr + 2]};


// Atualiza ponteiro de leitura OU le a linha novamente
always @(posedge clk_in)
begin
    if(rst_in || repeat_line_buffer) begin
        rd_ptr <= 'd0;
    end else if(rd_data_in) begin
        rd_ptr <= rd_ptr + 'd1;
    end
end

// Escrita no buffer + controle de data_valida_out + wr_ptr
always @(posedge clk_in) begin
    if(rst_in) begin
        wr_ptr <= 'd0;
    end else if(data_valida_in) begin
        line[wr_ptr] <= data_in;
        end_line <= (wr_ptr == 2);
        wr_ptr <= wr_ptr + 'd1;
    end else begin
    end
end


endmodule