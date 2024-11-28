module ALU_CONTROL #(
    parameter width_instruc = 32
) (
    input logic [width_instruc-1:0] instruccion, 
    input logic ALU_OP,
    output logic [3:0] alu_inst
);
    wire isRinst = instruccion[5];
    wire [2:0] field_3 = instruccion[14:12];
    wire I_30 = instruccion[30];

   always_comb begin : alu_case
    case (ALU_OP)
        1'b0: alu_inst = 4'b0010; // add
        1'b1: begin
            if (isRinst) begin   //case para instrucciones tipo R
                case (field_3)
                    3'b000: alu_inst = I_30 ? 4'b0110 : 4'b0010; //sub-add
                    3'b111: alu_inst = 4'b0000; //and
                    3'b110: alu_inst = 4'b0001; //or
                    3'b100: alu_inst = 4'b0011; //xor
                    3'b101: alu_inst = I_30 ? 4'b1010 : 4'b1000; //sra-srl
                    3'b001: alu_inst = 4'b1001;    //sll
                    3'b010: alu_inst = 4'b1100;       //slt
                    3'b011: alu_inst = 4'b1110;       //sltu
                    default: alu_inst = 4'b0010;
                endcase
            end
            else begin      //Caso para instrucciones tipo I
                case (field_3)
                    3'b000: alu_inst = 4'b0010; //addi
                    3'b111: alu_inst = 4'b0000; //andi
                    3'b110: alu_inst = 4'b0001; //ori
                    3'b100: alu_inst = 4'b0011; //xori
                    3'b101: alu_inst = I_30 ? 4'b1010 : 4'b1000; //srai-srli
                    3'b001: alu_inst = 4'b1001; //slli
                    3'b010: alu_inst = 4'b1100;    //slti
                    3'b011: alu_inst = 4'b1110;    //sltui

                    default: alu_inst = 4'b0010;
                endcase
            end
        end 
        default: alu_inst = 4'b0010; // Default case for unhandled ALU_OP values
    endcase
end


endmodule
