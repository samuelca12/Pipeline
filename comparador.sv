module comparador (
    input logic [31:0] rs1, // Primer número
    input logic [31:0] rs2, // Segundo número
    output logic [1:0] comparador_code // Salida de 2 bits

);
//LSB indica igualdad (1) o desigualdad (0)
//MSB indica mayor (1) o menor (0)
assign comparador_code={rs1>=rs2, rs1==rs2};

endmodule
