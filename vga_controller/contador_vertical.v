module contador_vertical (
    input clk_25mhz,
    input rst,
    input ativa_v_counter,
    output reg [15:0] v_value = 0,
    );



    always @(posedge clk_25mhz) begin
        if (ativa_v_counter == 1'b1) begin
            if (v_value < 524) begin
                v_value <= v_value + 1;  // Increment vertical counter until 525
            end else begin
                v_value <= 0;            // Reset vertical counter
            end
        end
    end

endmodule