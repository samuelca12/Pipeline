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
`include "../src/RegIntermedio.sv"
`include "../src/ForwardingU.sv"
`include "../src/hazard.sv"


module pipeline(
    input logic clk,
    input logic rst
);
    parameter W=32;
    parameter RegAddress=5;

    //Variables de primer pipe        
    logic [W-1:0] pc_in;
    logic [W-1:0] pc_out;
    logic [W-1:0] PC_4;

    logic [W-1:0] instruction;

    logic [2*W-1:0] IF_IDReg;

    //Variables segundo pipe

    logic Branch;
    logic MemRead;
    logic MemReg;
    logic ALUOp;
    logic MemWrite;
    logic ALUSrc;
    logic RegWrite;
    logic salta_registro;
    logic flush;

    logic [1:0] comparador_code;
    logic salto;

    logic [W-1:0] pc_inmediato;
    logic [W-1:0] pc_o_registro;

    logic [W-1:0] storeRegData;
    
    logic [3:0] alu_inst;

    logic [9:0] control_to_reg;

    logic [W-1:0] write_data_reg;
    logic [W-1:0] reg_out1;
    logic [W-1:0] reg_out2;
    
    logic [W-1:0] inmediato;

    //Variables tercer pipe

    logic [1:0] ForwardA;
    logic [1:0] ForwardB;

    logic [W-1:0] reg_to_alu1;
    logic [W-1:0] reg_to_alu2;
    logic [W-1:0] alu_in2;
    logic [W-1:0] ALU_result;
    
    
    //Cuarto pipe
    logic [W-1:0] Read_data;

    //Registros intermedios

    logic [4*W+3*RegAddress-1:0] ID_ExReg;
    logic [3*W+RegAddress-1:0] Ex_MemReg;
    logic [3*W+RegAddress-1:0] Mem_wbReg;

    logic [2:0] WB1; 
    logic [2:0] WB2; 
    logic [2:0] WB3;
    logic [1:0] MEM1;
    logic [1:0] MEM2;
    logic [4:0] EX;   

////////// PRIMER PIPE ///////////
    mux2_1 isTaken (        //Elige siguiente pc
        .select(Branch),       
        .entrada1(PC_4),
        .entrada2(pc_inmediato),   
        .salida_mux(pc_in)
    );

    pc unidad_pc(
        //entradas
        .clk(clk),
        .rst(rst),
        .enable(PC_Write), //VIENE DE HAZARD (estaba en 1'b1)
        .PC_next(pc_in),
        //salidas
        .inst_address(pc_out)
    );

    sumador pc4 (   //suma pc+4 siempre
        .entrada1(pc_out),
        .entrada2(32'b100),
        .Resultado(PC_4)
    );

    inst_memory inst_memory(
        .address(pc_out),
        .instruction(instruction)
    );

    RegIntermedio #(.size(2*W)) IFID (
        .clk(clk),
        .rst(rst||flush),
        .enable(IFIDWrite), //viene del hazard (logica invertida) (revisar)
        .data_in({pc_out, instruction}), //MSB indica flush
        .data_out(IF_IDReg)
    );

////////// SEGUNDO PIPE ///////////                   //va para PC y para el primer registro intermedio
    hazard unidad_hazard (
        .clk(clk),
        .IDEXMemRead(MEM1[1]),                  
        .RegisterRd_ID_EX(ID_ExReg[4*W+RegAddress-1:4*W]),   
        .RegisterRs1_IF_ID(IF_IDReg[19:15]), 
        .RegisterRs2_IF_ID(IF_IDReg[24:20]),  
        .Opcode_IF_ID(IF_IDReg[6:0]),
        .Branch(Branch),       

        .PC_Write(PC_Write),         
        .NoControl(NoControl),
        .IFIDWrite(IFIDWrite)              // Señal del mux para manejar el riesgo
    );

    main_control unidad_main_control (
    //entradas          
    .opcode(IF_IDReg[6:0]),
    .isBranchTrue(salto),
    //salidas
    .Branch(Branch),
    .Mem_read(MemRead),
    .Memto_Reg(MemReg),
    .ALU_OP(ALUOp),
    .Mem_write(MemWrite),
    .ALUSrc(ALUSrc),
    .Reg_Write(RegWrite),
    .salta_registro(salta_registro),
    .flush(flush)                    
    );
    
    control_salto unidad_control_salto_dut ( //Decide si tomar el salto
        .instruccion(IF_IDReg[W-1:0]),
        .comparador_code(comparador_code),
        .salto(salto)
    );

    ALU_CONTROL unidad_alu_control ( //Control de ALU
    //entradas
    .instruccion(IF_IDReg[W-1:0]),
    .ALU_OP(ALUOp),
    //salida
    .alu_inst(alu_inst)
    );

    mux2_1 #(.W(4'b1010)) muxID (
    .select(NoControl||(flush&&!(Reg_Write&&Branch))),    //Flush o hazard detection //viene del hazard? (estaba en 1'b1||1'b0)
    .entrada1({Branch, alu_inst, MemRead, MemReg, MemWrite, ALUSrc, RegWrite}),
    .entrada2(10'b0), //corregir a 1'b0?

    .salida_mux(control_to_reg)
    );

    mux2_1 #(.W()) storeReg ( //Elige qué guardar en el registro 
        .select(WB3[2]),    
        .entrada1(write_data_reg), // WB comun
        .entrada2(Mem_wbReg[3*W-1:2*W]+4), //pc+4

        .salida_mux(storeRegData)
    );

    registro unidad_registro (      
    //entradas
    .clk(clk),
    .rst(rst),
    .rs1(IF_IDReg[19:15]),
    .rs2(IF_IDReg[24:20]),
    .rd(Mem_wbReg[3*W+RegAddress-1:3*W]), 
    .data_in(storeRegData),
    .we(WB3[0]),
    //salidas
    .data_rs1(reg_out1),
    .data_rs2(reg_out2)
    );

    comparador unidad_comparador_dut( //Compara salidas del registro
        .rs1(reg_out1),
        .rs2(reg_out2),

        .comparador_code(comparador_code)   
    );

    imm_gen unidad_imm_gen (
    //entrada
    .inst(IF_IDReg[W-1:0]),
    //salida
    .immediate_gen(inmediato)
    );

    mux2_1 regVSpc (    //elige qué sumar con el inmediato para jalr
        .select(salta_registro),
        .entrada1(IF_IDReg[2*W-1:W]),
        .entrada2(reg_out1),
        .salida_mux(pc_o_registro)
    );

    sumador pc_salto (     //calcula dirección de caso para cualquier tipo de salto
        .entrada1(pc_o_registro), //pc_actual o valor del registro
        .entrada2(inmediato),
        .Resultado(pc_inmediato)
    );

    RegIntermedio #(.size(4*W+3*RegAddress)) IDEX ( 
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .data_in({IF_IDReg[19:15], IF_IDReg[24:20], IF_IDReg[11:7], IF_IDReg[2*W-1:W], reg_out1, reg_out2, inmediato}), //rs1,rs2,rd,pc...

        .data_out(ID_ExReg)
    );
    RegIntermedio #(.size(2'b11)) WB_1 (
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .data_in({control_to_reg[9], control_to_reg[3], control_to_reg[0]}), //Branch, MemReg, RegWrite

        .data_out(WB1)
    );
    RegIntermedio #(.size(2'b10)) MEM_1 (
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .data_in({control_to_reg[4], control_to_reg[2]}), //Mem_read, Mem_write

        .data_out(MEM1)
    );
    RegIntermedio #(.size(3'b101)) EX_reg (  
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .data_in({control_to_reg[1], control_to_reg[8:5]}),  //ALUSrc, alu_inst

        .data_out(EX)
    );
    
////////// TERCER PIPE ///////////

    ForwardingU ForwardingU (
        .WB1(WB2[0]),
        .WB2(WB3[0]),
        .rd1(Ex_MemReg[3*W+RegAddress-1:3*W]),
        .rd2(Mem_wbReg[3*W+RegAddress-1:3*W]),
        .rs1(ID_ExReg[4*W+3*RegAddress-1:4*W+2*RegAddress]),
        .rs2(ID_ExReg[4*W+2*RegAddress-1:4*W+RegAddress]),

        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    mux3_1 alu_in1 ( // Revisar entradas para adelantamiento
        .select(ForwardA),
        .entrada1(ID_ExReg[3*W-1:2*W]), //reg_out1
        .entrada2(storeRegData),     //Lectura de memoria o resultado trasanterior de la ALU
        .entrada3(Ex_MemReg[W-1:0]),  //Resultado anterior de la ALU
        .salida_mux(reg_to_alu1)
    );

    mux3_1 alu_input2 ( //Revisar entradas para adelantamiento
        .select(ForwardB),
        .entrada1(ID_ExReg[2*W-1:W]),  //reg_out2
        .entrada2(storeRegData),    //Lectura de memoria o resultado trasanterior de la ALU
        .entrada3(Ex_MemReg[W-1:0]), //Resultado anterior de la ALU
        .salida_mux(reg_to_alu2)
    );

    mux2_1 alu_in2_imm ( //elige inmediato o salida del registro para entrada de la ALU
    .select(EX[4]), //ALUSrc
    .entrada1(reg_to_alu2),
    .entrada2(ID_ExReg[W-1:0]), //inmediato
    .salida_mux(alu_in2)
    );

    ALU unidad_alu (
    //entradas
    .data_rs1(reg_to_alu1),
    .source_2(alu_in2),
    .op(EX[3:0]),
    //salidas
    .ALU_result(ALU_result)
    );

    RegIntermedio #(.size(3*W+RegAddress)) EXMEM (
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .data_in({ID_ExReg[4*W+RegAddress-1:4*W], ID_ExReg[4*W-1:3*W], reg_to_alu2, ALU_result}), //rd, pc ...

        .data_out(Ex_MemReg)
    );
    RegIntermedio #(.size(2'b11)) WB_2 (
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .data_in(WB1),

        .data_out(WB2)
    );
    RegIntermedio #(.size(2'b10)) MEM_2 (
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .data_in(MEM1),

        .data_out(MEM2)
    );

////////// CUARTO PIPE /////////// 

    data_memory unidad_data_memory( 
    //entradas
    .clk(clk),
    .rst(rst),
    .address(Ex_MemReg[W-1:0]),       // ALU_Result que puede ser la dirección calculada
    .write_data(Ex_MemReg[2*W-1:W]), //reg_to_alu2 que es la salida 2 del registro
    .MemRead(MEM2[1]),
    .MemWrite(MEM2[0]), 
    //salidas
    .read_data(Read_data)  
    );

    RegIntermedio #(.size(3*W+RegAddress)) MEMWB (
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .data_in({Ex_MemReg[3*W+RegAddress-1:3*W], Ex_MemReg[3*W-1:2*W] ,Ex_MemReg[W-1:0], Read_data}), //rd, pc, address/ALU_Result, ...

        .data_out(Mem_wbReg)
    );

    RegIntermedio #(.size(2'b11)) WB_3 (
        .clk(clk),
        .rst(rst),
        .enable(1'b1),
        .data_in(WB2),

        .data_out(WB3)
    );

////////// QUINTO PIPE /////////// 

    mux2_1 mux_writeback ( //Elige si guardar en el registro la salida de la ALU o la lectura de memoria
        .select(WB3[1]),
        .entrada1(Mem_wbReg[2*W-1:W]), //ALU_Result
        .entrada2(Mem_wbReg[W-1:0]), //Read_data
        .salida_mux(write_data_reg)
    );


endmodule
