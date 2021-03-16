module Test_FindMax120;
    localparam N = 16;
    localparam BINS = 120;
    logic unsigned [N-1:0] maxValue;
    logic unsigned [N-1:0] values [0:BINS-1];
    FindMax120 #(.N(N)) DUT(.maxValue, .values);

    localparam logic [N-1:0] DefaultValue = 16'd12345;
    localparam logic [N-1:0] PeakValue = 16'd50000;

    initial values = '{default:0};

    int it, il;

    task TestAndCompare(int bin);
        for(it = 0; it < BINS; it++)
        begin
            if(it == bin) values[it] = PeakValue + it;
            else values[it] = DefaultValue;
        end
        #50;
        assert(maxValue == PeakValue + bin) else $display("ERROR: At bin %3d, expected %6d but got %6d", bin, PeakValue + bin, maxValue);
    endtask

    initial
    begin
        #100;
        for(il = 0; il < BINS; il++)
        begin
            TestAndCompare(il);
            #50;
        end
        $stop; 
    end
endmodule

module Test_PeakDetector;
    localparam N = 16;
    logic isPeak;
    logic [N-1:0] left, right, here; // the bins to the left and right, as well as this bin here
    logic [N-1:0] threshold; // how large the peak needs to be to be considered a peak, and not just noise

    PeakDetector #(.N(N)) DUT(.isPeak, .left, .right, .here, .threshold);

    task TestVal(logic [N-1:0] l, logic [N-1:0] c, logic [N-1:0] r, logic expected);
        left = l;
        right = r;
        here = c;
        #50;
        assert(isPeak == expected);
        #50;
    endtask

    task TestFalse;
        TestVal(50, 100, 200, 0);
        TestVal(100, 50, 200, 0);
        TestVal(200, 100, 50, 0);
        TestVal(500, 1000, 2000, 0);
        TestVal(50, 50, 50, 0);
        TestVal(10, 200, 200, 0);
        TestVal(200, 200, 10, 0);
        TestVal(0, 0, 0, 0);
    endtask

    initial
    begin
        threshold = '0;
        TestFalse();
        TestVal(50, 200, 100, 1);
        TestVal(1999, 2000, 1999, 1);
        TestVal(0, 5555, 2, 1);

        threshold = 201;
        TestFalse();
        TestVal(50, 200, 100, 0);
        TestVal(1999, 2000, 1999, 1);
        TestVal(0, 5555, 2, 1);

        threshold = 2500;
        TestFalse();
        TestVal(50, 200, 100, 0);
        TestVal(1999, 2000, 1999, 0);
        TestVal(0, 5555, 2, 1);

        threshold = 9999;
        TestFalse();
        TestVal(50, 200, 100, 0);
        TestVal(1999, 2000, 1999, 0);
        TestVal(0, 5555, 2, 0);
        TestVal(20000, 15000, 20000, 0);
        TestVal(0, 40000, 0, 1);
    end
endmodule

