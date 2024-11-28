module mux2_1 (
    input logic select,
    input logic [W-1:0] entrada1,
    input logic [W-1:0] entrada2,

    output logic [W-1:0] salida_mux
);

parameter W=32;

always_comb begin
    case(select)
        1'b0: salida_mux=entrada1;
        1'b1: salida_mux=entrada2;
        
    endcase
end
  
endmodule