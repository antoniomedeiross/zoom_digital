module img_control (
  input       clk_in,
  input       rst_in,
  input [7:0] pixel_data_in,
  input       pixel_data_valid_in,
  output reg [71:0] pixel_data_out,
  output       pixel_data_valid_out,

  // controle zoom
  output [7:0] zoom_data_out,
  output       zoom_data_valid_out,

);

reg [8:0] pixelCounter; // contador de pixels
reg [1:0] currentLineBuffer; // buffer atual da linha (0 a 3)
reg [3:0] lineBufferDataValid; 
reg [3:0] readLineBuffer; // controle de leitura dos buffers de linha
reg [1:0] currentReadLineBuffer;

wire [23:0] lb0data_out_convolucao;
wire [23:0] lb1data_out_convolucao;
wire [23:0] lb2data_out_convolucao;
wire [23:0] lb3data_out_convolucao;

reg [8:0] readCounter; // contador de leitura
reg rd_line_buffer; // controle de leitura dos buffers de linha
reg [10:0] totalPixelCounter; // total de pixels processados 320x4 = 1280 ->(101 0000 0000) 11 bits

reg rdState;
localparam  IDLE = 'b0, 
            RD_BUFFER = 'b1;


assign pixel_data_valid_out = rd_line_buffer;

always @(posedge clk_in) begin
  if(rst_in) begin
    totalPixelCounter <= 0; // reinicializa o contador de pixels processados
  end else begin
    if(pixel_data_valid_in & !rd_line_buffer ) begin // se o dado de pixel for válido e não estiver lendo os buffers de linha
      totalPixelCounter <= totalPixelCounter + 1; // incrementa o contador de pixels processados
    end else if(!pixel_data_valid_in & rd_line_buffer) begin
      totalPixelCounter <= totalPixelCounter - 1; // decrementa o contador de pixels processados
    end
  end
end

always @(posedge clk_in) begin
  if(rst_in) begin
    rdState <= IDLE 
    rd_line_buffer <= 1'b0; // reinicializa o estado de leitura e o controle de leitura dos buffers de linha
  end else begin
    case (rdState)
      IDLE:begin
        if(totalPixelCounter >= 960) begin // se já processou 960 pixels (3 linhas de 320 pixels)
          rd_line_buffer <= 1'b1; // ativa a leitura dos buffers de linha
          rdState <= RD_BUFFER; // muda para o estado de leitura dos buffers de linha
        end 
      end
      RD_BUFFER:begin
        if(readCounter == 319 && rd_line_buffer) begin // se completou a leitura de uma linha de pixels
          rdState <= IDLE; // volta para o estado de espera
          rd_line_buffer <= 1'b0; // desativa a leitura dos buffers de linha 
        end 
      end
    endcase
  end
end

// Controle de saída de dados
always @(posedge clk_in) begin
  if(rst_in) begin
    pixelCounter <= 0;
  end else begin 
    if(pixel_data_valid_in) begin // se o dado de pixel for válido
      pixelCounter <= pixelCounter + 1; // incrementa o contador de pixels
    end
  end
end


always @(posedge clk_in) begin
  if(rst_in) begin
    currentLineBuffer <= 0;
  end else begin
    if(pixelCounter == 320 && pixel_data_valid_in) begin // se completou uma linha de pixels e ainda tem mais pixels
      currentLineBuffer <= currentLineBuffer + 1; // passa para o próximo buffer de linha
    end
  end
end


always @(*) begin
  lineBufferDataValid = 4'h0; // reinicializa o contador de dados válidos
  lineBufferDataValid[currentLineBuffer] = pixel_data_valid_in; // marca o buffer atual como válido 
end


always @(posedge clk_in) begin
  if(rst_in) begin
    readCounter <= 0; // reinicializa o contador de leitura
  end else begin
    if(rd_line_buffer) begin
      readCounter <= readCounter + 1; // incrementa o contador de leitura
    end
  end
end