module Test_PeakPlacer;
    localparam N = 16;
    localparam BPO = 24;
    localparam FPW = 5;
    localparam FPF = 10;
    logic [(FPW+FPF)-1:0] peakPosition; // between 0 (inc) and BPO (exc)
    logic [4:0] binIndex;// between 0 and BPO-1
    logic [N-1:0] left, right, here;

    PeakPlacer #(.N(N), .BPO(BPO), .FPW(FPW), .FPF(FPF)) DUT(.peakPosition, .binIndex, .left, .right, .here);

    real peakPositionR;
    always_comb peakPositionR = (peakPosition * (2.0 ** -FPF));

    int TotalAdjacentDifference;
    real ProportionalDifferenceLeft, ProportionalDifferenceRight, InternalOffset, ExpectedOutput;
    real AcceptableRange = 0.01;
    task TestPeak(logic [N-1:0] l, logic [N-1:0] c, logic [N-1:0] r, logic [4:0] bin);
        left = l;
        right = r;
        here = c;
        binIndex = bin;

        // Calculate the expected value using the CC.NET code
        TotalAdjacentDifference = ((c - l) + (c - r));
        ProportionalDifferenceLeft = (c - l) * 1.0 / TotalAdjacentDifference;
        ProportionalDifferenceRight = (c - r) * 1.0 / TotalAdjacentDifference;
        if (ProportionalDifferenceLeft < ProportionalDifferenceRight) InternalOffset = -(0.5 - ProportionalDifferenceLeft);
        else InternalOffset = (0.5 - ProportionalDifferenceRight);
        ExpectedOutput = (bin + InternalOffset);
        if(ExpectedOutput < 0.0) ExpectedOutput += BPO;
        if(ExpectedOutput >= BPO) ExpectedOutput -= BPO;

        #50;
        assert(peakPositionR < ExpectedOutput + AcceptableRange);
        assert(peakPositionR > ExpectedOutput - AcceptableRange);
        #50;
    endtask

    task TestSeries(logic [4:0] bin);
        TestPeak(300, 500, 300, bin);
        TestPeak(100, 500, 300, bin);
        TestPeak(10, 50, 30, bin);
        TestPeak(300, 500, 100, bin);
        TestPeak(0, 500, 499, bin);
        TestPeak(499, 500, 0, bin);
        TestPeak(0, 500, 0, bin);
        TestPeak(1, 2, 1, bin);
    endtask

    initial
    begin
        TestSeries(10); // Test bin near middle
        TestSeries(0); // Test bottom bin
        TestSeries(23); // Test top bin
    end
endmodule

