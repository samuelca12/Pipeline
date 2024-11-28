module sumador (
    input logic [W-1:0] entrada1,
    input logic [W-1:0] entrada2,
    output logic [W-1:0] Resultado
);
    parameter W=32;
  
    assign Resultado=entrada1+entrada2;
endmodule