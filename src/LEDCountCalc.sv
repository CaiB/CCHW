/*  LEDCountCalc converts fixed point amplitude to integer value relative proportions,
*    the sum of which adds up to LEDS. The actual resulting sum can be marginally smaller
*    and needs to be handled further in the project
*/

module LEDCountCalc #(
    parameter W = 6,                        // number of whole bits in the fixed point format
    parameter D = 10,                       // number of decimal  bits in the fixed point format - precision to ~.001
    parameter LEDS = 50,                    // total which the individual counts should sum to
    parameter BIN_QTY  = 12                 // number of independant notes being processed

    // =============== Fixed Point Specific Parameters ===============
    // The following parameters are computed based on the above parameters W and D. 
    // See LinearVisualizer.sv : line 24 for instruction on how to recompute
    parameter LEDS_X = 20,                  // 0.0195... ~ 20 ~ 0000010100 - D bit fixed point inverse of LEDS
) (
    output logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCount,  // integer ratios of the amplitudes which should add up to LEDS
    output logic data_v,                                            // set high when the output data is valid

    input logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes_i,  // original LV amplitudes but reduced and filtered
    input logic [W + D - 1 + $clog2(BIN_QTY): 0] amplitudeSumNew_i, // original LV amplitudes but filtered
    input logic start, clk, rst                                     // system clock and reset
);

    // propogates the start signal so that the done signal goes high after 3 cycles
    logic [3:0] valid_delay;

    // =============== cycle 0 outputs and registers ===============
    logic [W + D + D - 1 + $clog2(BIN_QTY) - $clog2(LEDS) : 0] thresholdAmplitude;
    logic [W + D - 1 + $clog2(BIN_QTY) - $clog2(LEDS) : 0] thresholdAmplitude_d1;

    // =============== cycle 1 outputs and registers ===============
    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCountReg, LEDCountReg_d1;

    integer i;

    always_comb begin
        // cycle 1 : compute a threshold amplitude so that LEDS of the thresholds will sum to become the amplitudeSum
        thresholdAmplitude = amplitudeSumNew_i * LEDS_X;

        // cycle 2 : find the number of times the thresholds fit into each amplitude value 
        for (i = 0; i < BIN_QTY; i++) begin
            LEDCountReg[i] = noteAmplitudes_i[i] / thresholdAmplitude_d1;
        end

        data_v = valid_delay[3];

    end

    always_ff @(posedge clk) begin
        if (rst) begin 
            valid_delay = '0;
        end
        else begin
            // register the cycle outputs
            thresholdAmplitude_d1 <= thresholdAmplitude[W + D + D - 1 + $clog2(BIN_QTY) - $clog2(LEDS) : D]; // drop bottom D bits
            LEDCountReg_d1 <= LEDCountReg;

            // register the output data
            LEDCount <= LEDCountReg_d1;

            valid_delay <= {valid_delay[2:0], start};
        end
        
    end

endmodule