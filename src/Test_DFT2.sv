module Test_OperationCounter;
    localparam OCT = 5;
    localparam BINS = 24;
    logic [$clog2(OCT)-1:0] octave;
    logic operation;
    logic [$clog2(BINS)-1:0] bin;
    logic finished;
    logic enable;
    logic clk, rst;

    OperationCounter #(.OCT(OCT), .BINS(BINS)) DUT(.octave, .operation, .bin, .finished, .enable, .clk, .rst);

    initial
    begin
        clk <= '0;
        forever #100 clk <= ~clk;
    end
    
    task Reset;
        enable = '1;
        rst = '1; @(posedge clk);
        rst = '0; @(posedge clk);
        assert(~finished);
    endtask

    task VerifyBinCounts(logic expectedOp, logic [$clog2(OCT)-1:0] expectedOct);
        for(int binInd = 0; binInd < BINS; binInd++)
        begin
            assert(bin == binInd);
            assert(operation == expectedOp);
            assert(octave == expectedOct);
            assert(finished == (binInd == BINS-1 && expectedOp && expectedOct == OCT-1));
            if(~finished) @(posedge clk);
        end
    endtask

    initial
    begin
        Reset();
        for(int octInd = 0; octInd < OCT; octInd++)
        begin
            VerifyBinCounts('0, octInd);
            VerifyBinCounts('1, octInd);
        end
        enable = '0;
        repeat(5) @(posedge clk);
        assert(bin == '0);
        assert(~operation);
        assert(octave == '0);
        $stop;
    end
endmodule

module Test_WritePulseGen;
    logic [3:0] writeLines;
    logic incr;
    logic clk, rst;

    WritePulseGen #(.N(4)) DUT(.writeLines, .incr, .clk, .rst);

    initial
    begin
        clk <= '0;
        forever #100 clk <= ~clk;
    end
    
    task Reset;
        rst = '1;
        incr = '0;

        @(posedge clk);
        rst = '0;
        @(posedge clk);
    endtask

    task CheckNone;
        assert(writeLines == '0);
    endtask

    task Check(logic [3:0] expected);
        #5;
        assert(writeLines == expected);
    endtask

    initial
    begin
        Reset();

        // Make sure we don't count without incr on
        CheckNone();
        @(posedge clk);
        CheckNone();

        incr = '1;
        @(posedge clk); Check(4'b0001); // 0001
        @(posedge clk); Check(4'b0010); // 0010
        @(posedge clk); Check(4'b0001); // 0011
        @(posedge clk); Check(4'b0100); // 0100
        @(posedge clk); Check(4'b0001); // 0101
        @(posedge clk); Check(4'b0010); // 0110
        @(posedge clk); Check(4'b0001); // 0111
        @(posedge clk); Check(4'b1000); // 1000
        @(posedge clk); Check(4'b0001); // 1001
        @(posedge clk);
        $stop;
    end
endmodule

module Test_OctaveStorage;
    logic signed [15:0] sample0, sample1, oldestSample;
    logic signed [15:0] newSample;
    logic writeSample;
    logic clk, rst;
    
    OctaveStorage #(.N(16), .SIZE(8)) DUT (.sample0, .sample1, .oldestSample, .newSample, .writeSample, .clk, .rst);

    initial
    begin
        clk <= '0;
        forever #100 clk <= ~clk;
    end

    task Reset;
        rst = '1;
        newSample = '0;
        writeSample = '0;

        @(posedge clk);
        rst = '0;
        @(posedge clk);
    endtask

    task Insert(logic signed [15:0] toAdd);
        newSample = toAdd;
        writeSample = '1;
        @(posedge clk);
        writeSample = '0;
    endtask

    task Verify(logic signed [15:0] expected0, logic signed [15:0] expected1, logic signed [15:0] expectedOld);
        assert(sample0 == expected0);
        assert(sample1 == expected1);
        assert(oldestSample == expectedOld);
    endtask

    initial
    begin
        Reset();
        Verify(16'd0, 16'd0, 16'd0);
        
        Insert(16'd100);
        Insert(16'd222);

        Verify(16'd100, 16'd0, 16'd0);

        Insert(-16'd333);
        Verify(16'd222, 16'd100, 16'd0);

        Insert(16'd444); // 100 in slot 2
        Verify(-16'd333, 16'd222, 16'd0);

        Insert(16'd555); // 100 in slot 3
        Insert(16'd666); // 100 in slot 4
        Insert(16'd777); // 100 in slot 5
        Insert(16'd888); // 100 in slot 6
        Insert(16'd9999); // 100 in old

        Verify(16'd888, 16'd777, 16'd100);

        Insert(16'd0);
        Verify(16'd9999, 16'd888, 16'd222);

        newSample = -16'd1;
        writeSample = '0; // false write

        @(posedge clk);
        Verify(16'd0, 16'd9999, -16'd333);

        @(posedge clk);
        Verify(16'd0, 16'd9999, -16'd333);

        @(posedge clk);
        $stop();
    end
endmodule