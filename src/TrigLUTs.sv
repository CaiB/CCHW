// TODO Investigate https://zipcpu.com/dsp/2017/07/11/simplest-sinewave-generator.html

module SinTables
// N is the bit count of each sample in the table
// BINS is the number of bins
// NS is the address width for each wave
#(parameter N = 16, parameter BINS = 24, parameter NS = 6)
(
    output logic signed [N-1:0] value,
    input logic unsigned [$clog2(BINS)-1:0] bin,
    input logic unsigned [NS-1:0] position
);
    logic signed [N-1:0] SinValues [0:((2**NS)*BINS)];
    initial $readmemh("../other/sintable.txt", SinValues);
    assign value = SinValues[{bin, position}];
endmodule

module CosTables
#(parameter N = 16, parameter BINS = 24, parameter NS = 6)
(
    output logic signed [N-1:0] value,
    input logic unsigned [$clog2(BINS)-1:0] bin,
    input logic unsigned [NS-1:0] position
);
    logic signed [N-1:0] CosValues [0:((2**NS)*BINS)];
    initial $readmemh("../other/costable.txt", CosValues);
    assign value = CosValues[{bin, position}];
endmodule


// NOTE: Changing either parameter requires regenerating the tables, and editing the code below!
// N is $BinBitCount, the number of bits required to address all samples in the longest wave.
// BINS is $BinCount, the number of bins in an octave, and the number of trig waves stored.
module TableCounters
#(parameter N = 6, parameter BINS = 24)
(
    output logic unsigned [N-1:0] counterOut,
    input logic unsigned [$clog2(BINS)-1:0] bin,
    input logic increment,
    input logic clk, rst
);
    logic unsigned [N-1:0] Counters [0:BINS-1];
    assign counterOut = Counters[bin];

    logic unsigned [$clog2(BINS)-1:0] BinMax [0:BINS-1];
    // This line is taken directly from the last terminal output from the GenerateTables.ps1 script.
    assign BinMax = { 6'd55, 6'd53, 6'd52, 6'd51, 6'd49, 6'd48, 6'd46, 6'd45, 6'd44, 6'd43, 6'd41, 6'd40, 6'd39, 6'd38, 6'd37, 6'd36, 6'd35, 6'd34, 6'd33, 6'd32, 6'd31, 6'd30, 6'd29, 6'd29 };

    always_ff @(posedge clk)
    begin
        if(rst) Counters <= '{default:0}; // TODO: Figure out how to zero whole array.
        else if(increment) Counters[bin] <= (Counters[bin] + 1'd1) % BinMax[bin];
    end
endmodule


// TODO: Investigate structure that increments all counters in an octave at once, perhaps that might be simpler than incrementing each bin.
module TrigManager
(
 // output sin and cos values for each octave
 // input next sample pulse, 1 for each octave (goes to all bins)
 // input next bin pulse, 1 for each octave
);

endmodule