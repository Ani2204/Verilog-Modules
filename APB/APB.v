module apb (
    input             pclk, presetn,
    input             pselx, penable, pwrite,
    input      [31:0] padder, pwdata,
    output reg [31:0] prdata,
    output reg        pready, pslverr
);

    reg [31:0] mem [0:15];

    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            prdata  <= 32'd0;
            pready  <= 1'b0;
            pslverr <= 1'b0;
        end
        else begin
            pready  <= 1'b0;
            pslverr <= 1'b0;

            if (pselx && penable) begin
                if ((padder[31:6] == 0) && (padder[1:0] == 0)) begin
                    pready <= 1'b1;
                    pslverr <= 1'b0;
                    if (pwrite) begin
                        mem[padder[5:2]] <= pwdata;
                    end
                    else begin
                        pslverr <= 1'b0;
                        prdata <= mem[padder[5:2]];
                    end

                end
                else begin
                    pready  <= 1'b1;
                    pslverr <= 1'b1;
                end
            end
        end
    end

endmodule