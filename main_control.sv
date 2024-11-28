module main_control #(
    parameter width_instruc = 7
) (
    input logic [width_instruc-1:0] opcode,
    input logic isBranchTrue, //condición del branch

    output logic ALUSrc,
    output logic Memto_Reg,
    output logic Reg_Write,
    output logic Mem_read,
    output logic Mem_write,                              
    output logic Branch,
    output logic ALU_OP,  
    output logic salta_registro,
    output logic flush
);
    
    always_comb begin
        case (opcode)
             7'b1101111 : begin  // jal-type
                ALU_OP = 1'b0;  
                ALUSrc = 0;
                Memto_Reg =0;
                Reg_Write = 1; //escribimos pc+4 en write back
                Mem_read = 0;
                Mem_write = 0;
                Branch = 1; 
                salta_registro=0;
                flush=1;
            end
            7'b1100111 : begin  // jalr-type
                ALU_OP = 1'b0;  
                ALUSrc =0;
                Memto_Reg = 0; //escribimos pc+4 en write back
                Reg_Write = 1;
                Mem_read = 0;
                Mem_write = 0;
                Branch = 1;
                salta_registro=1;
                flush = 1;
            end
            /////////////////////////////////
            7'b0110011 : begin  // R-type
                ALU_OP = 1'b1; 
                ALUSrc = 0;
                Memto_Reg = 0;
                Reg_Write = 1;
                Mem_read = 0;
                Mem_write = 0;
                Branch = 0;
                salta_registro=0;
            end
            7'b0000011 : begin // lw
                ALU_OP = 1'b0; 
                ALUSrc = 1;
                Memto_Reg = 1;
                Reg_Write = 1;
                Mem_read = 1;
                Mem_write = 0;
                Branch = 0;
                salta_registro=0;
            end
            7'b0010011 : begin // inmediate R
                ALU_OP = 1'b1; 
                ALUSrc = 1;
                Memto_Reg = 0;
                Reg_Write = 1;
                Mem_read = 0;
                Mem_write = 0;
                Branch = 0;
                salta_registro=0;
            end
            7'b0100011: begin   //S-type
                ALU_OP = 1'b0; 
                ALUSrc = 1;
                Memto_Reg = 0;
                Reg_Write = 0;
                Mem_read = 0;
                Mem_write = 1;
                Branch = 0;
                salta_registro=0;
            end
            7'b1100011: begin   // SB-type
                ALU_OP = 1'b0; 
                ALUSrc = 0;
                Memto_Reg = 0;
                Reg_Write = 0;
                Mem_read = 0;
                Mem_write = 0;
                Branch = isBranchTrue? 1'b1:1'b0;
                salta_registro=0;
                flush = isBranchTrue? 1'b1:1'b0;
            end
            default: begin // Default case
                flush = 0;
                ALU_OP = 1'b0; 
                ALUSrc = 0;
                Memto_Reg = 0;
                Reg_Write = 0;
                Mem_read = 0;
                Mem_write = 0;
                Branch = 0;
                salta_registro=0;
            end
        endcase
    end

endmodule
