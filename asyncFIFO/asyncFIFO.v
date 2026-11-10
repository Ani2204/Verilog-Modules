module asyncFIFO (
    input            wen, ren,
    input            wclk, rclk,
    input            rstn,
    input      [7:0] wdata,
    output reg [7:0] rdata,
    output reg       full, empty
);

    reg  [7:0] mem [0:15];
    reg  [4:0] wptr, rptr;
    wire [4:0] wptr_gray, rptr_gray;
    reg  [4:0] wptr_gray_sync1, wptr_gray_sync2;
    reg  [4:0] rptr_gray_sync1, rptr_gray_sync2;
    wire [4:0] wptr_binary, rptr_binary;

    always @(posedge wclk or negedge rstn) begin
        if (!rstn) begin
            wptr <= 0;
        end else if (wen && !full) begin
            mem[wptr] <= wdata;
            wptr <= wptr + 1'b1;
        end
    end

    always @(posedge rclk or negedge rstn) begin
        if (!rstn) begin
            rptr <= 0;
        end else if (ren && !empty) begin
            rdata <= mem[rptr];
            rptr <= rptr + 1'b1;
        end
    end

    assign wptr_gray = (wptr >> 1) ^ wptr;
    assign rptr_gray = (rptr >> 1) ^ rptr;

    always @(posedge rclk or negedge rstn) begin
        if (!rstn) begin
            wptr_gray_sync1 <= 0;
            wptr_gray_sync2 <= 0;
        end else begin
            wptr_gray_sync1 <= wptr_gray;
            wptr_gray_sync2 <= wptr_gray_sync1;
        end
    end

    always @(posedge wclk or negedge rstn) begin
        if (!rstn) begin
            rptr_gray_sync1 <= 0;
            rptr_gray_sync2 <= 0;
        end else begin
            rptr_gray_sync1 <= rptr_gray;
            rptr_gray_sync2 <= rptr_gray_sync1;
        end
    end

    assign wptr_binary = {wptr_gray_sync2[4], wptr_gray_sync2[3] ^ wptr_gray_sync2[4], wptr_gray_sync2[2] ^ wptr_gray_sync2[3] ^ wptr_gray_sync2[4], wptr_gray_sync2[1] ^ wptr_gray_sync2[2] ^ wptr_gray_sync2[3] ^ wptr_gray_sync2[4], wptr_gray_sync2[0] ^ wptr_gray_sync2[1] ^ wptr_gray_sync2[2] ^ wptr_gray_sync2[3] ^ wptr_gray_sync2[4]};
    assign rptr_binary = {rptr_gray_sync2[4], rptr_gray_sync2[3] ^ rptr_gray_sync2[4], rptr_gray_sync2[2] ^ rptr_gray_sync2[3] ^ rptr_gray_sync2[4], rptr_gray_sync2[1] ^ rptr_gray_sync2[2] ^ rptr_gray_sync2[3] ^ rptr_gray_sync2[4], rptr_gray_sync2[0] ^ rptr_gray_sync2[1] ^ rptr_gray_sync2[2] ^ rptr_gray_sync2[3] ^ rptr_gray_sync2[4]};

    always @(*) begin
        empty = (rptr_binary[4:0] == wptr_binary[4:0]);
        full = (wptr_binary[4:0] == {~rptr_binary[4], rptr_binary[3:0]});
    end

endmodule