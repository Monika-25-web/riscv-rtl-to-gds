module riscv_top (input clk, input rst,
    output [31:0] debug_wb_data,   // write-back result, for visibility
    output [31:0] debug_pc         // current PC, for visibility
);

    wire stall;
    wire predict_taken, active_predictor, is_branch_fetch;
    wire pmp_violation;
    wire [31:0] pmp_violation_count;
    wire [31:0] pc_current, pc_next;
    wire [31:0] instruction;

    // ===================== STAGE 1: FETCH =====================
    pc PC (.clk(clk), .rst(rst), .stall(stall), .pc_next(pc_next), .pc_out(pc_current));
    instruction_memory IMEM (.pc(pc_current), .instruction(instruction));
    assign is_branch_fetch = (instruction[6:0] == 7'b1100011);

    adaptive_branch_predictor ABP (
    .clk(clk),
    .rst(rst),
    .fetch_pc(pc_current),
    .is_branch_fetch(is_branch_fetch),
    .branch_resolved(ex_mem_branch),
    .actual_taken(ex_mem_zero),
    .predict_taken(predict_taken),
    .active_predictor(active_predictor));

    wire [31:0] pc_plus4 = pc_current + 4;

    // IF/ID pipeline register
    reg [31:0] if_id_instr, if_id_pc;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            if_id_instr <= 0; if_id_pc <= 0;
        end else if (!stall) begin
            if_id_instr <= instruction; if_id_pc <= pc_current;
        end
    end

    // ===================== STAGE 2: DECODE =====================
    wire [6:0] opcode = if_id_instr[6:0];
    wire [4:0] rs1 = if_id_instr[19:15];
    wire [4:0] rs2 = if_id_instr[24:20];
    wire [4:0] rd  = if_id_instr[11:7];
    wire [2:0] funct3 = if_id_instr[14:12];
    wire funct7_5 = if_id_instr[30];

    wire reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump;
    wire [1:0] alu_op;

    control_unit CU (.opcode(opcode), .reg_write(reg_write), .alu_src(alu_src),
        .mem_read(mem_read), .mem_write(mem_write), .mem_to_reg(mem_to_reg),
        .branch(branch), .jump(jump), .alu_op(alu_op));

    wire [31:0] read_data1, read_data2;
    wire wb_reg_write;
    wire [4:0] wb_rd;
    wire [31:0] write_back_data;

    register_file RF (.clk(clk), .rst(rst), .rs1(rs1), .rs2(rs2), .rd(wb_rd),
        .write_data(write_back_data), .reg_write(wb_reg_write),
        .read_data1(read_data1), .read_data2(read_data2));

    wire [31:0] imm_out;
    imm_gen IMM (.instruction(if_id_instr), .imm_out(imm_out));

    wire hz_pc_write, hz_if_id_write, hz_control_mux_sel;
    hazard_unit HZ (.id_ex_rd(id_ex_rd), .id_ex_mem_read(id_ex_mem_read),
        .if_id_rs1(rs1), .if_id_rs2(rs2),
        .pc_write(hz_pc_write), .if_id_write(hz_if_id_write), .control_mux_sel(hz_control_mux_sel));

    assign stall = !hz_pc_write;

    // ID/EX pipeline register
    reg id_ex_reg_write, id_ex_alu_src, id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg, id_ex_branch;
    reg [1:0] id_ex_alu_op;
    reg [31:0] id_ex_read_data1, id_ex_read_data2, id_ex_imm, id_ex_pc;
    reg [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    reg [2:0] id_ex_funct3;
    reg id_ex_funct7_5;

    always @(posedge clk or posedge rst) begin
    if (rst) begin
        id_ex_reg_write<=0; id_ex_alu_src<=0; id_ex_mem_read<=0; id_ex_mem_write<=0;
        id_ex_mem_to_reg<=0; id_ex_branch<=0; id_ex_alu_op<=0;
        id_ex_read_data1<=0; id_ex_read_data2<=0; id_ex_imm<=0; id_ex_pc<=0;
        id_ex_rs1<=0; id_ex_rs2<=0; id_ex_rd<=0; id_ex_funct3<=0; id_ex_funct7_5<=0;
    end else if (hz_control_mux_sel) begin
        id_ex_reg_write<=0; id_ex_alu_src<=0; id_ex_mem_read<=0; id_ex_mem_write<=0;
        id_ex_mem_to_reg<=0; id_ex_branch<=0; id_ex_alu_op<=0;
        id_ex_read_data1<=0; id_ex_read_data2<=0; id_ex_imm<=0; id_ex_pc<=0;
        id_ex_rs1<=0; id_ex_rs2<=0; id_ex_rd<=0; id_ex_funct3<=0; id_ex_funct7_5<=0;
    end else begin
        id_ex_reg_write<=reg_write; id_ex_alu_src<=alu_src; id_ex_mem_read<=mem_read;
        id_ex_mem_write<=mem_write; id_ex_mem_to_reg<=mem_to_reg; id_ex_branch<=branch;
        id_ex_alu_op<=alu_op; id_ex_read_data1<=read_data1; id_ex_read_data2<=read_data2;
        id_ex_imm<=imm_out; id_ex_pc<=if_id_pc;
        id_ex_rs1<=rs1; id_ex_rs2<=rs2; id_ex_rd<=rd;
        id_ex_funct3<=funct3; id_ex_funct7_5<=funct7_5;
    end
end

    // ===================== STAGE 3: EXECUTE =====================
    wire [1:0] forward_a, forward_b;
    forwarding_unit FU (.ex_mem_rd(ex_mem_rd), .mem_wb_rd(mem_wb_rd),
        .ex_mem_reg_write(ex_mem_reg_write), .mem_wb_reg_write(mem_wb_reg_write),
        .id_ex_rs1(id_ex_rs1), .id_ex_rs2(id_ex_rs2),
        .forward_a(forward_a), .forward_b(forward_b));

    wire [31:0] alu_in_a = (forward_a==2'b10) ? ex_mem_alu_res :
                           (forward_a==2'b01) ? write_back_data : id_ex_read_data1;
    wire [31:0] fwd_b    = (forward_b==2'b10) ? ex_mem_alu_res :
                           (forward_b==2'b01) ? write_back_data : id_ex_read_data2;
    wire [31:0] alu_in_b = id_ex_alu_src ? id_ex_imm : fwd_b;

    wire [3:0] alu_ctrl;
    alu_control AC (.alu_op(id_ex_alu_op), .funct3(id_ex_funct3), .funct7_5(id_ex_funct7_5), .alu_ctrl(alu_ctrl));

    wire [31:0] alu_result;
    wire alu_zero;
    alu ALU (.a(alu_in_a), .b(alu_in_b), .alu_ctrl(alu_ctrl), .result(alu_result), .zero(alu_zero));

    wire [31:0] branch_target = id_ex_pc + id_ex_imm;
    assign pc_next = (id_ex_branch && alu_zero) ? branch_target : (pc_current + 4);

    // EX/MEM pipeline register
    reg ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg, ex_mem_branch, ex_mem_zero;
    reg [31:0] ex_mem_alu_res, ex_mem_rd2;
    reg [4:0] ex_mem_rd;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ex_mem_reg_write<=0; ex_mem_mem_read<=0; ex_mem_mem_write<=0; ex_mem_mem_to_reg<=0;
            ex_mem_branch<=0; ex_mem_zero<=0; ex_mem_alu_res<=0; ex_mem_rd2<=0; ex_mem_rd<=0;
        end else begin
            ex_mem_reg_write<=id_ex_reg_write; ex_mem_mem_read<=id_ex_mem_read;
            ex_mem_mem_write<=id_ex_mem_write; ex_mem_mem_to_reg<=id_ex_mem_to_reg;
            ex_mem_branch<=id_ex_branch; ex_mem_zero<=alu_zero;
            ex_mem_alu_res<=alu_result; ex_mem_rd2<=fwd_b; ex_mem_rd<=id_ex_rd;
        end
    end

    // ===================== STAGE 4: MEMORY =====================
    wire [31:0] mem_read_data;
    data_memory DMEM (.clk(clk), .address(ex_mem_alu_res), .write_data(ex_mem_rd2),
        .mem_read(ex_mem_mem_read), .mem_write(ex_mem_mem_write), .read_data(mem_read_data));
   // Data Cache
wire cache_hit;
wire [31:0] cache_read_data, hit_count, miss_count;

data_cache DCACHE (
    .clk(clk),
    .rst(rst),
    .address(ex_mem_alu_res),
    .write_data(ex_mem_rd2),
    .mem_read(ex_mem_mem_read),
    .mem_write(ex_mem_mem_write),
    .mem_data_in(mem_read_data),
    .read_data(cache_read_data),
    .cache_hit(cache_hit),
    .hit_count(hit_count),
    .miss_count(miss_count));
     // PMP privilege timer
reg priv_mode;
reg [7:0] mode_timer;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        priv_mode  <= 1;
        mode_timer <= 0;
    end else if (mode_timer < 3)
        mode_timer <= mode_timer + 1;
    else
        priv_mode <= 0;
end

pmp_unit PMP (
    .clk(clk),
    .rst(rst),
    .mem_addr(ex_mem_alu_res),
    .mem_access(ex_mem_mem_read | ex_mem_mem_write),
    .priv_mode(priv_mode),
    .violation(pmp_violation),
    .violation_count(pmp_violation_count));
    // MEM/WB pipeline register
    reg mem_wb_reg_write, mem_wb_mem_to_reg;
    reg [31:0] mem_wb_alu_res, mem_wb_mem_data;
    reg [4:0] mem_wb_rd;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_wb_reg_write<=0; mem_wb_mem_to_reg<=0; mem_wb_alu_res<=0; mem_wb_mem_data<=0; mem_wb_rd<=0;
        end else begin
            mem_wb_reg_write<=ex_mem_reg_write; mem_wb_mem_to_reg<=ex_mem_mem_to_reg;
            mem_wb_alu_res<=ex_mem_alu_res; mem_wb_mem_data<=cache_read_data; mem_wb_rd<=ex_mem_rd;
        end
    end

    // ===================== STAGE 5: WRITE BACK =====================
    assign write_back_data = mem_wb_mem_to_reg ? mem_wb_mem_data : mem_wb_alu_res;
    assign wb_reg_write = mem_wb_reg_write;
    assign wb_rd = mem_wb_rd;
    assign debug_wb_data = write_back_data;  // or mem_wb_alu_res, whatever your WB mux output is named
    assign debug_pc = pc_current;
endmodule
