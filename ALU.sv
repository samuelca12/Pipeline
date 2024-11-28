module ALU #(parameter DATA_WIDTH=32)(
    input logic [DATA_WIDTH-1:0] data_rs1,
    input logic [DATA_WIDTH-1:0] source_2,
    input logic [3:0] op,                  // operacion que la alu realiza
    output logic [DATA_WIDTH-1:0] ALU_result                    // flag de cero como resultado
);

always_comb begin     // define la salida de la ALU
    case(op)
        4'b0010 : ALU_result = data_rs1 + source_2;  // suma
        4'b0110 : ALU_result = data_rs1 - source_2;  // resta
        4'b0000 : ALU_result = data_rs1 & source_2;  // AND
        4'b0001 : ALU_result = data_rs1 | source_2; // OR
        4'b0011 : ALU_result = data_rs1 ^ source_2; //XOR
        4'b1000 : ALU_result = data_rs1 >> source_2; //srl y srli (el resto del inmediato es 0)
        4'b1001 : ALU_result = data_rs1 << source_2; //sll y slli (el resto del inmediato es 0)
        4'b1010 : ALU_result = $signed(data_rs1) >>> source_2; //sra y srai (el resto del inmediato es 0)
        4'b1100 : ALU_result = ($signed(data_rs1) < $signed(source_2)) ? 32'd1 : 32'd0;  //slt y slti
        4'B1110 : ALU_result = (data_rs1 < source_2) ? 32'd1 : 32'd0;  //sltu y sltui
        default: ALU_result = data_rs1 + source_2;
    endcase
end

endmodule
