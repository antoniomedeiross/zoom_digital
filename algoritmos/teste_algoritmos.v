module test_algoritmos(
    input clk,
    input rst,
    output [7:0] data_out
);

    wire pixel_valid, fim_linha;
    wire [7:0] pixel_out;

    envia_dados ED(
        .clk(clk),          // in
        .rst(rst),          // in
        .pixel_out(pixel_out),       // out
        .pixel_valid_out(pixel_valid)  // out
    );

    line_Buffer LB(
        .clk_in(clk),                   // in
        .rst_in(rst),                   // in
        .data_in(pixel_out),            // in
        .data_valida_in(pixel_valid),   // in
        .data_out_zoom(data_out_zoom),               // out
        .data_out_convolucao(),         // out
        .rd_data_in(1'b1),              // in
        .repeat_line_buffer(repeat_line_buffer),      // in
        .end_line(fim_linha)                     // out
    );

    wire repeat_line_buffer;

    nearest_neighbor NN(
        .clk(clk),                   // in
        .rst(rst),                   // in
        .data_in(data_out_zoom),        // in
        .data_valida_in(pixel_valid), // in
        .data_out(data_out),         // out
        .data_valida_out(data_valid),  // out
        .line_end_in(fim_linha),        // in
        .repeat_line_buffer(repeat_line_buffer) // out
    );

endmodule