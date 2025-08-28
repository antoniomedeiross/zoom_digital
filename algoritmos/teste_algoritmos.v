////////////////////////////////////////////////////////////////////////////////
// Módulo Top-Level
// Conecta o gerador de pixels, o buffer de linha e o módulo de zoom
// para formar uma pipeline de processamento de imagem completa.
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
// Módulo Top-Level (CORREÇÃO FINAL)
////////////////////////////////////////////////////////////////////////////////
module teste_algoritmos (
    input           clk,
    input           rst,
    input           enable_zoom_in,

    output  [7:0]   final_pixel_out,
    output          final_pixel_valid
	 output [6:0]    seg1,
	 output [6:0]    seg0
);

    localparam IMAGE_WIDTH = 4;
    localparam NUM_BUFFERS = 3;

    // --- Fios de Conexão ---
    wire [7:0]  gen_pixel_out;
    wire        gen_valid_out;
    wire        gen_ready_in;

    wire [7:0]  zoom_pixel_in;
    wire        zoom_valid_in;
    wire        zoom_ready_out;
    
    wire        zoom_handshake_go = zoom_valid_in && zoom_ready_out;

    wire [2:0]  buf_ready_out_write;
    wire [2:0]  buf_line_full;
    wire [2:0]  buf_valid_out_zoom;
    
    wire [7:0]  buf_data_out [0:NUM_BUFFERS-1]; 

    // --- Sinais de Controle da FSM ---
    reg  [2:0]  buf_valid_in_sel;
    reg  [2:0]  buf_repeat_line_sel;
    reg  [2:0]  buf_clear_flag_sel;

    // --- FSM de Controle Central ---
    reg [$clog2(NUM_BUFFERS)-1:0] write_ptr;
    reg [$clog2(NUM_BUFFERS)-1:0] read_ptr;
    reg is_pass_two;
    
    wire line_read_done = (read_ptr_count == IMAGE_WIDTH - 1) && zoom_handshake_go;
    reg [$clog2(IMAGE_WIDTH)-1:0] read_ptr_count;
    
	 // DIVISAO PARA MOSTRA NOS SEGMENTOS
	 wire tick_1hz;
	 clock_divider_1hz u_divider (
		.clk_50mhz(clk), 
		.rst(rst), 
		.tick_1hz(tick_1hz)
	 );

	 
	 
    reg [2:0] buf_is_full_prev;
    
    always @(posedge clk) buf_is_full_prev <= buf_line_full;
    
    // Este bloco agora controla apenas os ponteiros dos buffers
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            write_ptr   <= 0;
            read_ptr    <= 0;
            // is_pass_two <= 1'b0; // <<< CORREÇÃO: LINHA REMOVIDA DAQUI
        end else begin
            if (buf_line_full[write_ptr] && !buf_is_full_prev[write_ptr]) begin
                write_ptr <= write_ptr + 1'b1;
            end
            
            if (line_read_done && is_pass_two) begin
                read_ptr <= read_ptr + 1'b1;
            end
        end
    end
    
    // Este bloco agora é o ÚNICO que controla 'is_pass_two' e o contador
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            is_pass_two <= 1'b0;
            read_ptr_count <= 0;
        end else if (tick_1hz) begin // TESTE APENAS ->  (line_read_done)
            is_pass_two <= ~is_pass_two;
            read_ptr_count <= 0;
        end else if (zoom_handshake_go) begin
            read_ptr_count <= read_ptr_count + 1'b1;
        end
    end
    
    assign gen_ready_in = buf_ready_out_write[write_ptr];
    always @(*) begin
        buf_valid_in_sel = 3'b0;
        buf_valid_in_sel[write_ptr] = gen_valid_out;
    end
    
    assign zoom_pixel_in = buf_data_out[read_ptr];
    assign zoom_valid_in = buf_valid_out_zoom[read_ptr];
    
    always @(*) begin
        buf_repeat_line_sel = 3'b0;
        buf_clear_flag_sel = 3'b0;

        if (line_read_done && !is_pass_two) begin
            buf_repeat_line_sel[read_ptr] = 1'b1;
        end
        
        if (line_read_done && is_pass_two) begin
            buf_clear_flag_sel[read_ptr] = 1'b1;
        end
    end
    
    // --- Instâncias ---
    envia_dados u_pixel_generator (
        .clk(clk), .rst(rst),
        .pixel_out(gen_pixel_out),
        .pixel_valid_out(gen_valid_out),
        .pixel_ready_in(gen_ready_in)
    );

    generate
        genvar i;
        for (i = 0; i < NUM_BUFFERS; i = i + 1) begin : BUFFERS
            line_buffer #( .LINE_DEPTH(IMAGE_WIDTH) ) u_line_buffer (
                .clk(clk), .rst(rst),
                .pixel_in(gen_pixel_out),
                .valid_in(buf_valid_in_sel[i]),
                .ready_out_write(buf_ready_out_write[i]),
                .line_full(buf_line_full[i]),
                .clear_line_full_flag(buf_clear_flag_sel[i]),
                .valid_out_zoom(buf_valid_out_zoom[i]),
                .ready_in_zoom( (read_ptr == i) ? zoom_ready_out : 1'b0 ),
                .data_out_zoom(buf_data_out[i]),
                .data_out_convolucao(),
                .repeat_line(buf_repeat_line_sel[i])
            );
        end
    endgenerate

    zoom_horizontal u_zoom_horizontal (
        .clk(clk), .rst(rst),
        .pixel_in(zoom_pixel_in),
        .pixel_valid_in(zoom_valid_in),
        .pixel_ready_out(zoom_ready_out),
        .zoom_in(enable_zoom_in),
        .pixel_out(final_pixel_out),
        .pixel_valid_out(final_pixel_valid)
    );
	 
	 
	    // --- NOVA INSTÂNCIA DO DRIVER DE DISPLAY ---
    display_driver_7seg u_display_driver (
        .clk_50mhz(clk),
        .rst(rst),
        .pixel_data_in(final_pixel_out),
        .new_data_tick(tick_1hz) // O tick que comanda a FSM também comanda o display
		  .HEX0(seg1), // Dígito menos significativo (direita)
		  .HEX1(seg0)  // Dígito mais significativo (esquerda)
    );
