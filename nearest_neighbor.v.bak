
module nearest_neighbor(
    input clk,
    input rst,
    input [7:0] pixel_in,      // Pixel vindo do line buffer
    input pixel_valid_in,       // Indica que o pixel_in é válido
    input line_end_in,          // Indica fim da linha no buffer
    output reg [7:0] pixel_out,// Pixel processado (zoom aplicado)
    output reg pixel_valid_out, // Pixel de saída válido
    input zoom_in,              // 1 = zoom in 2x, 0 = zoom out 1/2x
    output reg repeat_line_buffer
);

reg [7:0] last_pixel;      // Guarda o último pixel lido
reg repeat_pixel;          // Controla repetição horizontal
reg repeat_line;           // Controla repetição vertical
reg line_done;             // Indica se a linha já foi duplicada (vertical)

always @(posedge clk or posedge rst) begin
    // reseta todas as saidas
    if (rst) begin 
        pixel_out <= 0;
        pixel_valid_out <= 0;
        last_pixel <= 0;
        repeat_pixel <= 0;
        repeat_line <= 0;
        line_done <= 0;
    end 
    else if (pixel_valid_in) begin
        // =============================
        // Zoom-in 2x 
        // =============================
        if (zoom_in) begin
            if (~repeat_pixel) begin
                pixel_out <= pixel_in; // envia o pixel
                last_pixel <= pixel_in;
                repeat_pixel <= 1;     // próxima vez repete o mesmo pixel
            end else begin
                pixel_out <= last_pixel; // repete o mesmo pixel
                repeat_pixel <= 0;       // volta a ler próximo pixel
            end
            pixel_valid_out <= 1;
        end 
        // =============================
        // Zoom-out 1/2x 
        // =============================
        else begin
            if (~repeat_pixel) begin
                pixel_out <= pixel_in;  // envia pixel
                repeat_pixel <= 1;      // pula o próximo
                pixel_valid_out <= 1;
            end else begin
                repeat_pixel <= 0;      // pula pixel
                pixel_valid_out <= 0;   // pixel descartado
            end
        end
    end

    // =============================
    // Zoom vertical 
    // =============================
    if (line_end_in) begin
        // Se ainda não repetiu a linha, repetimos
        if (~line_done) begin // line done = 0
            repeat_line_ <= 1;
            repeat_line_buffer <= 1
            line_done <= 1;
        end else begin
            repeat_line <= 0;
            repeat_line_buffer <= 0;
            line_done <= 0;
        end
    end
end

endmodule
