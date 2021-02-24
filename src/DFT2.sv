// BPO = Bins Per Octave
// OC = Octave Count
// N = Number of bits (precision for entire system)
module DFT
#(parameter BPO = 24, parameter OC = 5, parameter N = 16, parameter TOPSIZE = 8192, parameter ND = (N*2)+(OC-1))
(
    output logic unsigned [ND-1:0] outBins [0:(BPO*OC)-1],
    input logic signed [N-1:0] inputSample, // New audio data to add
    input logic readSample, // Whether to read new audio data this cycle
    input logic clk, rst
);
    logic OctaveProcessingFinished;

    // Extremely simple state machine
    logic Processing, ProcessingNext;
    always_ff @(posedge clk)
        if(rst) Processing <= '0;
        else Processing <= ProcessingNext;
    always_comb
        if(Processing) ProcessingNext = ~OctaveProcessingFinished;
        else ProcessingNext = readSample;

    // Active octave selection
    // Generates the write pulses for each of the octaves at the correct intervals
    logic [OC-1:0] OctaveCounter;
    assign OctaveCounter[0] = Processing;
    WritePulseGen #(.N(OC-1)) PulseGen(.writeLines(OctaveCounter[OC-1:1]), .incr(Processing), .clk, .rst);

    // Octave operation counter
    logic [$clog2(OC)-1:0] ActiveOctave;
    logic CurrentOctaveOp;
    logic [$clog2(BPO)-1:0] CurrentOctaveBinIndex;
    OperationCounter #(.OCT(OC), .BINS(BPO)) OpCounter(.octave(ActiveOctave), .operation(CurrentOctaveOp), .bin(CurrentOctaveBinIndex), .finished(OctaveProcessingFinished), .enable(Processing), .clk, .rst);

    // Sin and cos tables
    localparam NS = 6; // trig table adddress width, set by script
    logic signed [N-1:0] SinOutput, CosOutput;
    logic [NS-1:0] TrigTablePositions [0:OC-1];
    SinTables #(.N(N), .BINS(BPO), .NS(NS)) SinTab(.value(SinOutput), .bin(CurrentOctaveBinIndex), .position(TrigTablePositions[ActiveOctave]));
    CosTables #(.N(N), .BINS(BPO), .NS(NS)) CosTab(.value(CosOutput), .bin(CurrentOctaveBinIndex), .position(TrigTablePositions[ActiveOctave]));

    // Octaves
    // Each octave gets 1 bit wider to accomodate addition of previous octave's samples
    logic signed [N:0] Octave1to2;
    OctaveManager #(.BINS(BPO), .SIZE(TOPSIZE), .N(N), .NO(ND)) Octave1(.nextOctave(Octave1to2), .magnitude(outBins[96:119]), .trigPosReq(TrigTablePositions[0]),
                  .newSample(inputSample), .readSample, .enable(OctaveCounter[0]), .sinData(SinOutput), .cosData(CosOutput), .mathOp(CurrentOctaveOp), .bin(CurrentOctaveBinIndex), .clk, .rst);
    //OctaveManager #(.BINS(BPO), .SIZE(TOPSIZE/2), .N(N+1), .NO((N*2)+1)) Octave2();
    //OctaveManager #(.BINS(BPO), .SIZE(TOPSIZE/4), .N(N+2), .NO((N*2)+2)) Octave3();
    //OctaveManager #(.BINS(BPO), .SIZE(TOPSIZE/8), .N(N+3), .NO((N*2)+3)) Octave4();
    //OctaveManager #(.BINS(BPO), .SIZE(TOPSIZE/16), .N(N+4), .NO((N*2)+4)) Octave5();


    // TODO: IIR?
endmodule


