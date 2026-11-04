module apb_tb;

    reg             pclk, presetn;
    reg             pselx, penable, pwrite;
    reg      [31:0] padder, pwdata;
    wire     [31:0] prdata;
    wire            pready, pslverr;

    apb uut (
        .pclk(pclk),
        .presetn(presetn),
        .pselx(pselx),
        .penable(penable),
        .pwrite(pwrite),
        .padder(padder),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr)
    );

    // Clock generation
    initial begin
        pclk = 0;
        forever #5 pclk = ~pclk;
    end

    // Test stimulus
    initial begin
        $dumpfile("apb_tb.vcd");
        $dumpvars(0, apb_tb);

        // Initial values
        presetn = 0;
        pselx   = 0;
        penable = 0;
        pwrite  = 0;
        padder  = 0;
        pwdata  = 0;

        // Reset
        repeat(2) @(negedge pclk);
        presetn = 1;

        // -------------------------
        // WRITE TEST
        // -------------------------
        @(negedge pclk);
        pselx  = 1;
        pwrite = 1;
        padder = 32'h00000008;
        pwdata = 32'h12345678;

        // Setup -> Access
        @(negedge pclk);
        penable = 1;

        // Wait for transaction completion
        @(negedge pclk);
        pselx   = 0;
        penable = 0;

        // -------------------------
        // READ TEST
        // -------------------------
        @(negedge pclk);
        pselx  = 1;
        pwrite = 0;
        padder = 32'h00000008;

        @(negedge pclk);
        penable = 1;

        @(negedge pclk);
        $display("READ DATA = %h", prdata);
        pselx   = 0;
        penable = 0;

        // -------------------------
        // INVALID ADDRESS TEST
        // -------------------------
        @(negedge pclk);
        pselx  = 1;
        pwrite = 1;
        padder = 32'h00000040;
        pwdata = 32'hABCDEF12;

        @(negedge pclk);
        penable = 1;

        @(negedge pclk);
        $display("ERROR = %b, READY = %b", pslverr, pready);
        pselx   = 0;
        penable = 0;

        #20;
        $finish;
    end

endmodule