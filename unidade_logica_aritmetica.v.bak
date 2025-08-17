// Unidade Lógica Aritmética (ULA) usada para convolução
module ula (
    input  [7:0] A,       // Operando A
    input  [7:0] B,       // Operando B
    input  [1:0] op,      // Código da operação
    output reg [7:0] R,   // Resultado
);

always @(*) begin
    case (op)
        2'b00: R = A + B;   // Soma
        2'b01: R = A - B;   // Subtração
        2'b10: R = A * B;   // Multiplicação simples
        2'b11: R = A / B;   // Divisão simples
        default: R = 8'd0;
    endcase
end

endmodule
