module imm_gen #(parameter DATA_WIDTH=32)(
    input [DATA_WIDTH-1:0] inst,
    output logic [DATA_WIDTH-1:0] immediate_gen
);
logic [DATA_WIDTH-1:0] inmediato; //signo extendido de immediate
logic [DATA_WIDTH-1:0] inmediato_jal; //signo extendio de immediate_jal
logic [11:0] immediate;
logic [19:0] immediate_jal;
wire [2:0] field_3 = inst[14:12];
always @* begin
        case (inst[6:0])   
            7'b0000011, 7'b0010011 : begin   //I-type
                if (field_3==3'b001 || field_3==3'b101) begin immediate=inst[24:20]; immediate_jal=0; end//srai slli srli tienen un inmediato más corto
                else begin immediate =inst[31:20]; immediate_jal=0; end
            end

            7'b0100011: begin  //S-type
                immediate={inst[31:25],inst[11:7]};
                immediate_jal=0;
            end
            
            7'b1100011:  begin  //SB-type
                immediate={inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
                immediate_jal=0;
            end
            7'b1101111: begin //jal
                immediate_jal={inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
                immediate=0;
            end
            7'b1100111: begin //jalr
                immediate={inst[31:20]};//revisar si es necesaria concatenar un 0 al inicio
                immediate_jal=0;
            end
            default: begin immediate=0; immediate_jal=0;
            end
        endcase
        inmediato=$signed(immediate);
        inmediato_jal=$signed(immediate_jal);
end
assign immediate_gen=$signed(inmediato | inmediato_jal);

endmodule