
module pc (
    input clk, rst, stall, input [31:0] pc_next,
    output reg [31:0] pc_out
);
always @(posedge clk or posedge rst) begin
    if (rst) pc_out <= 0;
    else if (!stall) pc_out <= pc_next;
end
endmodule
