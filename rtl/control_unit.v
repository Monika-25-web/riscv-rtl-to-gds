
module control_unit (input [6:0] opcode,
    output reg reg_write,alu_src,mem_read,mem_write,mem_to_reg,branch,jump,
    output reg [1:0] alu_op);
always @(*) begin
    reg_write=0;alu_src=0;mem_read=0;mem_write=0;
    mem_to_reg=0;branch=0;jump=0;alu_op=0;
    case(opcode)
        7'b0110011: begin reg_write=1; alu_op=2'b10; end
        7'b0010011: begin reg_write=1; alu_src=1; alu_op=2'b10; end
        7'b0000011: begin reg_write=1; alu_src=1; mem_read=1; mem_to_reg=1; end
        7'b0100011: begin alu_src=1; mem_write=1; end
        7'b1100011: begin branch=1; alu_op=2'b01; end
        7'b1101111: begin reg_write=1; jump=1; end
        7'b0110111: begin reg_write=1; alu_src=1; alu_op=2'b11; end
        default: ;
    endcase
end
endmodule