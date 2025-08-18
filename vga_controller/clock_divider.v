module clock_divider (
    input clk_100mhz, // CLK 100MHz
    output clk_25mhz  // CLK 25MHz
);
    
    reg [1:0] cont;

    always@(posedge clk_100mhz) begin
        if (cont == 2'b11) begin
            clk_25mhz <= ~clk_25mhz;
            cont <= 2'b00;
        end
        else begin
            cont <= cont + 1;
        end
    end

endmodule