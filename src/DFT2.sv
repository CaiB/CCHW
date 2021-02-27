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

    // Generates the write pulses for each of the octaves at the correct intervals
    logic [OC-1:0] OctaveCounter;
    WritePulseGen #(.N(OC)) PulseGen(.writeLines(OctaveCounter), .sampleReady(readSample), .processing(Processing), .clk, .rst);

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
    logic signed [N+1:0] Octave2to3;
    OctaveManager #(.BINS(BPO), .SIZE(TOPSIZE), .N(N), .NO(ND)) Octave1(.nextOctave(Octave1to2), .magnitude(outBins[96:119]), .trigPosReq(TrigTablePositions[0]),
                  .newSample(inputSample), .readSample(OctaveCounter[0]), .enable(ActiveOctave == 0), .sinData(SinOutput), .cosData(CosOutput), .mathOp(CurrentOctaveOp), .bin(CurrentOctaveBinIndex), .clk, .rst);
    OctaveManager #(.BINS(BPO), .SIZE(TOPSIZE/2), .N(N+1), .NO(ND)) Octave2(.nextOctave(Octave2to3), .magnitude(outBins[72:95]), .trigPosReq(TrigTablePositions[1]),
                  .newSample(Octave1to2), .readSample(OctaveCounter[1]), .enable(ActiveOctave == 1), .sinData(SinOutput), .cosData(CosOutput), .mathOp(CurrentOctaveOp), .bin(CurrentOctaveBinIndex), .clk, .rst);
    //OctaveManager #(.BINS(BPO), .SIZE(TOPSIZE/4), .N(N+2), .NO((N*2)+2)) Octave3();
    //OctaveManager #(.BINS(BPO), .SIZE(TOPSIZE/8), .N(N+3), .NO((N*2)+3)) Octave4();
    //OctaveManager #(.BINS(BPO), .SIZE(TOPSIZE/16), .N(N+4), .NO((N*2)+4)) Octave5();


    // TODO: IIR?
endmodule


// N is for input sample
// NO is for output magnitude
// NS is trig table address width
// NT is for trig value width
module OctaveManager
#(parameter BINS = 24, parameter SIZE = 8192, parameter N = 16, parameter NT = 16, parameter NO = 32, parameter NS = 6)
(
    output logic signed [N:0] nextOctave, // the sum of 2 samples to write into the next octave down (resampling)
    output logic [NO-1:0] magnitude [0:BINS-1], // the output magnitudes for each bin in this octave
    output logic [NS-1:0] trigPosReq, // what location in the trig tables we want to read from
    input logic signed [N-1:0] newSample, // the new audio sample to process
    input logic signed [NT-1:0] sinData, cosData, // the sin and cos values at the location we requested using `trigPosReq`
    input logic enable, // whether this octave is currently active
    input logic readSample, // whether we should push the input sample data into storage this cycle
    input logic mathOp, // whether we are subtracting old data (false/first), or adding new data to our running sum (true/second)
    input logic [$clog2(BINS)-1:0] bin, // which bin to process now
    input logic clk, rst
);
    logic [NS-1:0] CurrentTrigTablePos, EndTrigTablePos;
    TableCounters #(.BINS(BINS)) TrigTableCountersCur(.counterOut(CurrentTrigTablePos), .bin, .increment(mathOp && enable), .clk, .rst);
    TableCounters #(.BINS(BINS)) TrigTableCountersEnd(.counterOut(EndTrigTablePos), .bin, .increment(~mathOp && enable), .clk, .rst);
    assign trigPosReq = mathOp ? CurrentTrigTablePos : EndTrigTablePos;

    logic signed [N-1:0] sample0, sample1, oldestSample;
    OctaveStorage #(.SIZE(SIZE), .N(N)) OctaveData(.sample0, .sample1, .oldestSample, .newSample, .writeSample(readSample), .clk, .rst);
    assign nextOctave = sample0 + sample1;

    logic signed [N-1:0] SampleOperand; // Whatever sample we are currently operating on
    logic signed [NO-1:0] SinProd, CosProd; // The sin and cos products for the current sample

    localparam SUMSIZE = $clog2(SIZE) + NO;
    logic signed [SUMSIZE-1:0] SinSum [0:BINS-1], CosSum [0:BINS-1]; // The current cumulative sum of all samples' sin/cos products
    logic signed [SUMSIZE-1:0] AbsSinSum, AbsCosSum;

    always_comb
    begin
        SampleOperand = mathOp ? sample0 : oldestSample;
        SinProd = sinData * SampleOperand;
        CosProd = cosData * SampleOperand;
        AbsSinSum = (SinSum[bin] < 0) ? -SinSum[bin] : SinSum[bin];
        AbsCosSum = (CosSum[bin] < 0) ? -CosSum[bin] : CosSum[bin];
    end

    always_ff @(posedge clk)
    begin
        if(rst)
        begin
            SinSum <= '{default:0};
            CosSum <= '{default:0};
        end 
        else if(~mathOp && enable) // subtracting
        begin
            SinSum[bin] <= SinSum[bin] - SinProd; // TODO: Consider squishing these back down to 16 bit, we probably don't need the precision
            CosSum[bin] <= CosSum[bin] - CosProd;
        end
        else if(mathOp && enable) // add and calc mag (we only need to do this here as subtraction happens right before addition)
        begin
            SinSum[bin] <= SinSum[bin] + SinProd;
            CosSum[bin] <= CosSum[bin] + CosProd;
            if(AbsSinSum > AbsCosSum) magnitude[bin] <= (AbsSinSum + (AbsCosSum >>> 1)); // TODO This might be too slow, potentially requiring breaking into another cycle.
            else                      magnitude[bin] <= (AbsCosSum + (AbsSinSum >>> 1));
        end
    end
