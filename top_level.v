module top_level(
    input clk,
    input rst,
    input [7:0] pixel_in,
    input pixel_valid_in,
    input line_end_in,
    output [7:0] pixel_out,
    input zoom_in,
    output pixel_valid_out
);

wire [7:0] pixel_out_buffer;
wire pixel_valid_out;
wire repeat_line_buffer;

line_Buffer line_buffer (
    .clk_in(clk),
    .rst_in(rst),
    .data_in(pixel_in),
    .data_valida_in(pixel_valid_in),
    .data_out_zoom(pixel_out_buffer),
    .data_out_convolucao(),
    .data_valida_out(pixel_valid_out),
    .rd_data_in(1'b1), // sempre lendo
    .line_end(line_end_in),
    .line_repeat(repeat_line_buffer) 
);

nearest_neighbor nearest_neighbor (
    .clk(clk),
    .rst(rst),
    .pixel_in(pixel_out_buffer),
    .pixel_valid_in(pixel_valid_out),
    .line_end_in(line_end_in),
    .pixel_out(pixel_out),
    .pixel_valid_out(pixel_valid_out),
    .zoom_in(zoom_in),
    .repeat_line_buffer(repeat_line_buffer)
);

endmodule