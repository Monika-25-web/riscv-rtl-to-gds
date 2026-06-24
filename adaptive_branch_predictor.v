module adaptive_branch_predictor (
    input clk, rst,
    input [31:0] fetch_pc,
    input is_branch_fetch,
    input branch_resolved,
    input actual_taken,
    output predict_taken,
    output active_predictor
);

    reg [1:0] table_2bit [0:63];
    reg       table_1bit [0:63];

    wire [5:0] idx      = fetch_pc[7:2];
    wire       pred_2bit = table_2bit[idx][1];
    wire       pred_1bit = table_1bit[idx];

    reg active_pred_r;
    reg [7:0] mis_2bit, mis_1bit, branch_count;

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            active_pred_r <= 0;
            mis_2bit      <= 0;
            mis_1bit      <= 0;
            branch_count  <= 0;
            for (i = 0; i < 64; i = i + 1) begin
                table_2bit[i] <= 2'b01;
                table_1bit[i] <= 1'b0;
            end
        end
        else if (branch_resolved) begin

            // Update 2-bit saturating counter
            if (actual_taken) begin
                if (table_2bit[idx] != 2'b11)
                    table_2bit[idx] <= table_2bit[idx] + 1;
            end else begin
                if (table_2bit[idx] != 2'b00)
                    table_2bit[idx] <= table_2bit[idx] - 1;
            end

            // Update 1-bit predictor
            table_1bit[idx] <= actual_taken;

            // Count mispredictions
            if (pred_2bit != actual_taken)
                mis_2bit <= mis_2bit + 1;
            if (pred_1bit != actual_taken)
                mis_1bit <= mis_1bit + 1;

            // Every 256 branches, pick better predictor
            branch_count <= branch_count + 1;
            if (branch_count == 8'hFF) begin
                if (mis_1bit < mis_2bit)
                    active_pred_r <= 1;
                else
                    active_pred_r <= 0;
                mis_2bit     <= 0;
                mis_1bit     <= 0;
                branch_count <= 0;
            end
        end
    end

    assign predict_taken    = active_pred_r ? pred_1bit : pred_2bit;
    assign active_predictor = active_pred_r;

endmodule