/*  The AmpPreprocessor filters out amplitudes below a relative threshold set by LEDFloor
*   It takes a total of 4 cycles to compute, the outputs are registered because the upcoming computations are heavy
*       cycle 0 - calculate the cumulative sum of the amplitudes
*       cycle 1 - compute the relative amplitude threshold
*       cycle 2 - test the amplitudes against the threshold
*       cycle 4 - recompute the cumulative sum with the filtered amplitudes
*/

module AmpPreprocessor #(
    parameter W = 5,                        // number of whole bits in the fixed point format
    parameter D = 11,                       // number of decimal  bits in the fixed point format - precision to ~.001
    parameter BIN_QTY  = 12,                // number of independant amplitudes being processed

    // =============== Fixed Point Specific Parameters ===============
    // The following parameters are computed based on the above parameters W and D. 
    // See LinearVisualizer.sv : line 24 for instruction on how to recompute
    parameter LEDFloor = 205                // 0.100... ~ 205 ~ 00011001101 - sets the relative threshold value for amplitudes to be considered 
) (
    output logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes_o,     // original amplitudes but reduced and filtered
    output logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudesFast_o, // original amplitudes but filtered
    output logic [W + D - 1 + $clog2(BIN_QTY): 0] amplitudeSumNew_o,    // sum of all noteAmplitudes_o
    output logic data_v,                                                // set when the computation is complete

    input logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes_i,      // input array of note amplitudes [0, 63.999]
    input logic start, clk, rst                                         // system clock and reset
);
    localparam WIDTH = W + D - 1;   // fixed point value total width

    integer i, j, k;

    // propogates the start signal so that the done signal goes high after 4 cycles
    logic [3:0] valid_delay;
    
    // ============== cycle 0 outputs and register ==============
    logic [WIDTH + $clog2(BIN_QTY) : 0] amplitudeSum, amplitudeSum_d1;
    
    // ============== cycle 1 wires, outputs and register ==============
    logic [WIDTH + $clog2(BIN_QTY) + D : 0] threshold_tmp;
    logic [WIDTH + $clog2(BIN_QTY) : 0] threshold, threshold_d1;

    // ============== cycle 2 outputs and register ==============
    logic [BIN_QTY - 1 : 0][WIDTH + 1 : 0] noteAmplitudesReduced;
    logic [BIN_QTY - 1 : 0][WIDTH : 0] noteAmplitudesSlow;
    logic [BIN_QTY - 1 : 0][WIDTH : 0] noteAmplitudesFast;

    // ============== cycle 3 outputs==============
    logic [WIDTH + $clog2(BIN_QTY) : 0] amplitudeSumNew;


    always_comb begin
        // cycle 0: accmulation - sum all of the amplitudes at the input
        amplitudeSum = 'd0;
        for (i = 0; i < BIN_QTY; i++) begin
            amplitudeSum += noteAmplitudes_i[i];
        end

        // cycle 1: multiply the amplitude sum with the parameter to find the relative amplitude threshold
        threshold_tmp = (amplitudeSum_d1 * LEDFloor);
        threshold = threshold_tmp[WIDTH + $clog2(BIN_QTY) + D : D]; // reduce the multiplication result to the 16 bit fixed point representation

        // cycle 2: reduce all amplitudes by the threshold and set subzero amplitudes to 0 ; duplicate this amplitude array but with original values
        for (j = 0; j < BIN_QTY; j++) begin
            noteAmplitudesReduced[j] = {'0, noteAmplitudes_i[j]} - {1'b0, threshold_d1};

            noteAmplitudesFast[j] = noteAmplitudesReduced[j][WIDTH+1] ? '0 : noteAmplitudes_i[j];
            noteAmplitudesSlow[j] = noteAmplitudesReduced[j][WIDTH+1] ? '0 : noteAmplitudesReduced[j][WIDTH:0];
        end

        // cycle 3 accumulation - sum all of the reduced amplitudes from cycle 2 and register all of the computed values
        amplitudeSumNew = 'd0;
        for (k = 0; k < BIN_QTY; k++) begin
            amplitudeSumNew += noteAmplitudesSlow[k];
        end

        // cycle 4 : output the the registered computations and the done signal
        data_v = valid_delay[3];
    
    end

    // pass signals between each cycle stage
    always_ff @(posedge clk) begin
        if (rst) begin
            valid_delay <= '0;
        end 
        else begin
            // register stage outputs
            amplitudeSum_d1 <= amplitudeSum;
            threshold_d1    <= threshold;

            // register the outputs to allocate full clock period for upcoming computations
            noteAmplitudes_o <= noteAmplitudesSlow;
            noteAmplitudesFast_o <= noteAmplitudesFast;
            amplitudeSumNew_o <= amplitudeSumNew;

            // start -> done in 4 cycles
            valid_delay <= {valid_delay[2:0], start};
        end
    end
endmodule