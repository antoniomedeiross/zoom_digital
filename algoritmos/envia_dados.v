/////////////////////////////////////////////////////////////////////////////
// Módulo gerador de padrão de imagem (Datafeeder)
/////////////////////////////////////////////////////////////////////////////
module envia_dados (
    // --- Interface Global ---
    input           clk,
    input           rst,

    // --- Interface de Saída com Handshake ---
    output  [7:0]   pixel_out,     
    output          pixel_valid_out,
    input           pixel_ready_in
);

    // --- Parâmetros ---
    parameter IMG_WIDTH  = 4;
    parameter IMG_HEIGHT = 4;
    localparam IMG_PIXELS = IMG_WIDTH * IMG_HEIGHT;
    localparam ADDR_WIDTH = $clog2(IMG_PIXELS);

    // --- Memória (ROM) para a imagem de teste ---
    reg [7:0] pixel_rom [0:IMG_PIXELS-1];

    initial begin
        $readmemh("pixel_data.mem", pixel_rom);
    end
    
    // --- Lógica do Contador ---
    reg [ADDR_WIDTH:0] pixel_count;
    
    wire handshake_go = pixel_valid_out && pixel_ready_in;

    // A lógica de controle do contador agora está isolada
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pixel_count <= 0;
        end else if (handshake_go) begin
            // O contador só avança se a transferência foi bem-sucedida
            if (pixel_count < IMG_PIXELS) begin
                pixel_count <= pixel_count + 1;
            end
        end
    end

    // --- Lógica de Saída ---
    // O pixel de saída é uma leitura direta da ROM baseada no contador atual.
    assign pixel_out = pixel_rom[pixel_count];

    // A saída é válida se o contador ainda não terminou e o reset não está ativo.
    assign pixel_valid_out = (pixel_count < IMG_PIXELS) && !rst;

endmodule