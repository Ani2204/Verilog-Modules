module asyncFIFO_tb;

    reg         wen, ren;
    reg         rclk = 0;
    reg         wclk = 0;
    reg         rstn;
    reg  [7:0]  wdata;
    wire [7:0]  rdata;
    wire        full, empty;

    asyncFIFO dut (
        .wen(wen),
        .ren(ren),
        .rclk(rclk),
        .wclk(wclk),
        .rstn(rstn),
        .wdata(wdata),
        .rdata(rdata),
        .full(full),
        .empty(empty)
    );

    always #5 rclk = ~rclk; 
    always #2.5 wclk = ~wclk; 

    initial begin
        rstn = 0;
        wen = 0;
        ren = 0;
        wdata = 8'h00;

        #12 rstn = 1; 

        wen = 1;
        wdata = 8'hA5; #10;
        wdata = 8'h5A; #10;
        wen = 0; 
        ren = 1; #10;

        #10 $finish;
    end
    
endmodule 
