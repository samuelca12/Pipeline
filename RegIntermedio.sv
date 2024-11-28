module RegIntermedio(
    input logic rst,
    input logic clk,
    input logic enable,
    input logic [size-1:0] data_in,
    output logic [size-1:0] data_out
);

parameter size = 1;

always @(posedge clk) begin 
    if (rst) data_out<=0;
    else if (enable) data_out<=data_in; 
end
    
endmodule