// N is for input sample
// NO is for output magnitude
// NS is trig table address width
module OctaveManager
#(parameter BINS = 24, parameter SIZE = 8192, parameter N = 16, parameter NO = 32, parameter NS = 6)
(
    output logic signed [N:0] nextOctave,
    output logic [NO-1:0] magnitude [0:BINS-1],
    output logic [NS-1:0] trigPosReq,
    input logic signed [N-1:0] newSample,
    input logic signed [N-1:0] sinData, cosData,
    input logic readSample,
    input logic enable,
    input logic mathOp,
    input logic [$clog2(BINS)-1:0] bin,
    input logic clk, rst
);
    logic [NS-1:0] CurrentTrigTablePos, EndTrigTablePos;
    TableCounters #(.BINS(BINS)) TrigTableCountersCur(.counterOut(CurrentTrigTablePos), .bin, .increment(enable), .clk, .rst);
    TableCounters #(.BINS(BINS)) TrigTableCountersEnd(.counterOut(EndTrigTablePos), .bin, .increment(enable), .clk, .rst);
    assign trigPosReq = mathOp ? CurrentTrigTablePos : EndTrigTablePos;

    logic [N-1:0] sample0, sample1, oldestSample;
    OctaveStorage #(.SIZE(SIZE), .N(N)) OctaveData(.sample0, .sample1, .oldestSample, .newSample, .writeSample(enable), .clk, .rst);
    assign nextOctave = sample0 + sample1;

    logic [N-1:0] SampleOperand; // Whatever sample we are currently operating on
    logic signed [NO-1:0] SinProd, CosProd; // The sin and cos products for the current sample

    localparam SUMSIZE = $clog2(SIZE) + NO;
    logic signed [SUMSIZE-1:0] SinSum, CosSum; // The current cumulative sum of all samples' sin/cos products
    logic signed [SUMSIZE-1:0] AbsSinSum, AbsCosSum;

    always_comb
    begin
        SampleOperand = mathOp ? sample0 : oldestSample;
        SinProd = sinData * SampleOperand;
        CosProd = cosData * SampleOperand;
        AbsSinSum = (SinSum < 0) ? -SinSum : SinSum;
        AbsCosSum = (CosSum < 0) ? -CosSum : CosSum;
    end

    always_ff @(posedge clk)
    begin
        if(rst)
        begin
            SinSum <= '0;
            CosSum <= '0;
        end 
        else if(~mathOp) // subtracting
        begin
            SinSum <= SinSum - SinProd;
            CosSum <= CosSum - CosProd;
        end
        else if(mathOp) // add and calc mag (we only need to do this here as subtraction happens right before addition)
        begin
            SinSum <= SinSum + SinProd;
            CosSum <= CosSum + CosProd;
            if(AbsSinSum > AbsCosSum) magnitude[bin] <= (AbsSinSum + (AbsCosSum >>> 1)); // TODO This might be too slow, potentially requiring breaking into another cycle.
            else                      magnitude[bin] <= (AbsCosSum + (AbsSinSum >>> 1));
        end
    end
endmodule


// A multi-stage irregular counter for determining what to do in each clock cycle
// Enable counting with `enable`
// { op 0 { index 0 - 23 }, op 1 { index 0-23 } } x 5 octaves, then finished
module OperationCounter
#(parameter OCT = 5, BINS = 24)
(
    output logic [$clog2(OCT)-1:0] octave,
    output logic operation, // add / subtract
    output logic [$clog2(BINS)-1:0] bin,
    output logic finished,
    input logic enable,
    input logic clk, rst
);
    always_ff @(posedge clk)
    begin
        if(rst || finished)
        begin
            octave <= '0;
            operation <= '0;
            bin <= '0;
        end
        else if(enable)
        begin
            if(bin == (BINS - 1))
            begin
                if(operation) octave <= octave + 1'd1;
                operation <= ~operation;
                bin <= '0;
            end
            else bin <= bin + 1'd1;
        end
    end

    assign finished = (octave == (OCT - 1)) && operation && (bin == (BINS - 1));
endmodule


// A binary counter, but each bit only stays on for 1 clock cycle
// Enable counting with `incr`
module WritePulseGen
#(parameter N = 4)
(
    output logic [N-1:0] writeLines,
    input logic incr,
    input logic clk, rst
);
    logic [N-1:0] Counter, CounterPrev;

    always_ff @(posedge clk)
    begin
        if(rst)
        begin
            Counter <= '0;
            CounterPrev <= '0;
        end
        else if(incr)
        begin
            CounterPrev <= Counter;
            Counter <= Counter + 1'd1;
        end
    end

    assign writeLines = Counter & ~CounterPrev;
endmodule

// A chain of SIZE, N-bit registers, with the outputs of the first, second, and last registers exposed
// `writeSample` must be true to enable writing
// TODO: Convert to RAM/DFF hybrid to reduce resource usage
module OctaveStorage
#(parameter SIZE = 8192, parameter N = 16)
(
    output logic signed [N-1:0] sample0, sample1, oldestSample,
    input logic signed [N-1:0] newSample,
    input logic writeSample,
    input logic clk, rst
);
    logic signed [SIZE-1:0][N-1:0] Inter;

    SampleRegister Reg0(.out(Inter[0]), .in(newSample), .en(writeSample), .clk, .rst);

    genvar i;
    generate
        for(i = 1; i < SIZE; i++)
        begin : MakeTopOctStorage
            SampleRegister Reg(.out(Inter[i]), .in(Inter[i - 1]), .en(writeSample), .clk, .rst);
        end
    endgenerate

    always_comb
    begin
        oldestSample = Inter[SIZE-1];
        sample0 = Inter[0];
        sample1 = Inter[1];
    end
endmodule


// An N-bit enabled register
module SampleRegister
#(parameter N = 16)
(
    output logic signed [N-1:0] out,
    input logic signed [N-1:0] in,
    input logic en, clk, rst
);
    always_ff @(posedge clk)
        if(rst) out <= '0;
        else out <= en ? in : out;
endmodule



// Normal operation spacing
// 1111 1111 1111 1111
//  2 2  2 2  2 2  2 2
//    3    3    3    3
//         4         4
//                   5

// Condensed operation spacing
// 1111 1111 1111 1111
// 32 2 3242 3252 3242

// Great for CPUs where cycles are limited, but not so important here
// Except maybe in low-power system where we want to elimite peak loads when many operations happen at once?
// TODO: Consider operation spacing options