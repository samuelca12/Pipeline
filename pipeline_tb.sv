`timescale 1ns/1ps
`include "../src/pipeline.sv"

module pipeline_tb;

    // Parámetros y variables
    parameter W = 32;
    
    logic clk;
    logic rst;
    // Instancia del módulo a probar
    pipeline #(.W(W)) dut (
        .clk(clk),
        .rst(rst)
    );
    
    // Generador de reloj
    initial begin
    $dumpfile("pipeline_tb.vcd");
    $dumpvars(0, pipeline_tb);
    end
    initial begin
    clk = 0;
    forever begin
        #10 clk = ~clk;
    end
    end
    initial begin
    rst=1;
    #40;
    rst=0;
    #10000;
    $finish;
    end
    endmodule