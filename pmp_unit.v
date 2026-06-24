module pmp_unit (
    input clk, rst,
    input [31:0] mem_addr,
    input mem_access,
    input priv_mode,
    output reg violation,
    output reg [31:0] violation_count
);
    reg [31:0] pmp_base, pmp_bound;
    initial begin
        pmp_base  = 32'h0;
        pmp_bound = 32'h4;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            violation       <= 0;
            violation_count <= 0;
        end else begin
            violation <= 0;
            if (mem_access && !priv_mode &&
                mem_addr >= pmp_base &&
                mem_addr <= pmp_bound) begin
                violation       <= 1;
                violation_count <= violation_count + 1;
            end
        end
    end
endmodule