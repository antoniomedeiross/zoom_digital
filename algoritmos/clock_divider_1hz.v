module clock_divider_1hz (
    input  clk_50mhz,
    input  rst,
    output reg tick_1hz
);
    reg [25:0] counter;
    localparam COUNT_MAX = 25'd25_000_000; // 50M / 2

    always @(posedge clk_50mhz or posedge rst) begin
        if (rst) begin
            counter <= 0;
            tick_1hz <= 1'b0;
        end else begin
            if (counter == COUNT_MAX - 1) begin
                counter <= 0;
                tick_1hz <= 1'b1; // Gera um pulso de 1 ciclo a cada meio segundo
            end else begin
                counter <= counter + 1;
                tick_1hz <= 1'b0;
            end
        end
    end
endmodule