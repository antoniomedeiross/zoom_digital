module vga_controller_top #(
    input clk_in, // 100 MHz
    input rst, // Reset signal
    output h_sync,
    output v_sync,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue
);


    wire clk_25mhz, ativa_v_counter;
    wire [15:0] h_value;
    wire [15:0] v_value;


    clock_divider clk_div (
        .clk_in(clk_in),
        .clk_out(clk_25mhz)
    );


    contador_horizontal h_counter (
        .clk_25mhz(clk_25mhz),
        .rst(rst),
        .h_value(h_value)
    );

    contador_vertical v_counter (
        .clk_25mhz(clk_25mhz),
        .rst(rst),
        .ativa_v_counter(ativa_v_counter),
        .v_value(v_value)
    );


    // Saidas
    assign h_sync = (h_value < 96) ? 1'b1 : 1'b0; // Horizontal sync pulse
    assign v_sync = (v_value < 2) ? 1'b1 : 1'b0; // Vertical sync pulse
    
    // Cores
    assign red =   (h_value < 784 && h_value > 143 && v_value < 515 && v_value > 35) ? 4'hF : 4'h0;
    assign green = (h_value < 784 && h_value > 143 && v_value < 515 && v_value > 35) ? 4'hF : 4'h0;
    assign blue =  (h_value < 784 && h_value > 143 && v_value < 515 && v_value > 35) ? 4'hF : 4'h0;

endmodule