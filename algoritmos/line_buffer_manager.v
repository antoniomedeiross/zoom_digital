////////////////////////////////////////////////////////////////////////////////
// Módulo Gerenciador de Buffer Triplo (Ping-Pong-Pung)
// Garante um fluxo de dados contínuo para o consumidor, sem "buracos".
////////////////////////////////////////////////////////////////////////////////
module line_buffer_manager #(
    parameter LINE_DEPTH = 4, // Configurado para o teste
    parameter PIXEL_WIDTH = 8
)(
    // ... (as portas não mudam)
    input  clk,
    input  rst,
    input  [PIXEL_WIDTH-1:0] pixel_in,
    input  valid_in,
    output ready_out_write,
    output             valid_out_zoom,
    input              ready_in_zoom,
    output [PIXEL_WIDTH-1:0] data_out_zoom,
    input              repeat_line
);

    localparam ADDR_WIDTH = $clog2(LINE_DEPTH);

    // --- Memórias e Ponteiros ---
    reg [PIXEL_WIDTH-1:0] mem [0:2] [0:LINE_DEPTH-1];
    reg [1:0] write_buf_idx;
    reg [1:0] read_buf_idx;
    reg [2:0] buf_is_full;
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;

    // --- Lógica de Handshake ---
    wire write_handshake_go = valid_in && ready_out_write;
    wire read_handshake_go  = valid_out_zoom && ready_in_zoom;

    assign ready_out_write = !buf_is_full[write_buf_idx];
    assign valid_out_zoom = buf_is_full[read_buf_idx];
    assign data_out_zoom = mem[read_buf_idx][rd_ptr];

    // --- Lógica de Escrita (controla apenas ponteiros de escrita) ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            write_buf_idx <= 0;
        end else if (write_handshake_go) begin
            mem[write_buf_idx][wr_ptr] <= pixel_in;
            if (wr_ptr == LINE_DEPTH - 1) begin
                wr_ptr <= 0;
                // Apenas avança o índice, não mexe no flag 'buf_is_full'
                write_buf_idx <= write_buf_idx + 1'b1;
            end else begin
                wr_ptr <= wr_ptr + 1'b1;
            end
        end
    end

    // --- Lógica de Leitura (controla apenas ponteiros de leitura) ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            read_buf_idx <= 0;
        end else begin
            if (repeat_line) begin
                rd_ptr <= 0;
            end else if (read_handshake_go) begin
                if (rd_ptr == LINE_DEPTH - 1) begin
                    rd_ptr <= 0;
                    // Apenas avança o índice, não mexe no flag 'buf_is_full'
                    read_buf_idx <= read_buf_idx + 1'b1;
                end else begin
                    rd_ptr <= rd_ptr + 1'b1;
                end
            end
        end
    end

    // --- LÓGICA DE CONTROLE DO FLAG 'buf_is_full' (ÚNICO DRIVER) ---
    // Este bloco agora é o único "chefe" do registrador buf_is_full
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buf_is_full <= 3'b000;
        end else begin
            // Condição para SETAR um bit: escrita de uma linha terminou
            if (write_handshake_go && wr_ptr == LINE_DEPTH - 1) begin
                buf_is_full[write_buf_idx] <= 1'b1;
            end

            // Condição para LIMPAR um bit: leitura de uma linha terminou
            if (read_handshake_go && rd_ptr == LINE_DEPTH - 1 && !repeat_line) begin
                buf_is_full[read_buf_idx] <= 1'b0;
            end
        end
    end

endmodule