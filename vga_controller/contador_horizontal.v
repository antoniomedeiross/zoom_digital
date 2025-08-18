module contador_horizontal (
    input clk_25mhz,
    input rst,
    output reg [15:0] h_value = 0,
    output reg ativa_v_counter = 0
    );


    always @(posedge clk_25mhz) begin
        if (rst) begin
            h_value <= 0;
        else if (h_value < 799) begin
            h_value <= h_value + 1;  // Increment horizontal counter until 800
            ativa_v_counter <= 0;    // Desativa vertical counter enquanto h_value < 800
        end else begin
            h_value <= 0;            // Reset horizontal counter
            ativa_v_counter <= 1;    // Ativa vertical counter quando h_value atinge 800

        end
    end

endmodule