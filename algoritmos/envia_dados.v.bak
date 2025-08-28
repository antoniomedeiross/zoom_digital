//////////////////////////////////////////////////////////
// Modulo que simula o envio de dados para os algoritmos//
//////////////////////////////////////////////////////////
module envia_dados(
    input             clk,
    input             rst,
    output reg [7:0]  pixel_out,
    output reg        pixel_valid_out
);

reg [7:0] pixel_mem [0:15]; // 4x4 = 16 pixels

initial begin
    pixel_mem[0]  = 8'h01;  pixel_mem[1]  = 8'h02;  pixel_mem[2]  = 8'h03;  pixel_mem[3]  = 8'h04;
    pixel_mem[4]  = 8'h05;  pixel_mem[5]  = 8'h06;  pixel_mem[6]  = 8'h07;  pixel_mem[7]  = 8'h08;
    pixel_mem[8]  = 8'h09;  pixel_mem[9]  = 8'h0A;  pixel_mem[10] = 8'h0B;  pixel_mem[11] = 8'h0C;
    pixel_mem[12] = 8'h0D;  pixel_mem[13] = 8'h0E;  pixel_mem[14] = 8'h0F;  pixel_mem[15] = 8'h10;
end


integer i;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        i <= 0;
        pixel_valid_out <= 0;
    end else if (i < 16) begin
        pixel_out <= pixel_mem[i];
        pixel_valid_out <= 1; // pixel válido todo ciclo
        i <= i + 1;
    end else begin
        pixel_valid_out <= 0; // sinaliza fim dos pixels
    end
end



endmodule
