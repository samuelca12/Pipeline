`timescale 1ns/ 1ps
module hazard(
    input logic clk,
    input logic IDEXMemRead,                  //Proviene de ID/EX*
    input logic [4:0] RegisterRd_ID_EX,   // Registro de destino en ID/EX*
    input logic [4:0] RegisterRs1_IF_ID,  // Registro fuente rs1 en IF/ID
    input logic [4:0] RegisterRs2_IF_ID,  // Registro fuente rs2 en IF/ID
    input logic [6:0] Opcode_IF_ID,       // Opcode de la instrucción en IF/ID*
    input logic Branch,
    
    output logic PC_Write,          // Señal combinada para PCwrite y IF_IDwrite
    output logic NoControl,
    output logic IFIDWrite               // Señal del mux para manejar el riesgo
);
    // Definir los opcodes relevantes
    localparam BRANCH_OP = 7'b1100011;   // Opcode para beq, bne, blt, bge
    localparam JAL_OP = 7'b1101111;      // Opcode para jal
    localparam JALR_OP = 7'b1100111;     // Opcode para jalr

logic cont;

    always_comb begin
        // inicializar las señales de salida:
        PC_Write = 1;
        IFIDWrite = 1;
        NoControl = 0;
        cont = 0;
            // Detectar riesgos de datos tipo RAW (solo para lw)
        if (IDEXMemRead && ((RegisterRd_ID_EX == RegisterRs1_IF_ID) || (RegisterRd_ID_EX == RegisterRs2_IF_ID))) begin //Stall
            IFIDWrite = 0; 
            PC_Write = 0;
            NoControl = 1; 
        end
        // Detectar riesgos de control
        case (Opcode_IF_ID)
            BRANCH_OP:
                NoControl=Branch?1'b1:1'b0;  //Flush
            JAL_OP, JALR_OP:          //Stall
                NoControl=0; 
        endcase
    end
endmodule