endmodule





/*
module teste_algoritmos (
    // --- Entradas Globais de Controle ---
    input           clk,
    input           rst,
    input           enable_zoom_in,

    // --- Saídas Finais do Processamento ---
    output  [7:0]   final_pixel_out,
    output          final_pixel_valid,
    output  [23:0]  convolution_window_out,
    output          line_is_full
);
	


    //===========================================================================
    // FSM de Controle para Zoom Vertical
    //===========================================================================
    
    // 1. Definição dos estados
    localparam S_AGUARDA_LINHA     = 2'b00;
    localparam S_PROCESSA_1        = 2'b01;
    localparam S_REBOBINA          = 2'b10;
    localparam S_PROCESSA_2        = 2'b11;
    
    reg [1:0] state, next_state;
	 wire clear_line_full_flag;
	 
	 
	 // 2. Contador para saber quando a linha termina de ser lida
    // (LINE_DEPTH vem do módulo line_buffer, idealmente definido como parâmetro aqui também)
    localparam LINE_DEPTH = 4;
    reg [$clog2(LINE_DEPTH)-1:0] pixel_read_count;
    
    wire zoom_handshake_go = buf_to_zoom_valid && zoom_to_buf_ready;
    wire line_processing_done = (pixel_read_count == LINE_DEPTH - 1) && zoom_handshake_go;

	 // Lógica do contador
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pixel_read_count <= 0;
        end else if (state == S_AGUARDA_LINHA || state == S_REBOBINA) begin
            // Reseta o contador quando está esperando ou rebobinando
            pixel_read_count <= 0;
        end else if (zoom_handshake_go) begin
            // Incrementa a cada pixel lido com sucesso pelo zoom
            pixel_read_count <= pixel_read_count + 1;
        end
    end
	 
	 // 3. Lógica de Transição de Estados (bloco combinacional)
    always @(*) begin
        next_state = state; // Por padrão, mantém o estado
        case (state)
            S_AGUARDA_LINHA: if (line_is_full) next_state = S_PROCESSA_1;
            S_PROCESSA_1:    if (line_processing_done) next_state = S_REBOBINA;
            S_REBOBINA:      next_state = S_PROCESSA_2;
            S_PROCESSA_2:    if (line_processing_done) next_state = S_AGUARDA_LINHA;
        endcase
    end
	 
	 // 4. Registrador de Estado (bloco sequencial)
    always @(posedge clk or posedge rst) begin
        if (rst) state <= S_AGUARDA_LINHA;
        else     state <= next_state;
    end
    
    // 5. Geração do sinal de controle
    wire trigger_repeat_line = (state == S_REBOBINA);
	 assign clear_line_full_flag = (state == S_PROCESSA_2) && line_processing_done;
	 
	 //======================================================================
	 // Junção dos módulos
	 //======================================================================


    // --- Fios de Conexão Interna ---
    wire [7:0]  gen_to_buf_pixel;
    wire        gen_to_buf_valid;
    wire        buf_to_gen_ready;

    wire [7:0]  buf_to_zoom_pixel;
    wire        buf_to_zoom_valid;
    wire        zoom_to_buf_ready;

    // --- Instâncias dos Módulos ---
    envia_dados u_pixel_generator (
        .clk(clk),
        .rst(rst),
        .pixel_out(gen_to_buf_pixel),
        .pixel_valid_out(gen_to_buf_valid),
        .pixel_ready_in(buf_to_gen_ready)
    );

	 /*
    line_buffer u_line_buffer (
        .clk(clk),
        .rst(rst),
        .pixel_in(gen_to_buf_pixel),
		  .clear_line_full_flag(clear_line_full_flag),
        .valid_in(gen_to_buf_valid),
        .ready_out_write(buf_to_gen_ready),
        .line_full(line_is_full),
        .data_out_zoom(buf_to_zoom_pixel),
        .valid_out_zoom(buf_to_zoom_valid),
        .ready_in_zoom(zoom_to_buf_ready),
        .data_out_convolucao(convolution_window_out),
        .repeat_line(trigger_repeat_line)
    );
	 *
	 
	 line_buffer_manager #(
        .LINE_DEPTH(4) // Passando o parâmetro de 4 para o teste
    ) u_buffer_manager (
        .clk(clk),
        .rst(rst),
        
        // Conexões de Escrita
        .pixel_in(gen_to_buf_pixel),
        .valid_in(gen_to_buf_valid),
        .ready_out_write(buf_to_gen_ready),

        // Conexões de Leitura
        .valid_out_zoom(buf_to_zoom_valid),
        .ready_in_zoom(zoom_to_buf_ready),
        .data_out_zoom(buf_to_zoom_pixel),

        // Controle de Repetição
        .repeat_line(trigger_repeat_line)
    );

    zoom_horizontal u_zoom_horizontal (
        .clk(clk),
        .rst(rst),
        .pixel_in(buf_to_zoom_pixel),
        .pixel_valid_in(buf_to_zoom_valid),
        .pixel_ready_out(zoom_to_buf_ready),
        .zoom_in(enable_zoom_in),
        .pixel_out(final_pixel_out),
        .pixel_valid_out(final_pixel_valid)
    );
endmodule
*/