module control_salto #(
    parameter W = 32
) (
    input logic [W-1:0] instruccion, 
    input logic [1:0] comparador_code,
    output logic salto 
);
   
wire [2:0] field_3 = instruccion[14:12];
wire isEqual = comparador_code[0];   //Primer bit indica igualdad
wire isGreater = comparador_code[1];    //Segundo bit indica si es mayor
   always_comb begin
    case (field_3)
        3'b000: salto=isEqual; //beq
        3'b001: salto=!isEqual; //bne
        3'b101: salto=isGreater; //bge
        3'b100: salto=!isGreater; //blt
        default: salto=1'b0;
    endcase
    end
endmodule

