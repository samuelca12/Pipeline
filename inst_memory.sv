module inst_memory #(
    parameter DATA_WIDTH=32,
    parameter ADDRESS_WIDTH=32, // EN REALIDAD NO NECESITAMOS TOS LOS BITS POR EL TAMAÑO DE LA MEMORY
    parameter MEM_SIZE=256
) (
    input logic [ADDRESS_WIDTH-1:0] address,
    output logic [DATA_WIDTH-1:0] instruction
);
    
    //creación del espacio de memory

    logic [DATA_WIDTH-1:0] inst_memory[0:MEM_SIZE-1];

//inicializa la memoria
    initial begin
        $readmemh("prueba2.hex",inst_memory);
    end


    assign instruction=inst_memory[address[9:2]];
endmodule