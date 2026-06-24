module data_cache (
    input clk, rst,
    input [31:0] address, write_data,
    input mem_read, mem_write,
    input [31:0] mem_data_in,
    output [31:0] read_data,
    output cache_hit,
    output reg [31:0] hit_count, miss_count
);
    reg [31:0] cache_data  [0:7];
    reg [25:0] cache_tag   [0:7];
    reg        cache_valid [0:7];
    integer i;

    wire [2:0]  line = address[4:2];
    wire [25:0] tag  = address[31:6];

    assign cache_hit  = mem_read &&
                        cache_valid[line] &&
                        (cache_tag[line] == tag);

    assign read_data  = cache_hit ? cache_data[line] : mem_data_in;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0;i<8;i=i+1)
                cache_valid[i] <= 0;
            hit_count  <= 0;
            miss_count <= 0;
        end else begin
            if (mem_read) begin
                if (cache_hit)
                    hit_count <= hit_count + 1;
                else begin
                    miss_count          <= miss_count + 1;
                    cache_data[line]    <= mem_data_in;
                    cache_tag[line]     <= tag;
                    cache_valid[line]   <= 1;
                end
            end
            if (mem_write &&
                cache_valid[line] &&
                cache_tag[line] == tag)
                cache_data[line] <= write_data;
        end
    end
endmodule