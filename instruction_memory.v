
module instruction_memory (
    input  [31:0] pc,
    output [31:0] instruction
);
    reg [31:0] mem [0:255];

    initial begin
        mem[0] = 32'h00500093; // ADDI x1,x0,5
        mem[1] = 32'h00A00113; // ADDI x2,x0,10
        mem[2] = 32'h00208133; // ADD  x2,x1,x2 (=15)
        mem[3] = 32'h0020c463; // BLT  x1,x2,+8 (taken)
        mem[4] = 32'h00100193; // ADDI x3,x0,1 (skipped)
        mem[5] = 32'h00312023; // SW   x2,0(x0)
        mem[6] = 32'h00002283; // LW   x5,0(x0)
        mem[7] = 32'h00002303; // LW   x6,0(x0) ← cache hit
    end

    assign instruction = mem[pc[9:2]];
endmodule
