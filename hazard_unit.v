

module hazard_unit (input [4:0] id_ex_rd, input id_ex_mem_read,
    input [4:0] if_id_rs1, if_id_rs2,
    output reg pc_write, if_id_write, control_mux_sel);
always @(*) begin
    if (id_ex_mem_read && ((id_ex_rd==if_id_rs1)||(id_ex_rd==if_id_rs2))) begin
        pc_write=0; if_id_write=0; control_mux_sel=1;
    end else begin
        pc_write=1; if_id_write=1; control_mux_sel=0;
    end
end
endmodule

