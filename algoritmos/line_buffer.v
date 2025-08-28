module line_buffer (
    // --- Interface Global ---
    input           clk,
    input           rst,

    // --- Interface de Escrita (para o gerador de pixels) ---
    input   [7:0]   pixel_in,
    input           valid_in,
    output          ready_out_write,
    output  reg     line_full,
    input           clear_line_full_flag,

    // --- Interface de Leitura (para o zoom) ---
    output          valid_out_zoom,
    input           ready_in_zoom,
    output  [7:0]   data_out_zoom,      // <-- CORREÇÃO: Não é mais 'reg'
    output  [23:0]  data_out_convolucao,
    input           repeat_line
);

    // --- Parâmetros ---
    parameter LINE_DEPTH = 4;
    parameter PIXEL_WIDTH = 8;
    localparam ADDR_WIDTH = $clog2(LINE_DEPTH);

    // --- Sinais Internos ---
    reg [PIXEL_WIDTH-1:0]   line_mem [LINE_DEPTH-1:0];
    reg [ADDR_WIDTH-1:0]    wr_ptr;
    reg [ADDR_WIDTH-1:0]    rd_ptr;

    // --- Lógica de Handshake ---
    assign ready_out_write = !line_full;
    wire   write_handshake_go = valid_in && ready_out_write;
    wire   zoom_handshake_go = valid_out_zoom && ready_in_zoom;

    // --- Lógica de Escrita ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr    <= 0;
            line_full <= 1'b0;
        end else if (clear_line_full_flag) begin
            line_full <= 1'b0;
        end else if (write_handshake_go) begin // <-- MELHORIA: Usando o wire para clareza
            line_mem[wr_ptr] <= pixel_in;
            if (wr_ptr == LINE_DEPTH - 1) begin
                line_full <= 1'b1;
                wr_ptr    <= 0;
            end else begin
                wr_ptr <= wr_ptr + 1;
            end
        end
    end

    // --- Lógica de Leitura ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
        end else if (repeat_line) begin
            rd_ptr <= 0;
        end else if (zoom_handshake_go) begin
            rd_ptr <= rd_ptr + 1;
        end
    end

    // --- Lógica de Saída ---
    // A saída é válida se a linha está cheia E o ponteiro está dentro dos limites.
    assign valid_out_zoom = line_full && (rd_ptr < LINE_DEPTH);

    // A saída de dados é uma leitura direta (combinacional) da memória.
    assign data_out_zoom = line_mem[rd_ptr];

    // A saída de convolução permanece a mesma.
    assign data_out_convolucao = {
        line_mem[rd_ptr],
        (rd_ptr < LINE_DEPTH - 2) ? line_mem[rd_ptr + 1] : 8'b0,
        (rd_ptr < LINE_DEPTH - 2) ? line_mem[rd_ptr + 2] : 8'b0
    };

endmodule