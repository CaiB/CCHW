// BPO = Bins Per Octave
// OC = Octave Count
// N = Number of bits (precision for entire system)
module DFT
#(parameter BPO = 24, parameter OC = 5, parameter N = 16, parameter TOPSIZE = 8192, parameter ND = (N*2)+(OC-1))
(
    output logic unsigned [ND-1:0] outBins [0:(BPO*OC)-1], // the magnitudes in each frequency bin
    output logic doingRead, // on while we are doing a read on the input, useful for FPGA
    input logic signed [N-1:0] inputSample, // New audio data to add
    input logic sampleReady, // Whether to new audio data is ready
    input logic clk, rst
);
    // Active octave and operation selection
    logic [$clog2(OC)-1:0] ActiveOctave;
    logic CurrentOctaveOp;
    logic [$clog2(BPO)-1:0] CurrentOctaveBinIndex;
    logic DoWrites, AdvanceOctave, ReadyToRead, DoCalcs;
    OperationManager #(.OCT(OC), .BINS(BPO)) OpMgr(.octave(ActiveOctave), .operation(CurrentOctaveOp), .bin(CurrentOctaveBinIndex), .ready(ReadyToRead), .doCalculations(DoCalcs), .writeSample(DoWrites), .finishedProcessing(AdvanceOctave), .sampleReady, .clk, .rst);
    assign doingRead = DoWrites;

    logic [OC-1:0] EnableOctaves;
    OctaveSelector #(.OCT(OC)) OctSel(.enableOctaves(EnableOctaves), .incr(AdvanceOctave), .clk, .rst);

    // Sin and cos tables
    localparam NS = 6; // trig table adddress width, specified by GenerateTables.ps1
    logic signed [N-1:0] SinOutput, CosOutput;
    logic [NS-1:0] TrigTablePositions [0:OC-1];
    SinTables #(.N(N), .BINS(BPO), .NS(NS)) SinTab(.value(SinOutput), .bin(CurrentOctaveBinIndex), .position(TrigTablePositions[ActiveOctave]));
    CosTables #(.N(N), .BINS(BPO), .NS(NS)) CosTab(.value(CosOutput), .bin(CurrentOctaveBinIndex), .position(TrigTablePositions[ActiveOctave]));

    // Octaves
    // Each octave gets 1 bit wider to accomodate addition of previous octave's samples
    logic signed [N:0] Octave1to2;
    logic signed [N+1:0] Octave2to3;
    logic signed [N+2:0] Octave3to4;
    logic signed [N+3:0] Octave4to5;
    logic signed [N+4:0] Octave5to6;
    OctaveManager #(.OID(0), .BINS(BPO), .SIZE(TOPSIZE), .N(N), .NO(ND)) Octave1(.nextOctave(Octave1to2), .magnitude(outBins[96:119]), .trigPosReq(TrigTablePositions[0]),
                  .newSample(inputSample), .readSample(EnableOctaves[0] & DoWrites), .enable(EnableOctaves[0] & ActiveOctave == 0 & DoCalcs), .sinData(SinOutput), .cosData(CosOutput), .mathOp(CurrentOctaveOp), .bin(CurrentOctaveBinIndex), .clk, .rst);
    OctaveManager #(.OID(1), .BINS(BPO), .SIZE(TOPSIZE/2), .N(N+1), .NO(ND)) Octave2(.nextOctave(Octave2to3), .magnitude(outBins[72:95]), .trigPosReq(TrigTablePositions[1]),
                  .newSample(Octave1to2), .readSample(EnableOctaves[1] & DoWrites), .enable(EnableOctaves[1] & ActiveOctave == 1 & DoCalcs), .sinData(SinOutput), .cosData(CosOutput), .mathOp(CurrentOctaveOp), .bin(CurrentOctaveBinIndex), .clk, .rst);
    OctaveManager #(.OID(2), .BINS(BPO), .SIZE(TOPSIZE/4), .N(N+2), .NO(ND)) Octave3(.nextOctave(Octave3to4), .magnitude(outBins[48:71]), .trigPosReq(TrigTablePositions[2]),
                  .newSample(Octave2to3), .readSample(EnableOctaves[2] & DoWrites), .enable(EnableOctaves[2] & ActiveOctave == 2 & DoCalcs), .sinData(SinOutput), .cosData(CosOutput), .mathOp(CurrentOctaveOp), .bin(CurrentOctaveBinIndex), .clk, .rst);
    OctaveManager #(.OID(3), .BINS(BPO), .SIZE(TOPSIZE/8), .N(N+3), .NO(ND)) Octave4(.nextOctave(Octave4to5), .magnitude(outBins[24:47]), .trigPosReq(TrigTablePositions[3]),
                  .newSample(Octave3to4), .readSample(EnableOctaves[3] & DoWrites), .enable(EnableOctaves[3] & ActiveOctave == 3 & DoCalcs), .sinData(SinOutput), .cosData(CosOutput), .mathOp(CurrentOctaveOp), .bin(CurrentOctaveBinIndex), .clk, .rst);
    OctaveManager #(.OID(4), .BINS(BPO), .SIZE(TOPSIZE/16), .N(N+4), .NO(ND)) Octave5(.nextOctave(Octave5to6), .magnitude(outBins[0:23]), .trigPosReq(TrigTablePositions[4]),
                  .newSample(Octave4to5), .readSample(EnableOctaves[4] & DoWrites), .enable(EnableOctaves[4] & ActiveOctave == 4 & DoCalcs), .sinData(SinOutput), .cosData(CosOutput), .mathOp(CurrentOctaveOp), .bin(CurrentOctaveBinIndex), .clk, .rst);


    // TODO: IIR?
