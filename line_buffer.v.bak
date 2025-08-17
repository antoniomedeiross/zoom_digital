// Codigo que faz o buffer de linha

module line_Buffer(
    input clk_in, 
    input rst_in,
    input [7:0] data_in, // dado de entrada
    input data_valida_in, // indica se o dado de entrada é válido
    output [7:0] data_out_zoom, // dado de saída do zoom
    output [23:0] data_out_convolucao, // dado de saída da convolução (3 pixels)
    output data_valida_out,
    input rd_data_in // indica se a leitura dos dados é válida

    // se comunica com o algoritmo para saber se deve enviar a line novamente
    input line_end, // indica se o fim da linha foi alcançado
    input line_repeat // indica se a linha deve ser repetida
);


// Buffer da linha: armazena 320 pixels de uma linha
reg[7:0] line [319:0]; 
reg[8:0] wr_ptr; // ponteiro de escrita
reg[8:0] rd_ptr; // ponteiro de leitura



// Escrita no buffer
always @(posedge clk_in) 
begin
    if(data_valida_in) begin
        line[wr_ptr] <= data_in; 
        data_valida_out <= 1; // Indica que o dado foi escrito
    end else begin
        data_valida_out <= 0; // Indica que o dado não foi escrito
    end
end

// Atualiza ponteiro de escrita
always @(posedge clk_in)
begin
    if(rst_in) begin
        wr_ptr <= 'd0;
        data_valida_out <= 0; // Reseta o ponteiro de escrita
    end else if(data_valida_in) begin
        wr_ptr <= wr_ptr + 'd1;
    end
end

// Saída de 1 pixels    
assign data_out_zoom = {line[rd_ptr]}; 
// Concatena os 3 pixels para formar a janela de saída 
assign data_out_convolucao = {line[rd_ptr], line[rd_ptr + 1], line[rd_ptr + 2]};


// Atualiza ponteiro de leitura OU le a linha novamente
always @(posedge clk_in)
begin
    if(rst_in || line_repeat) begin
        rd_ptr <= 'd0;
    end else if(rd_data_in) begin
        rd_ptr <= rd_ptr + 'd1;
    end
end

endmodule