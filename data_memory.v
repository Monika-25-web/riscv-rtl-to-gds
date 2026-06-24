
module data_memory (
    input clk, input [31:0] address, write_data,
    input mem_read, mem_write, output reg [31:0] read_data
);
reg [31:0] mem [0:255]; integer i;
initial for (i=0;i<256;i=i+1) mem[i]=0;
always @(*)
    read_data = mem_read ? mem[address[9:2]] : 32'b0;
always @(posedge clk)
    if (mem_write) mem[address[9:2]] <= write_data;
endmodule
