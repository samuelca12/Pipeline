module pc#(
    parameter ADDRESS_WIDTH = 32,
    parameter MEM_SIZE=256
)
(
input logic rst,
input logic clk,
input logic enable,
input logic  [ADDRESS_WIDTH-1:0] PC_next,

output logic [ADDRESS_WIDTH-1:0] inst_address
);

always_ff @(posedge clk) begin 
    if (rst) begin
        inst_address <= 0;
    end else if ((PC_next<4*(MEM_SIZE-1)) && enable) begin //Que PC_next no exceda la cantidad de bytes direccionables
        inst_address <= PC_next;
    end
end       
    
endmodule
