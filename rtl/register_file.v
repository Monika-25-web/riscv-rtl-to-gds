
module register_file (
    input clk, rst, input [4:0] rs1, rs2, rd,
    input [31:0] write_data, input reg_write,
    output [31:0] read_data1, read_data2
);
reg [31:0] registers [0:31]; integer i;
assign read_data1 = (rs1==0) ? 0 : registers[rs1];
assign read_data2 = (rs2==0) ? 0 : registers[rs2];
always @(posedge clk or posedge rst) begin
    if (rst) for (i=0;i<32;i=i+1) registers[i] <= 0;
    else if (reg_write && rd!=0) registers[rd] <= write_data;
end
endmodule
