module mux3_1 #(parameter W=32) (
    input logic [1:0] select,
    input logic [W-1:0] entrada1,
    input logic [W-1:0] entrada2,
    input logic [W-1:0] entrada3,

    output logic [W-1:0] salida_mux
);

always_comb begin
case(select)
    2'b00: salida_mux=entrada1;
    2'b01: salida_mux=entrada2;
    2'b10: salida_mux=entrada3;
    
endcase

end
  
endmodule