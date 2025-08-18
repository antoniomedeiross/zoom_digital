module image_reader #(
    parameter IMG_WIDTH = 320,
    parameter IMG_HEIGHT = 240
)(
    input wire clk,
    input wire rst,
    output reg [7:0] pixel_out,     // pixel atual
    output reg pixel_valid,         // indica que pixel_out é válido
    output reg [15:0] pixel_addr    // endereço atual da ROM
);

    reg [9:0] x;  // contador de colunas
    reg [8:0] y;  // contador de linhas

    // Instancia a ROM gerada pelo Quartus a partir do .mif
    wire [7:0] rom_pixel; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x <= 0;
            y <= 0;
            pixel_addr <= 0;
            pixel_out <= 0;
            pixel_valid <= 0;
        end else begin
            pixel_out <= rom_pixel;     // pega o pixel atual da ROM
            pixel_valid <= 1;           // pixel válido
            pixel_addr <= y * IMG_WIDTH + x;  // calcula endereço

            // Atualiza x e y
            if (x == IMG_WIDTH-1) begin
                x <= 0;
                if (y == IMG_HEIGHT-1) begin
                    y <= 0;  // volta ao início da imagem
                end else begin
                    y <= y + 1;
                end
            end else begin
                x <= x + 1;
            end
        end
    end
endmodule
