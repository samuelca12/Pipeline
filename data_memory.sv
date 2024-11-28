module data_memory #(
parameter DATA_WIDTH = 32,
parameter N=8,
parameter memzise=32
)(
    input logic clk,
    input logic rst,
    //señales de la memoria
    input logic [DATA_WIDTH-1:0] address, //dirección de consulta
    input logic [DATA_WIDTH-1:0] write_data, //valor de almacenamiento
    
    //Señales de control
    input logic MemRead, 
    input logic MemWrite, 
 
    //a la salida mostramos el contenido de la memoria
    output logic [DATA_WIDTH-1:0] read_data
);
//Crea el espacio de memoria
logic  [DATA_WIDTH-1:0] mem[(memzise)-1:0];


//inicializa la memoria
initial begin
    $readmemh("data.hex",mem,0,31);
end

assign read_data=(MemRead & !rst) ? mem[address[9:2]]: 32'b0; 

//que hace según el clk y control
always_ff @(posedge clk) begin
    if (MemWrite)    
        mem[address[9:2]]<=write_data;
end

endmodule