module Test_PeakWAvg;
    localparam FPW = 5;
    localparam FPF = 10;
    localparam N = 16;
    logic [N-1:0] peakAmp, peakPos;
    logic [N-1:0] in0Amp, in0Pos;
    logic [N-1:0] in1Amp, in1Pos;

    PeakWAvg #(.N(N)) DUT(.peakAmp, .peakPos, .in0Amp, .in0Pos, .in1Amp, .in1Pos);

    int Whole;
    real Fractional;
    function logic [N-1:0] RealToFixed(input real in, input int fpf);
        Whole = (in >= 0 ? int'($floor(in)) : int'($ceil(in)));
        Fractional = in - real'(Whole);
        RealToFixed = (Whole << fpf) | (int'(Fractional * (1 << fpf)));
    endfunction

    function real FixedToReal(input logic [N-1:0] in, input int fpf);
        FixedToReal = (in * (2.0 ** -fpf));
    endfunction

    real AcceptableRange = 0.01;
    real RangeMin, RangeMax, Result;
    task TestValue(logic [N-1:0] leftAmp, real leftPos, logic [N-1:0] rightAmp, real rightPos, logic [N-1:0] expectedAmp, real expectedPos);
        in0Amp = leftAmp;
        in0Pos = RealToFixed(leftPos, FPF);
        in1Amp = rightAmp;
        in1Pos = RealToFixed(rightPos, FPF);

        RangeMin = expectedPos - AcceptableRange;
        RangeMax = expectedPos + AcceptableRange;
        #50;

        Result = FixedToReal(peakPos, FPF);
        assert(peakAmp == expectedAmp) else $display("%4t FAIL: Expected amplitude %0d, got %0d.", $time, expectedAmp, peakAmp);
        assert(Result < RangeMax) else $display("%4t FAIL: Expected position %f (range between %f and %f). Got %f, which was too high.", $time, expectedPos, RangeMin, RangeMax, Result);
        assert(Result > RangeMin) else $display("%4t FAIL: Expected position %f (range between %f and %f). Got %f, which was too low.", $time, expectedPos, RangeMin, RangeMax, Result);
        #50;
    endtask

    real peakPosR, in0PosR, in1PosR;
    always_comb
    begin
        peakPosR = FixedToReal(peakPos, FPF);
        in0PosR = FixedToReal(in0Pos, FPF);
        in1PosR = FixedToReal(in1Pos, FPF);
    end

    initial
    begin
        TestValue(100, 10.0, 100, 11.0, 200, 10.5);
        TestValue(300, 10.0, 100, 11.0, 400, 10.25);
        TestValue(100, 0.0, 100, 2.0, 200, 1.0);
        TestValue(1, 10.0, 99, 11.0, 100, 10.99);
        TestValue(100, 10.0, 0, 12.0, 100, 10.0);
        TestValue(10000, 2.0, 1, 4.0, 10001, 2.0);
        TestValue(100, 6.384, 100, 15.762, 200, 11.073);
        TestValue(100, 6.384, 250, 15.762, 350, 13.083);
        TestValue(100, 6.384, 100, 15.762, 200, 11.073);
        $stop;
    end
endmodule

module Test_NoteOperationManager;
    localparam OCT = 5;
    logic [3:0] activeNoteSlot;
    logic [$clog2(OCT)-1:0] activeOctave;
    logic finished, doOperation;
    logic start;
    logic clk, rst;

    NoteOperationManager #(.OCT(OCT)) DUT(.activeNoteSlot, .activeOctave, .finished, .doOperation, .start, .clk, .rst);

    initial
    begin
        clk <= '0;
        forever #50 clk <= ~clk;
    end

    task Reset;
        rst = '1;
        start = '0;
        repeat(3) @(posedge clk);
        rst = '0;
        @(posedge clk);
        #5;
        assert(~doOperation);
        assert(~finished);
    endtask

    initial
    begin
        Reset();
        start = '1; @(posedge clk);
        start = '0;
        repeat(260) @(posedge clk);
        start = '1;
        repeat(260) @(posedge clk);
        start = '0;
        repeat(260) @(posedge clk);
        $stop;
    end
endmodule

module Test_NoteFinder;
    localparam N = 16;
    localparam BPO = 24;
    localparam OCT = 5;
    localparam BINS = BPO * OCT;
    localparam FPF = 11;
    logic unsigned [N-1:0] dftBins [0:BINS-1];
    logic startCycle;
    logic clk, rst;
    NoteFinder #(.N(N), .BPO(BPO), .OCT(OCT)) DUT(.dftBins, .startCycle, .clk, .rst);

    real SavedPeakPositionsR [0:11];

    genvar i;
    generate
        for(i = 0; i < 12; i++)
        begin
            assign SavedPeakPositionsR[i] = (DUT.SavedPeakPositions[i] * (2.0 ** -FPF));
        end
    endgenerate

    initial
    begin
        clk <= '0;
        forever #50 clk <= ~clk;
    end

    task Reset;
        dftBins = '{default:0};
        startCycle = '0;
        rst = '1;
        repeat(5) @(posedge clk);
        rst = '0; @(posedge clk);
    endtask

    initial
    begin
        Reset();
        //             0     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19    20    21    22    23   <- bins
        dftBins = '{   0,    0,   20,   80,  300,  500,  900, 2000, 1800,  700,  500,  200,  300,  200,  200,  200,  200,  200,  200,  220,  300,  500,  700,  900, // 0  octaves
                     700,  500,  500,  500,  900, 1500, 2500, 3500, 4000, 3100, 1500,  600,  100,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, // 1  |
                     100,  500,  300,  100,    0,    0,    0,    0,    0,    0,    0,    0,    0,   10,  100,  500,  900, 1500, 2500, 3500, 2700, 1800,  700,  500, // 2  v
                     300,  100,   80,   20,  100,  600, 1000,  600,  200,   50,    2,    1,    2,    1,    2,    1,    2,    1,    2,    1,    3,    7,    5,    0, // 3
                       0,   50,   10,   80,  150,  300,  500,  800,  900,  950, 1200, 1500, 1500, 1500, 1900, 1600, 1100,  600,  400,  200,   80,   10,    0,    1};// 4
        startCycle = '1; @(posedge clk);
        startCycle = '0;
        repeat(250) @(posedge clk);
        $stop;
    end
endmodule

typedef struct packed
{
    logic [15:0] position;
    logic [15:0] amplitude;
    logic valid;
} Note;

