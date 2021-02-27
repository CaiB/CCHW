module Test_OperationManager;
    localparam OCT = 5;
    localparam BINS = 24;
    
    logic [$clog2(OCT)-1:0] octave;
    logic operation; // add / subtract
    logic [$clog2(BINS)-1:0] bin;
    logic ready; // asserted while we are ready and waiting for an audio sample
    logic writeSample; // asserted for 1 cycle before processing to write the sample into each octave
    logic finishedProcessing; // asserted for 1 clock cycle after the current sample is done being processed

    logic sampleReady;
    logic clk, rst;

    OperationManager #(.OCT(OCT), .BINS(BINS)) DUT(.*);

    initial
    begin
        clk <= '0;
        forever #100 clk <= ~clk;
    end
    
    task Reset;
        sampleReady = '0;
        rst = '1; @(posedge clk);
        rst = '0; @(posedge clk);
        assert(~finishedProcessing);
        assert(~writeSample);
        assert(ready);
    endtask

    task VerifyBinCounts(logic expectedOp, logic [$clog2(OCT)-1:0] expectedOct);
        for(int binInd = 0; binInd < BINS; binInd++)
        begin
            #5;
            assert(bin == binInd) else $display("%5t: Expected bin %2d, was %2d", $time, binInd, bin);
            assert(operation == expectedOp);
            assert(octave == expectedOct);
            assert(~writeSample);
            if(~(binInd == BINS-1 && expectedOp && expectedOct == OCT-1)) @(posedge clk);
        end
    endtask

    initial
    begin
        Reset();
        sampleReady = '1; @(posedge clk);
        sampleReady = '0;
        #5; assert(writeSample);
        @(posedge clk);
        #5; assert(~writeSample);

        for(int octInd = 0; octInd < OCT; octInd++)
        begin
            VerifyBinCounts('0, octInd);
            VerifyBinCounts('1, octInd);
        end
        @(posedge clk);
        #5; assert(finishedProcessing);

        repeat(5) @(posedge clk);
        assert(bin == '0);
        assert(~operation);

        // Again, but this time pretend there's multiple samples waiting
        sampleReady = '1; @(posedge clk);
        #5; assert(writeSample);
        @(posedge clk);
        #5; assert(~writeSample);

        for(int octInd = 0; octInd < OCT; octInd++)
        begin
            VerifyBinCounts('0, octInd);
            VerifyBinCounts('1, octInd);
        end
        @(posedge clk);
        #5; assert(finishedProcessing);

        repeat(5) @(posedge clk);
        sampleReady = '0;
        repeat(50) @(posedge clk);

        $stop;
    end

endmodule

module Test_OctaveSelector;
    parameter OCT = 4;
    logic [OCT-1:0] enableOctaves;
    logic incr, clk, rst;

    OctaveSelector #(.OCT(OCT)) DUT(.enableOctaves, .incr, .clk, .rst);

    initial
    begin
        clk <= '0;
        forever #100 clk <= ~clk;
    end

    task Reset;
        incr = '0;
        rst = '1; @(posedge clk);
        rst = '0; @(posedge clk);
    endtask

    task Check(logic [OCT-1:0] expected);
        #5;
        $write("%4t Expected %b, got %b", $time, expected, enableOctaves);
        assert(enableOctaves == expected) else $display(" - WRONG");
        $display("");
        @(posedge clk);
    endtask

    initial
    begin
        Reset();
        Check(4'b1111);
        Check(4'b1111);
        #50; incr = '1;
        Check(4'b1111);
        Check(4'b0001);
        Check(4'b0011);
        Check(4'b0001);
        Check(4'b0111);
        Check(4'b0001);
        Check(4'b0011);
        Check(4'b0001);
        Check(4'b1111);
        Check(4'b0001);
        Check(4'b0011);
        Check(4'b0001);
        #50; incr = '0;
        Check(4'b0111);
        Check(4'b0111);
        Check(4'b0111);
        Check(4'b0111);
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