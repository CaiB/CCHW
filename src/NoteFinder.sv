interface Note;
    logic [4:0] position; // TODO totally random number
    logic [25:0] amplitude;
    modport In(input position, input amplitude);
    modport Out(output position, output amplitude);
endinterface

module NoteFinder
#(parameter N = 16, parameter BINS = 120)
(
    Note.Out notes,
    input logic unsigned [N-1:0] dftBins [0:BINS-1],
    input logic clk, rst
);

    // Pre-process DFT input data
        // Shift by some value (amplify)
        // IIR each bin
    
    // Find maximum of all bins

    // Smooth adjacent bins

    // Detect peaks
    // -> Positions are now 0-119

    // Adjust peak location within bin depending on surroundings (turn isPeak into numeric positions)
    // -> Positions are now 0.0-119.0

    // Merge octaves (bins close to each other in other octaves)
    // -> positions are now 0.0-23.0, qty up to 60 (BINS/2)

    // Associate peaks to existing notes, shifting them if needed
    // -> notes max qty 12 (BPO/2)

    // Create new notes if peaks don't have corresponding note

    // Decay notes not associated to
    // -> notes max qty still 12 (BPO/2)?

    // 
endmodule

module PeakDetector
#(parameter N = 16)
(
    output logic isPeak,
    input logic [N-1:0] left, right, here, // the bins to the left and right, as well as this bin here
    input logic [N-1:0] threshold // how large the peak needs to be to be considered a peak, and not just noise
);
    logic localMax;
    assign localMax = (left < here) && (here > right);
    assign isPeak = localMax & (here > threshold);
endmodule