endmodule


module OperationManager
#(parameter OCT = 5, BINS = 24)
(
    output logic [$clog2(OCT)-1:0] octave,
    output logic operation, // add / subtract
    output logic [$clog2(BINS)-1:0] bin,
    output logic ready, // asserted while we are ready and waiting for an audio sample
    output logic writeSample, // asserted for 1 cycle before processing to write the sample into each octave
    output logic finishedProcessing, // asserted for 1 clock cycle after the current sample is done being processed
    input logic sampleReady,
    input logic clk, rst
);
    typedef enum { WAIT, WRITE, LOOPSUB, LOOPADD, DONE, XXX } OpManState;
    OpManState Present, Next;

    always_ff @(posedge clk) // State register
        if(rst) Present <= WAIT;
        else Present <= Next;
    
    always_comb // Next state
    begin
        Next = XXX;
        case(Present)
            WAIT: if(sampleReady) Next = WRITE;
                  else Next = WAIT; // @LB
            WRITE: Next = LOOPSUB;
            LOOPSUB: if(bin == (BINS - 1)) Next = LOOPADD;
                     else Next = LOOPSUB; // @LB
            LOOPADD: if(bin == (BINS - 1)) Next = (octave == (OCT - 1) ? DONE : LOOPSUB);
                     else Next = LOOPADD; // @LB
            DONE: Next = WAIT;
            default: Next = XXX;
        endcase
    end

    always_comb // Combinational outputs
    begin
        operation = (Present == LOOPADD);
        ready = (Present == WAIT);
        writeSample = (Present == WRITE);
        finishedProcessing = (Present == DONE);
    end
    
    always_ff @(posedge clk) // Registered outputs
    begin
        if(rst || Present == WRITE)
        begin
            octave <= '0;
            bin <= '0;
        end
        else
        begin
            if(Present == LOOPSUB || Present == LOOPADD) bin <= (bin == (BINS - 1) ? '0 : bin + 1'd1);
            if(Present == LOOPADD && bin == (BINS - 1)) octave <= octave + 1'd1;
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
#(parameter N = 5)
(
    output logic [N-1:0] writeLines,
    input logic sampleReady, // whether a new sample is ready in the audio buffer
    input logic processing, // whether we are currently processing a sample
    input logic clk, rst
);
    logic [N-1:0] Counter;

    always_ff @(posedge clk)
    begin
        if(rst) Counter <= '0;
        else
        begin
            if(writeLines[0]) Counter <= Counter + 1'd1;
            writeLines[0] <= ~writeLines[0] & ~processing & sampleReady;
        end
    end

    genvar i;
    generate
        for(i = 1; i < N; i++)
        begin
            assign writeLines[i] = writeLines[0] & (Counter[i-1:0] == '0);
        end
    endgenerate
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

    SampleRegister #(.N(N)) Reg0(.out(Inter[0]), .in(newSample), .en(writeSample), .clk, .rst);

    genvar i;
    generate
        for(i = 1; i < SIZE; i++)
        begin : MakeTopOctStorage
            SampleRegister #(.N(N)) Reg(.out(Inter[i]), .in(Inter[i - 1]), .en(writeSample), .clk, .rst);
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