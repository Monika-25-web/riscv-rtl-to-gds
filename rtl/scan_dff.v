module scan_dff #(parameter W = 32) (
 input wire clk,
 input wire rst_n,
 input wire scan_en,
 input wire scan_in,
 input wire [W-1:0] d,
 output reg [W-1:0] q,
 output wire scan_out
);
 wire [W-1:0] mux_d = scan_en ? {q[W-2:0], scan_in} : d;
 always @(posedge clk or negedge rst_n)
 if (!rst_n) q <= {W{1'b0}};
 else q <= mux_d;
 assign scan_out = q[W-1];
endmodule
