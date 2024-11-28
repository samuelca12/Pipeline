module ForwardingU (
    input logic WB1,
    input logic WB2,
    input logic [regAddress_w-1:0] rd1,
    input logic [regAddress_w-1:0] rd2,
    input logic [regAddress_w-1:0] rs1,
    input logic [regAddress_w-1:0] rs2,

    output logic [1:0] ForwardA,
    output logic [1:0] ForwardB
 );
// 00 => Salidas del banco de registros
// 10 => Resultado anterior de la ALU
// 01 => Resultado trasanterior de la ALU o lectura de memoria
parameter regAddress_w=5;    
    always_comb begin
        {ForwardA, ForwardB} = 4'b0;
        if (WB1 && (rd1!=0)) begin
            ForwardA = (rd1==rs1)?2'b10:2'b0;
            ForwardB = (rd1==rs2)?2'b10:2'b0;
        end
        if (WB2 && (rd2 != 0) && !(WB1 && (rd1 != 0) && (rd1 == rs1)) && (rd2 == rs1)) 
            ForwardA = 2'b01;

        if (WB2 && (rd2 != 0) && !(WB1 && (rd1 != 0) && (rd1 == rs2)) && (rd2 == rs2)) 
            ForwardB = 2'b01;
    end
endmodule