module Test_NoteAssociator;
    localparam FPF = 10;
    localparam N = 16;

    Note outNotes [0:11];
    logic finished;
    Note newPeaks [0:11];
    logic start;
    logic clk, rst;
    
    NoteAssociator #(.N(N), .FPF(FPF)) DUT(.outNotes, .finished, .newPeaks, .start, .clk, .rst);

    int Whole;
    real Fractional;
    function logic [N-1:0] RealToFixed(input real in, input int fpf);
        Whole = (in >= 0 ? int'($floor(in)) : int'($ceil(in)));
        Fractional = in - real'(Whole);
        RealToFixed = (Whole << fpf) | (int'(Fractional * (1 << fpf)));
    endfunction

    function real FixedToReal(input logic [N-1:0] in, input int fpf);
        FixedToReal = (in * (2.0 ** -fpf));
    endfunction

    real outPositionsR [0:11], newPeakPosR [0:11];
    genvar i;
    generate
        for(i = 0; i < 12; i++)
        begin
            assign outPositionsR[i] = FixedToReal(outNotes[i].position, FPF);
            assign newPeakPosR[i] = FixedToReal(newPeaks[i].position, FPF);
        end
    endgenerate

    real ASSDISTR = FixedToReal(DUT.ASSDIST, FPF);

    initial
    begin
        clk <= '1;
        forever #50 clk <= ~clk;
    end

    task Reset;
        newPeaks = '{default:0};
        start = '0;
        rst = '1;
        repeat(5) @(posedge clk);
        @(negedge clk);
        rst = '0; @(posedge clk);
    endtask

    initial
    begin
        Reset();
        newPeaks[0] = { RealToFixed(0.542, FPF), 16'd10000, 1'b1 };
        newPeaks[1] = { 'x, 1'b0 };
        newPeaks[2] = { 'x, 1'b0 };
        newPeaks[3] = { RealToFixed(7.111, FPF), 16'd10000, 1'b1 };
        newPeaks[4] = { RealToFixed(8.020, FPF), 16'd20000, 1'b1 };
        newPeaks[5] = { RealToFixed(11.50, FPF), 16'd30000, 1'b1 };
        newPeaks[6] = { 'x, 1'b0 };
        newPeaks[7] = { 'x, 1'b0 };
        newPeaks[8] = { 'x, 1'b0 };
        newPeaks[9] = { 'x, 1'b0 };
        newPeaks[10] = { 'x, 1'b0 };
        newPeaks[11] = { RealToFixed(23.97, FPF), 16'd15775, 1'b1 };
        start = '1; @(posedge clk);
        start = '0; @(posedge clk);
        while(~finished) @(posedge clk);

        newPeaks[0] = { RealToFixed(0.542, FPF), 16'd10000, 1'b1 }; // Exact same
        newPeaks[1] = { 'x, 1'b0 };
        newPeaks[2] = { 'x, 1'b0 };
        newPeaks[3] = { RealToFixed(6.980, FPF), 16'd15000, 1'b1 }; // Shift pos left, increase amplitude
        newPeaks[4] = { RealToFixed(9.207, FPF), 16'd20000, 1'b1 }; // Shift pos right too far
        newPeaks[5] = { 'x, 1'b0 }; // No longer a peak
        newPeaks[6] = { 'x, 1'b0 };
        newPeaks[7] = { 'x, 1'b0 };
        newPeaks[8] = { RealToFixed(16.987, FPF), 16'd18888, 1'b1 }; // New peak
        newPeaks[9] = { 'x, 1'b0 };
        newPeaks[10] = { 'x, 1'b0 };
        newPeaks[11] = { RealToFixed(23.97, FPF), 16'd7777, 1'b1 }; // Decrease amplitude
        start = '1; @(posedge clk);
        start = '0; @(posedge clk);
        while(~finished) @(posedge clk);

        repeat(5) @(posedge clk); // see if correct data gets latched out
        $stop;
    end
endmodule