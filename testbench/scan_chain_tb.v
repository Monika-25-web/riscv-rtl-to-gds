`timescale 1ns/1ps
module scan_chain_tb;
 reg clk=0, rst_n=0, scan_en=0, scan_in=0;
 wire scan_out;
 integer i;
 reg [186:0] pattern, captured;
 rv32i_top_scan dut(.clk(clk), .rst_n(rst_n), .scan_en(scan_en),
 .scan_in(scan_in), .scan_out(scan_out));
 always #5 clk = ~clk;
 initial begin
 $dumpfile("scan_dump.vcd");
 $dumpvars(0, scan_chain_tb);
 rst_n = 0; #20; rst_n = 1;
 scan_en = 1;
 pattern = 187'b101010...; // walking-1 pattern, 187 bits long
 for (i = 0; i < 187; i = i + 1) begin
 scan_in = pattern[i];
 @(posedge clk);
 end
 for (i = 0; i < 187; i = i + 1) begin
 captured[i] = scan_out;
 @(posedge clk);
 end
 if (captured == pattern)
 $display("Scan chain integrity : PASS (187/187 bits match)");
 else
 $display("Scan chain integrity : FAIL");
 $finish;
 end
endmodule