endmodule

// N is for input sample
// NO is for output magnitude
// NS is trig table address width
// NT is for trig value width
// OID is octave index
// Houses storage, math processing, and control of 1 octave
module OctaveManager
#(parameter BINS = 24, parameter SIZE = 8192, parameter N = 16, parameter NT = 16, parameter NO = 32, parameter NS = 6, parameter OID = 0)
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
    TableCountersEnd #(.BINS(BINS), .OCT(OID)) TrigTableCountersEnd(.counterOut(EndTrigTablePos), .bin, .increment(~mathOp && enable), .clk, .rst);
    assign trigPosReq = mathOp ? CurrentTrigTablePos : EndTrigTablePos;

    logic signed [N-1:0] sample0, sample1, oldestSample;
    OctaveStorageRAM #(.SIZE(SIZE), .N(N)) OctaveData(.sample0, .sample1, .oldestSample, .newSample, .writeSample(readSample), .clk, .rst);
    assign nextOctave = sample0 + sample1;

    logic signed [N-1:0] SampleOperand; // Whatever sample we are currently operating on
    logic signed [NO-1:0] SinProd, CosProd; // The sin and cos products for the current sample

    localparam SUMSIZE = $clog2(SIZE) + NO;
    logic signed [SUMSIZE-1:0] SinSum [0:BINS-1], CosSum [0:BINS-1]; // The current cumulative sum of all samples' sin/cos products
    logic signed [SUMSIZE-1:0] AbsSinSum, AbsCosSum;

    always_comb // Combinational outputs
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

// Generates control signals for other modules to synchronize behaviour of all octaves
module OperationManager
#(parameter OCT = 5, BINS = 24)
(
    output logic [$clog2(OCT)-1:0] octave, // which octave should be worked on now
    output logic operation, // whether to currently add new data / subtract old data from the running sum
    output logic [$clog2(BINS)-1:0] bin, // which bin should be worked on now
    output logic ready, // asserted while we are ready and waiting for an audio sample
    output logic writeSample, // asserted for 1 cycle before processing to write the sample into each octave
    output logic doCalculations, // asserted during the loops
    output logic finishedProcessing, // asserted for 1 clock cycle after the current sample is done being processed
    input logic sampleReady, // assert this when there is audio data ready for analysis (starting the operation)
    input logic clk, rst
);
    typedef enum { WAIT, WRITE, LOOPSUB, LOOPADD, DONE, XXX } OpManState;
    OpManState Present, Next;

    always_ff @(posedge clk, posedge rst) // State register
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
        doCalculations = (Present == LOOPSUB) || (Present == LOOPADD);
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

// Determines which octaves are active for this input sample
// Not all octaves are processing every sample
module OctaveSelector
#(parameter OCT = 5)
(
    output logic [OCT-1:0] enableOctaves, // one line for each octave, specifying which ones sohuld be active this sample cycle, up to all can be true at once
    input logic incr, // processingFinished from OperationManager
    input logic clk, rst
);
    logic [OCT-2:0] Previous, Present;

    always_ff @(posedge clk, posedge rst) // Async because otherwise SAPR throws a fit???
    begin
        if(rst)
        begin
            Previous <= '1;
            Present <= '0;
        end
        else
        begin
            if(incr)
            begin
                Previous <= Present;
                Present <= Present + 1'd1;
            end
        end
    end

    assign enableOctaves[0] = '1; // Bottom octave is always processing.
    assign enableOctaves[OCT-1:1] = Previous & ~Present;
endmodule