always @(posedge clk_in) begin
  if(rst_in) begin
    currentReadLineBuffer <= 0; // reinicializa o buffer de leitura
  end else begin
    if(readCounter == 320 && rd_line_buffer) begin 
      currentReadLineBuffer <= currentReadLineBuffer + 1; // passa para o próximo buffer de leitura
    end
  end
end

// Controle de leitura dos buffers de linha
always @(*) begin
  case (currentReadLineBuffer)
    0:begin // concatena o pixels dos buffers de linha 0 a 3
      pixel_data_out = {lb2data_out_convolucao, lb1data_out_convolucao, lb0data_out_convolucao}; 
    end
    1:begin // concatena o pixels dos buffers de linha 1 a 4
      pixel_data_out = {lb3data_out_convolucao, lb2data_out_convolucao, lb1data_out_convolucao}; 
    end
    2:begin // concatena o pixels dos buffers de linha 2 a 0
      pixel_data_out = {lb0data_out_convolucao, lb3data_out_convolucao, lb2data_out_convolucao}; 
    end
    3:begin // concatena o pixels dos buffers de linha 3 a 2
      pixel_data_out = {lb1data_out_convolucao, lb0data_out_convolucao, lb3data_out_convolucao}; 
    end
  endcase
end

always @(*) begin
  case(currentReadLineBuffer)
    0:begin
      readLineBuffer[0] = rd_line_buffer;
      readLineBuffer[1] = rd_line_buffer;
      readLineBuffer[2] = rd_line_buffer;
      readLineBuffer[3] = 1'b0; // não lê o buffer 3
    end
    1:begin
      readLineBuffer[0] = 1'b0; // não lê o buffer 0
      readLineBuffer[1] = rd_line_buffer;
      readLineBuffer[2] = rd_line_buffer;
      readLineBuffer[3] = rd_line_buffer
    end
    2:begin
      readLineBuffer[0] = rd_line_buffer;
      readLineBuffer[1] = 1'b0; // não lê o buffer 1
      readLineBuffer[2] = rd_line_buffer;
      readLineBuffer[3] = rd_line_buffer;
    end
    3:begin
      readLineBuffer[0] = rd_line_buffer;
      readLineBuffer[1] = rd_line_buffer;
      readLineBuffer[2] = 1'b0; // não lê o buffer 2
      readLineBuffer[3] = rd_line_buffer
    end
  endcase
end

// lineBuffer 1
line_Buffer LB0(
    .clk_in(clk_in), 
    .rst_in(rst_in),
    .data_in(pixel_data_in),
    .data_valida_in(lineBufferDataValid[0]), 
    .data_out_zoom(zoom_data_out), 
    .data_out_convolucao(lb0data_out_convolucao), 
    .rd_data_in(readLineBuffer[0])
);

// lineBuffer 2
line_Buffer LB1(
    .clk_in(clk_in), 
    .rst_in(rst_in),
    .data_in(pixel_data_in),
    .data_valida_in(lineBufferDataValid[1]), 
    .data_out_zoom(zoom_data_out), 
    .data_out_convolucao(lb1data_out_convolucao), 
    .rd_data_in(readLineBuffer[1])
);

// lineBuffer 3
line_Buffer LB2(
    .clk_in(clk_in), 
    .rst_in(rst_in),
    .data_in(pixel_data_in),
    .data_valida_in(lineBufferDataValid[2]), 
    .data_out_zoom(zoom_data_out), 
    .data_out_convolucao(lb2data_out_convolucao), 
    .rd_data_in(readLineBuffer[2])
);

// lineBuffer 4
line_Buffer LB3(
    .clk_in(clk_in), 
    .rst_in(rst_in),
    .data_in(pixel_data_in),
    .data_valida_in(lineBufferDataValid[3]), 
    .data_out_zoom(zoom_data_out), 
    .data_out_convolucao(lb3data_out_convolucao), 
    .rd_data_in(readLineBuffer[3])
);


endmodule