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
    logic signed [N-1:0] SinValues [0:((2**NS)*BINS)-1];
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
    logic signed [N-1:0] CosValues [0:((2**NS)*BINS)-1];
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

    logic unsigned [N-1:0] BinMax [0:BINS-1];
    logic unsigned [N-1:0] ThisBinMax;
    // This line is taken directly from the last terminal output from the GenerateTables.ps1 script.
    
    assign BinMax = '{ 6'd55, 6'd53, 6'd52, 6'd51, 6'd49, 6'd48, 6'd46, 6'd45, 6'd44, 6'd43, 6'd41, 6'd40, 6'd39, 6'd38, 6'd37, 6'd36, 6'd35, 6'd34, 6'd33, 6'd32, 6'd31, 6'd30, 6'd29, 6'd29 };
    assign ThisBinMax = BinMax[bin];

    logic ResetThisBin;
    assign ResetThisBin = (Counters[bin] + 1'd1) == ThisBinMax;

    always_ff @(posedge clk)
    begin
        if(rst) Counters <= '{default:0};
        else if(increment) Counters[bin] <= (ResetThisBin ? '0 : (Counters[bin] + 1'd1));
    end
endmodule



module TableCountersEnd
#(parameter N = 6, parameter BINS = 24, parameter OCT = 0)
(
    output logic unsigned [N-1:0] counterOut,
    input logic unsigned [$clog2(BINS)-1:0] bin,
    input logic increment,
    input logic clk, rst
);
    logic unsigned [N-1:0] Counters [0:BINS-1];
    assign counterOut = Counters[bin];

    logic unsigned [N-1:0] BinMax [0:BINS-1];
    logic unsigned [N-1:0] ThisBinMax;
    // This line is taken directly from the last terminal output from the GenerateTables.ps1 script.
    // These only change if the frequencies or sample rate are changed.
    assign BinMax = '{ 6'd55, 6'd53, 6'd52, 6'd51, 6'd49, 6'd48, 6'd46, 6'd45, 6'd44, 6'd43, 6'd41, 6'd40, 6'd39, 6'd38, 6'd37, 6'd36, 6'd35, 6'd34, 6'd33, 6'd32, 6'd31, 6'd30, 6'd29, 6'd29 };
    assign ThisBinMax = BinMax[bin];

    logic unsigned [N-1:0] DefaultValues [0:BINS-1];
    always_comb
    begin
        // These lines are taken from output of GenerateTables.ps1 script, and depend on TOPSIZE (top octave memory length)
        // RAM takes an extra cycle, so there is an offest of 1 when using RAM. See GenerateTables.ps1 line 55.
        // TOPSIZE=8192, RAM:
        // /*
        if(OCT == 0) DefaultValues = '{6'd3, 6'd23, 6'd24, 6'd19, 6'd40, 6'd16, 6'd42, 6'd43, 6'd36, 6'd21, 6'd8, 6'd8, 6'd37, 6'd16, 6'd22, 6'd16, 6'd33, 6'd2, 6'd25, 6'd0, 6'd23, 6'd28, 6'd15, 6'd15};
        else if(OCT == 1) DefaultValues = '{6'd29, 6'd38, 6'd12, 6'd35, 6'd20, 6'd32, 6'd44, 6'd44, 6'd40, 6'd32, 6'd4, 6'd24, 6'd38, 6'd8, 6'd11, 6'd8, 6'd34, 6'd18, 6'd29, 6'd0, 6'd27, 6'd14, 6'd22, 6'd22};
        else if(OCT == 2) DefaultValues = '{6'd42, 6'd19, 6'd32, 6'd43, 6'd10, 6'd16, 6'd22, 6'd22, 6'd20, 6'd16, 6'd2, 6'd32, 6'd19, 6'd4, 6'd24, 6'd4, 6'd17, 6'd26, 6'd31, 6'd0, 6'd29, 6'd22, 6'd11, 6'd11};
        else if(OCT == 3) DefaultValues = '{6'd21, 6'd36, 6'd16, 6'd47, 6'd5, 6'd32, 6'd34, 6'd11, 6'd32, 6'd8, 6'd1, 6'd16, 6'd29, 6'd2, 6'd12, 6'd20, 6'd26, 6'd30, 6'd32, 6'd0, 6'd30, 6'd26, 6'd20, 6'd20};
        else if(OCT == 4) DefaultValues = '{6'd38, 6'd18, 6'd8, 6'd49, 6'd27, 6'd16, 6'd40, 6'd28, 6'd16, 6'd4, 6'd21, 6'd8, 6'd34, 6'd20, 6'd6, 6'd28, 6'd13, 6'd32, 6'd16, 6'd0, 6'd15, 6'd28, 6'd10, 6'd10};
        // */

        // TOPSIZE=1024, DFFs:
         /*
        if(OCT == 0) DefaultValues = '{6'd22, 6'd37, 6'd17, 6'd48, 6'd6, 6'd33, 6'd35, 6'd12, 6'd33, 6'd9, 6'd2, 6'd17, 6'd30, 6'd3, 6'd13, 6'd21, 6'd27, 6'd31, 6'd33, 6'd1, 6'd31, 6'd27, 6'd21, 6'd21};
        else if(OCT == 1) DefaultValues = '{6'd39, 6'd19, 6'd9, 6'd50, 6'd28, 6'd17, 6'd41, 6'd29, 6'd17, 6'd5, 6'd22, 6'd9, 6'd35, 6'd21, 6'd7, 6'd29, 6'd14, 6'd33, 6'd17, 6'd1, 6'd16, 6'd29, 6'd11, 6'd11};
        else if(OCT == 2) DefaultValues = '{6'd20, 6'd10, 6'd5, 6'd51, 6'd39, 6'd33, 6'd21, 6'd15, 6'd9, 6'd3, 6'd32, 6'd25, 6'd18, 6'd11, 6'd4, 6'd33, 6'd25, 6'd17, 6'd9, 6'd1, 6'd24, 6'd15, 6'd6, 6'd6};
        else if(OCT == 3) DefaultValues = '{6'd38, 6'd32, 6'd29, 6'd26, 6'd20, 6'd17, 6'd11, 6'd8, 6'd5, 6'd2, 6'd37, 6'd33, 6'd29, 6'd25, 6'd21, 6'd17, 6'd13, 6'd9, 6'd5, 6'd1, 6'd28, 6'd23, 6'd18, 6'd18};
        else if(OCT == 4) DefaultValues = '{6'd47, 6'd43, 6'd41, 6'd39, 6'd35, 6'd33, 6'd29, 6'd27, 6'd25, 6'd23, 6'd19, 6'd17, 6'd15, 6'd13, 6'd11, 6'd9, 6'd7, 6'd5, 6'd3, 6'd1, 6'd30, 6'd27, 6'd24, 6'd24};
         */

        // TOPSIZE=512, DFFs:
         /*
        if(OCT == 0) DefaultValues = '{6'd39, 6'd19, 6'd9, 6'd50, 6'd28, 6'd17, 6'd41, 6'd29, 6'd17, 6'd5, 6'd22, 6'd9, 6'd35, 6'd21, 6'd7, 6'd29, 6'd14, 6'd33, 6'd17, 6'd1, 6'd16, 6'd29, 6'd11, 6'd11};
        else if(OCT == 1) DefaultValues = '{6'd20, 6'd10, 6'd5, 6'd51, 6'd39, 6'd33, 6'd21, 6'd15, 6'd9, 6'd3, 6'd32, 6'd25, 6'd18, 6'd11, 6'd4, 6'd33, 6'd25, 6'd17, 6'd9, 6'd1, 6'd24, 6'd15, 6'd6, 6'd6};
        else if(OCT == 2) DefaultValues = '{6'd38, 6'd32, 6'd29, 6'd26, 6'd20, 6'd17, 6'd11, 6'd8, 6'd5, 6'd2, 6'd37, 6'd33, 6'd29, 6'd25, 6'd21, 6'd17, 6'd13, 6'd9, 6'd5, 6'd1, 6'd28, 6'd23, 6'd18, 6'd18};
        else if(OCT == 3) DefaultValues = '{6'd47, 6'd43, 6'd41, 6'd39, 6'd35, 6'd33, 6'd29, 6'd27, 6'd25, 6'd23, 6'd19, 6'd17, 6'd15, 6'd13, 6'd11, 6'd9, 6'd7, 6'd5, 6'd3, 6'd1, 6'd30, 6'd27, 6'd24, 6'd24};
        else if(OCT == 4) DefaultValues = '{6'd24, 6'd22, 6'd21, 6'd20, 6'd18, 6'd17, 6'd15, 6'd14, 6'd13, 6'd12, 6'd10, 6'd9, 6'd8, 6'd7, 6'd6, 6'd5, 6'd4, 6'd3, 6'd2, 6'd1, 6'd31, 6'd29, 6'd27, 6'd27};
        // */
    end

    logic ResetThisBin;
    assign ResetThisBin = (Counters[bin] + 1'd1) == ThisBinMax;

    always_ff @(posedge clk)
    begin
        if(rst) Counters <= DefaultValues;
        else if(increment) Counters[bin] <= (ResetThisBin ? '0 : (Counters[bin] + 1'd1));
    end
endmodule