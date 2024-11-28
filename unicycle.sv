`include "../src/ALU_CONTROL.sv"
`include "../src/ALU.sv"
`include "../src/data_memory.sv"
`include "../src/imm_gen.sv"
`include "../src/inst_memory.sv"
`include "../src/main_control.sv"
`include "../src/mux2_1.sv"
`include "../src/mux3_1.sv"
`include "../src/comparador.sv"
`include "../src/control_salto.sv"
`include "../src/pc.sv"
`include "../src/registro.sv"
`include "../src/sumador.sv"

module unicycle #(
    parameter W=32
)(
    input logic clk, rst
    //definir salidas para valiar el funcionamiento
    //output logic
);
// ''cablesde conexión''

logic [W-1:0] pc_in;
logic [W-1:0] pc_out;


logic [W-1:0] instruction;

logic [W-1:0] inmediato;

logic [W-1:0] write_data;
logic [W-1:0] data1;
logic [W-1:0] data2;

logic [3:0] alu_inst;
logic [W-1:0] alu_in;
logic zero;
logic [W-1:0] ALU_result;

logic [W-1:0] Read_data;
logic [W-1:0] Result;

logic andresult;

logic [W-1:0] pc_inm_next; 

//cables de main_control
logic Branch;
logic MemRead;
logic [1:0] MemReg;
logic [1:0] ALUOp;
logic MemWrite;
logic ALUSrc;
logic RegWrite;
logic salto_incon;
logic flag_direccion;

//instancias de los modulos
pc unidad_pc(
    //entradas
    .clk(clk),
    .rst(rst),
    .PC_next(pc_in),
    //salidas
    .inst_address(pc_out)
);



inst_memory inst_memory(
    .address(pc_out),
    .instruction(instruction)
);

//fraccionamos la señal de instruccion a continuación:
imm_gen unidad_imm_gen (
    //entrada
    .inst(instruction),
    //salida
    .immediate_gen(inmediato)
);


main_control unidad_main_control (
    //entradas
    .opcode(instruction[6:0]),
    //salidas
    .Branch(Branch),
    .Mem_read(MemRead),
    .Memto_Reg(MemReg),
    .ALU_OP(ALUOp),
    .Mem_write(MemWrite),
    .ALUSrc(ALUSrc),
    .Reg_Write(RegWrite),
    .salto_incon(salto_incon),
    .flag_direccion(flag_direccion)                        
);

registro unidad_registro (
    //entradas
    .clk(clk),
    .rst(rst),
    .rs1(instruction[19:15]),
    .rs2(instruction[24:20]),
    .rd(instruction[11:7]),
    .data_in(write_data),
    .we(RegWrite),
    //salidas
    .data_rs1(data1),
    .data_rs2(data2)
);

////////////-BRANCHES-//////////////
logic [1:0] comparador_code;
comparador unidad_comparador_dut(
    .rs1(data1),
    .rs2(data2),
    .comparador_code(comparador_code)
);
logic salto;
control_salto unidad_control_salto_dut (
    .instruccion(instruction),
    .comparador_code(comparador_code),
    .salto(salto)
);
////////////////////////////////////

mux2_1 unidad_mux_salida_registro (
    .select(ALUSrc),
    .entrada1(data2),
    .entrada2(inmediato),
    .salida_mux(alu_in)
);

ALU_CONTROL unidad_alu_control (
    //entradas
    .instruccion(instruction),
    .ALU_OP(ALUOp),
    //salida
    .alu_inst(alu_inst)
);

ALU unidad_alu (
    //entradas
    .data_rs1(data1),
    .source_2(alu_in),
    .op(alu_inst),
    //salidas
    .zero(zero),
    .ALU_result(ALU_result)
);

data_memory unidad_data_memory( 
    //entradas
    .clk(clk),
    .address(ALU_result),
    .write_data(data2),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .rst(rst),
    //salidas
    .read_data(Read_data)  
);

//////////inclusion de PC+4 EN WRITE-BACK///////////
mux3_1 unidad_mux_salida_memoria (
    //entradas
    .select(MemReg),
    .entrada2(Read_data),
    .entrada1(ALU_result),
    .entrada3(pc_inm_next),
    //salidas
    .salida_mux(write_data)
);
///////////////////////////////////////////////////

logic [31:0] cuatro = 32'd4;
sumador unidad_sumador_PC_4 (
    //entradas
    .pc_actual(pc_out),
    .inmediato(cuatro),
    //salidas
    .Result(pc_inm_next)
);

////////PC+INMEDIATO (BRANCHES O JAL) O RS1 +INMEDIATO (JALR)//////
logic [W-1:0] sumando_direccion;
mux2_1 unidad_mux_sumador_direccion_dut (
    .select(flag_direccion),
    .entrada1(pc_out),
    .entrada2(data1),
    .salida_mux(sumando_direccion)
);
sumador unidad_sumador (
    //entradas
    .pc_actual(sumando_direccion), //para el posible caso de jalr
    .inmediato(inmediato),
    //salidas
    .Result(Result)
);
///////////////////////////////////////////////////

//la siguiente linea resuelve el salto de los branches (según sea el valor de 'salto')
logic salida_and;
assign salida_and= Branch && salto;
logic select_mux_sumador;
assign select_mux_sumador= salida_and || salto_incon;
mux2_1 unidad_mux_salida_sumador (
    //entradas
    .select(select_mux_sumador),  //esta linea resuelve el caso de salto de banches y/o saltos incondicionales
    //.select(Branch && zero),
    .entrada1(pc_inm_next),
    .entrada2(Result),
    //salida
    .salida_mux(pc_in)
);
endmodule
