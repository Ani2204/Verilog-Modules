module syncFIFO (
    input            wen, ren,
    input            clk,
    input            rstn,
    input      [7:0] wdata,
    output reg [7:0] rdata,
    output reg       full, empty
);

    reg  [7:0] mem [0:15];
    reg  [4:0] wptr, rptr;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            wptr <= 0;
        end else if (wen && !full) begin
            mem[wptr] <= wdata;
            wptr <= wptr + 1'b1;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rptr <= 0;
        end else if (ren && !empty) begin
            rdata <= mem[rptr];
            rptr <= rptr + 1'b1;
        end
    end

    always @(*) begin
        full = (wptr[4] != rptr[4]) && (wptr[3:0] == rptr[3:0]);
        empty = (wptr == rptr);
    end
    
endmodule