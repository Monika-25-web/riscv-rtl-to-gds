
module riscv_tb;
reg clk, rst;
riscv_top DUT (.clk(clk), .rst(rst));
always #5 clk = ~clk; // 10ns period = 100MHz
initial begin
$dumpfile("simulation/riscv_wave.vcd");
$dumpvars(0, riscv_tb);
end
initial begin
clk=0; rst=1; #20; rst=0; #500000;
$display("Simulation complete at time %0t", $time);
$finish;
end
endmodule

