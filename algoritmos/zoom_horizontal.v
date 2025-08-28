module zoom_horizontal (
    input           clk,
    input           rst,
    input   [7:0]   pixel_in,
    input           pixel_valid_in,
    output  reg [7:0]   pixel_out,
    output  reg     pixel_valid_out,
    output          pixel_ready_out,
    input           zoom_in
);

    reg [7:0] last_pixel;
    reg       state;

    localparam S_READ = 1'b0;
    localparam S_HOLD = 1'b1;

    // O módulo está pronto para receber um novo pixel apenas quando está no estado S_READ.
    assign pixel_ready_out = (state == S_READ);
    
    // O handshake acontece quando a entrada é válida E nós estamos prontos.
    wire handshake_go = pixel_valid_in && pixel_ready_out;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pixel_out       <= 8'b0;
            pixel_valid_out <= 1'b0;
            last_pixel      <= 8'b0;
            state           <= S_READ;
        end else begin
            // --- Lógica de Zoom In ---
            if (zoom_in) begin
                case (state)
                    S_READ: begin
                        pixel_valid_out <= 1'b0;
                        if (handshake_go) begin
                            pixel_out       <= pixel_in;
                            last_pixel      <= pixel_in;
                            pixel_valid_out <= 1'b1;
                            state           <= S_HOLD;
                        end
                    end
                    S_HOLD: begin
                        pixel_out       <= last_pixel;
                        pixel_valid_out <= 1'b1;
                        state           <= S_READ;
                    end
                endcase
            // --- Lógica de Zoom Out ---
            end else begin
                if (state == S_READ) begin
                    if (handshake_go) begin
                        pixel_out       <= pixel_in;
                        pixel_valid_out <= 1'b1; // Saída válida neste ciclo
                        state           <= S_HOLD;
                    end else begin
                        pixel_valid_out <= 1'b0; // Se não há handshake, saída inválida
                    end
                end else begin // state == S_HOLD
                    pixel_valid_out <= 1'b0; // Saída inválida neste ciclo
                    state           <= S_READ;
                end
            end
        end
    end
endmodule
