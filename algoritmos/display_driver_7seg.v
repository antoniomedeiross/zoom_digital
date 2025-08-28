////////////////////////////////////////////////////////////////////////////////
// Driver de Display 7 Segmentos com Efeito de "Piscada"
////////////////////////////////////////////////////////////////////////////////
module display_driver_7seg (
    input           clk_50mhz,
    input           rst,
    
    // Entrada de dados vinda do seu 'top'
    input  [7:0]    pixel_data_in,
    input           new_data_tick, // Conectar ao 'tick_1hz'

    // Saídas para os displays físicos da placa
    output [6:0]    HEX0, // Dígito menos significativo (direita)
    output [6:0]    HEX1  // Dígito mais significativo (esquerda)
);

    // Divisão do pixel em dois dígitos de 4 bits
    wire [3:0] digit_low  = pixel_data_in[3:0];
    wire [3:0] digit_high = pixel_data_in[7:4];
    
    // Fios para os segmentos decodificados
    wire [6:0] segments_low;
    wire [6:0] segments_high;

    // Instancia dois decodificadores
    hex_to_7seg decoder_low  (.hex_digit_in(digit_low),  .segments_out(segments_low));
    hex_to_7seg decoder_high (.hex_digit_in(digit_high), .segments_out(segments_high));

    // --- Lógica de Controle da "Piscada" ---
    localparam STATE_OFF = 1'b0;
    localparam STATE_ON  = 1'b1;
    reg state;

    // Timer para manter o display aceso por ~0.8s e apagado por ~0.2s
    localparam ON_CYCLES = 50_000_000 * 8 / 10; // 40 Milhões de ciclos
    reg [25:0] on_timer;

    always @(posedge clk_50mhz or posedge rst) begin
        if (rst) begin
            state <= STATE_OFF;
            on_timer <= 0;
        end else begin
            case (state)
                STATE_OFF: begin
                    // Se recebemos um novo tick, acendemos o display e iniciamos o timer
                    if (new_data_tick) begin
                        state <= STATE_ON;
                        on_timer <= 0;
                    end
                end
                STATE_ON: begin
                    // Mantém aceso até o timer estourar, então apaga
                    if (on_timer == ON_CYCLES - 1) begin
                        state <= STATE_OFF;
                        on_timer <= 0;
                    end else begin
                        on_timer <= on_timer + 1;
                    end
                end
            endcase
        end
    end
    
    // --- Lógica de Saída Final ---
    // Se o estado for 'ON', mostra os segmentos decodificados.
    // Se for 'OFF', manda o sinal para apagar todos os segmentos (7'b1111111).
    assign HEX0 = (state == STATE_ON) ? segments_low  : 7'b1111111;
    assign HEX1 = (state == STATE_ON) ? segments_high : 7'b1111111;

endmodule


////////////////////////////////////////////////////////////////////////////////
// Sub-módulo: Decodificador de Hexadecimal para 7 Segmentos (Ativo-Baixo)
////////////////////////////////////////////////////////////////////////////////
module hex_to_7seg (
    input  [3:0] hex_digit_in,
    output [6:0] segments_out // Formato: {g,f,e,d,c,b,a}
);

    assign segments_out = (hex_digit_in == 4'h0) ? 7'b1000000 : // 0
                          (hex_digit_in == 4'h1) ? 7'b1111001 : // 1
                          (hex_digit_in == 4'h2) ? 7'b0100100 : // 2
                          (hex_digit_in == 4'h3) ? 7'b0110000 : // 3
                          (hex_digit_in == 4'h4) ? 7'b0011001 : // 4
                          (hex_digit_in == 4'h5) ? 7'b0010010 : // 5
                          (hex_digit_in == 4'h6) ? 7'b0000010 : // 6
                          (hex_digit_in == 4'h7) ? 7'b1111000 : // 7
                          (hex_digit_in == 4'h8) ? 7'b0000000 : // 8
                          (hex_digit_in == 4'h9) ? 7'b0010000 : // 9
                          (hex_digit_in == 4'hA) ? 7'b0001000 : // A
                          (hex_digit_in == 4'hB) ? 7'b0000011 : // b
                          (hex_digit_in == 4'hC) ? 7'b1000110 : // C
                          (hex_digit_in == 4'hD) ? 7'b0100001 : // d
                          (hex_digit_in == 4'hE) ? 7'b0000110 : // E
                          (hex_digit_in == 4'hF) ? 7'b0001110 : // F
                                                 7'b1111111;  // Apagado

endmodule