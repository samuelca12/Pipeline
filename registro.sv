module registro #(
parameter W = 32,
parameter N=5
)(
    input logic clk,
    input logic [N-1:0] rs1,
    input logic [N-1:0] rs2,
    input logic [N-1:0] rd,
    input logic rst,
    input logic we,
    input logic [W-1:0] data_in,
    output logic [W-1:0] data_rs1,
    output logic [W-1:0] data_rs2
);
    reg  [W-1:0] registers[(2**N)-1:0];

    // Lee rs1 y rs2 en el flanco negativo
    always @(negedge clk) begin
        if (rst) begin
            data_rs1 <= 32'b0;
            data_rs2 <= 32'b0;
        end else begin
            if(rs1 != 0) begin
                data_rs1 <= registers[rs1];
                if (rd==rs1) data_rs1<= data_in;
            end
            else
                data_rs1 <= 32'b0;

            if (rs2 != 0) begin
                data_rs2 <= registers[rs2];
                if (rd==rs2) data_rs2<= data_in;
            end
            else
                data_rs2 <= 32'b0;
        end
    end

    // Escribe en el flanco positivo
    always @(posedge clk) begin
        if (rst) begin
            foreach(registers[i]) begin
                registers[i] <= 0;
            end
        end else begin
            if (we && (rd != 0)) begin 
                registers[rd] <= data_in;
            end       
        end
    end
endmodule
