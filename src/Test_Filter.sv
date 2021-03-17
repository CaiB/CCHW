module Test_FilterIIR;
    import CCHWTest::*;
    localparam N = 16;
    localparam CONST = 6;
    localparam FPF = 7;

    logic signed [N-1:0] out, in;
    logic write;
    logic clk, rst;

    FilterIIR #(.N(N), .NI(N), .IIRCONST(CONST)) DUT(.out, .in, .write, .clk, .rst);

    initial
    begin
        clk <= '1;
        forever #50 clk <= ~clk;
    end

    task Reset;
        in = '0;
        write = '0;
        rst = '1;
        repeat(5) @(posedge clk);
        rst = '0; @(posedge clk);
    endtask

    real errorBounds = 0.02;
    real min, max;
    task InsertAndCheck(logic [N-1:0] newData, real expectedOut);
        in = newData;
        write = '1;
        @(posedge clk);
        #10;
        min = expectedOut * (1 - errorBounds);
        max = expectedOut * (1 + errorBounds);
        assert(out > min);
        assert(out < max);
        write = '0;
    endtask

    initial
    begin
        Reset();
        // Numbers just taken from Excel
        InsertAndCheck(16'd10000, 156.25);
        InsertAndCheck(16'd10000, 310.06);
        InsertAndCheck(16'd10000, 461.46);
        InsertAndCheck(16'd10000, 610.50);
        InsertAndCheck(16'd10000, 757.21);
        InsertAndCheck(16'd10000, 901.63);
        InsertAndCheck(16'd10000, 1043.79);
        InsertAndCheck(16'd10000, 1183.74);
        InsertAndCheck(16'd10000, 1321.49);
        InsertAndCheck(16'd20000, 1613.34);
        InsertAndCheck(16'd20000, 1900.63);
        InsertAndCheck(16'd20000, 2183.44);
        InsertAndCheck(16'd20000, 2461.82);
        InsertAndCheck(16'd0, 2423.35);
        InsertAndCheck(16'd0, 2385.49);
        InsertAndCheck(16'd0, 2348.22);
        InsertAndCheck(-16'd1, 2311.51);
        InsertAndCheck(16'd1, 2275.41);
        InsertAndCheck(-16'd1000, 2224.23);
        InsertAndCheck(16'd2224, 2224.23);
        $stop;
    end
endmodule