// A chain of SIZE, N-bit registers, with the outputs of the first, second, and last registers exposed
// `writeSample` must be true to enable writing
// NOTE: This uses a ton of individual registers as storage, and while simple, is neither space nor power-efficient. Good only for testing.
module OctaveStorage
#(parameter SIZE = 8192, parameter N = 16)
(
    output logic signed [N-1:0] sample0, sample1, oldestSample, // the first, second, and last sample in storage
    input logic signed [N-1:0] newSample, // the new sample to add to storage
    input logic writeSample, // whether to write the new sample into storage. Only keep true for 1 clock cycle for a single write
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

// This is preferred over OctaveStorage when actually used in the FPGA or ASIC. Uses RAM modules designed for the respective device types.
// However, this is limited to only using the TOPSIZE = 8192 option and TOPN = 16, unless other RAM modules are created.
module OctaveStorageRAM
#(parameter SIZE = 8192, parameter N = 16) // N must match size of RAM, which is determined by SIZE.
(
    output logic signed [N-1:0] sample0, sample1, oldestSample, // the first, second, and last sample in storage
    input logic signed [N-1:0] newSample, // the new sample to add to storage
    input logic writeSample, // whether to write the new sample into storage. Only keep true for 1 clock cycle for a single write
    input logic clk, rst
);
    SampleRegister #(.N(N)) Reg0(.out(sample0), .in(newSample), .en(writeSample), .clk, .rst);
    SampleRegister #(.N(N)) Reg1(.out(sample1), .in(sample0), .en(writeSample), .clk, .rst);

    typedef enum { WAIT, OUTPUT, WRITE, INCR, XXX } OctStorageState;
    OctStorageState Present, Next;

    logic [$clog2(SIZE)-1:0] Address;
    logic DataValid, Filled; // Filled indicates we're about to complete the first write pass. DataValid becomes true once we are ready to read back at address 0.
    logic [N-1:0] RAMOut, RAMIn, OldRegOut;
    logic RAMWrite;
    assign RAMIn = sample0; //newSample;

    SampleRegister #(.N(N)) RegEnd(.out(OldRegOut), .in(RAMOut), .en(writeSample), .clk, .rst);

    always_ff @(posedge clk, posedge rst) // State register
        if(rst) Present <= WAIT;
        else Present <= Next;
    
    always_comb // Next state
    begin
        Next = XXX;
        case(Present)
            WAIT: if(writeSample) Next = OUTPUT;
                  else Next = WAIT; // @LB
            OUTPUT: Next = WRITE;
            WRITE: Next = INCR;
            INCR: Next = WAIT;
            default: Next = XXX;
        endcase
    end

    always_ff @(posedge clk) // Registered outputs
    begin
        if(rst)
        begin
            Address <= '0;
            Filled <= '0;
            DataValid <= '0;
        end
        else
        begin
            if(Present == INCR) Address <= Address + 1'b1;
            if(Address == (SIZE-1)) Filled <= '1;
            if(Filled && (Address == 0) && writeSample) DataValid <= '1;
        end
    end

    always_comb // Combinational outputs
    begin
        RAMWrite = (Present == WRITE);
        oldestSample = DataValid ? OldRegOut : '0;
    end

    generate // RAM module
`ifdef RAM_ASIC
        if(SIZE == 8192) RAM_16B_8192_AR4_LP RAM(.Q(RAMOut), .CLK(clk), .CEN('0), .WEN(~RAMWrite), .A(Address), .D(RAMIn), .EMA('0), .EMAW('0), .EMAS('0), .RET1N('1));
        else if(SIZE == 4096) RAM_17B_4096_AR4_LP RAM(.Q(RAMOut), .CLK(clk), .CEN('0), .WEN(~RAMWrite), .A(Address), .D(RAMIn), .EMA('0), .EMAW('0), .EMAS('0), .RET1N('1));
        else if(SIZE == 2048) RAM_18B_2048_AR3_LP RAM(.Q(RAMOut), .CLK(clk), .CEN('0), .WEN(~RAMWrite), .A(Address), .D(RAMIn), .EMA('0), .EMAW('0), .EMAS('0), .RET1N('1));
        else if(SIZE == 1024) RAM_19B_1024_AR3_LP RAM(.Q(RAMOut), .CLK(clk), .CEN('0), .WEN(~RAMWrite), .A(Address), .D(RAMIn), .EMA('0), .EMAW('0), .EMAS('0), .RET1N('1));
        else if(SIZE == 512) RAM_20B_512_AR2_LP RAM(.Q(RAMOut), .CLK(clk), .CEN('0), .WEN(~RAMWrite), .A(Address), .D(RAMIn), .EMA('0), .EMAW('0), .EMAS('0), .RET1N('1));
        //else $display("MEMORY SIZE %4d INVALID", SIZE);
`elsif RAM_FPGA
        `timescale 1 ps / 1 ps
        if(SIZE == 8192) RAM_8192 DUT(.address(Address), .clock(clk), .data(RAMIn), .wren(RAMWrite), .q(RAMOut));
        else if(SIZE == 4096) RAM_4096 DUT(.address(Address), .clock(clk), .data(RAMIn), .wren(RAMWrite), .q(RAMOut));
        else if(SIZE == 2048) RAM_2048 DUT(.address(Address), .clock(clk), .data(RAMIn), .wren(RAMWrite), .q(RAMOut));
        else if(SIZE == 1024) RAM_1024 DUT(.address(Address), .clock(clk), .data(RAMIn), .wren(RAMWrite), .q(RAMOut));
        else if(SIZE == 512) RAM_512 DUT(.address(Address), .clock(clk), .data(RAMIn), .wren(RAMWrite), .q(RAMOut));
        //else $display("MEMORY SIZE %4d INVALID", SIZE);
`else
        $error("ERROR: MEMORY TYPE NOT SELECTED VIA DEFINE!");
`endif
    endgenerate
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