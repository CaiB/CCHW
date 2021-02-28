module LinearVisualizer #(
    parameter W = 6,                        // max whole value 63
    parameter D = 10,                       // decimal precision to ~.001

    parameter LEDS  = 50,                   // number of LEDs being driven
    parameter BIN_QTY = 12,
    // parameter OctaveBinCount = 24;       // not used

    parameter steadyBright = 'b1,           // True

    // these assume the W and D above, use fixedPointCalculator.py to recalculate if needed
    parameter LEDFloor    = 'b0001100110,   // 0.0996... 
    parameter LEDLimitWhl = 'b000001,       // 1, whole number part of LEDLimit
    parameter LEDLimitDec = 'b0000000000,   // .0, decimal part of LEDLimit
    parameter SatAmpWhl   = 'b000001,       // 1, whole number part of SaturationAmplifier
    parameter SatAmpDec   = 'b1001100110    // 0.5996..., decimal part of SaturationAmplifier
) (
    output  logic [(24*LEDS)-1:0] led_rgb,  // data input from visualizer
    output  logic start,                    // comms input from visualizer
    
    input logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes,
    input logic [BIN_QTY - 1 : 0][W + D - 1 : 0] notePositions,
    input logic done,
    input logic clk, rst
);
    integer i, j;

    logic [W + D - 1 + $clog2(BIN_QTY) : 0] amplitudeSum; // make large enough to hold total sum

    logic [W + D - 1 + $clog2(BIN_QTY) + 10 : 0] amplitudeSumMultiplied_temp;
    logic [W + D - 1 + $clog2(BIN_QTY) : 0] amplitudeSumMultiplied;

    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudesReduced;
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudesFast;
    logic [W + D - 1 + $clog2(BIN_QTY) : 0] amplitudeSumNew;

    // sums the note amplitudes
    always_comb begin
        amplitudeSum = 'd0;
        for (i = 0; i < BIN_QTY; i++) begin
            amplitudeSum += noteAmplitudes[i];
        end
    end

    // finds the relative threshold
    assign amplitudeSumMultiplied_temp = (amplitudeSum * LEDFloor);
    assign amplitudeSumMultiplied = amplitudeSumMultiplied_temp[W + D - 1 + $clog2(BIN_QTY) + 10 : 10];

    // applies the relative threshold
    always_comb begin
        amplitudeSumNew = 'd0;

        for (j = 0; j < BIN_QTY; j++) begin
            noteAmplitudesReduced[j] = {{$clog2(BIN_QTY){1'b0}}, noteAmplitudes[j]} - amplitudeSumMultiplied;
            if (noteAmplitudesReduced[j][W + D - 1]) begin
                noteAmplitudesReduced[j] = '0;
                noteAmplitudesFast[j] = '0;
            end

            else begin
                noteAmplitudesFast[j] = noteAmplitudes[j];
            end

            amplitudeSumNew += noteAmplitudesFast[j];
        end
    end

endmodule

module LinearVisualizer_testbench();
    parameter W = 6;                        // max whole value 63
    parameter D = 10;                       // decimal precision to ~.001
    parameter LEDS  = 50;                   // number of LEDs being drivern
    parameter BIN_QTY = 12;

    logic [(24*LEDS)-1:0] led_rgb;  // data input from visualizer
    logic start;                    // comms input from visualizer
    
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes;
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] notePositions;
    logic done;
    logic clk, rst;

    LinearVisualizer #(
        .W              (W              ),
        .D              (D              ),
        .LEDS           (LEDS           ),
        .BIN_QTY        (BIN_QTY        ),
        .steadyBright   ('b1            ),
        .LEDFloor       ('b0001100110   ),
        .LEDLimitWhl    ('b000001       ),
        .LEDLimitDec    ('b0000000000   ),
        .SatAmpWhl      ('b000001       ),
        .SatAmpDec      ('b1001100110   )  
    ) dut (
        .led_rgb        (led_rgb        ),
        .start          (start          ),
        .noteAmplitudes (noteAmplitudes ),
        .notePositions  (notePositions  ),
        .done           (done           ),
        .clk            (clk            ),
        .rst            (rst            )
    );
    

    initial begin
        noteAmplitudes[0] = 16'b0001000000000000;
        noteAmplitudes[1] = 16'b0001110000000000;
        noteAmplitudes[2] = 16'b0001110000000000;
        noteAmplitudes[3] = 16'b0000000000000000;
        noteAmplitudes[4] = 16'b0000110000000000;
        noteAmplitudes[5] = 16'b0001010000000000;
        noteAmplitudes[6] = 16'b0000000000000000;
        noteAmplitudes[7] = 16'b0010000000000000;
        noteAmplitudes[8] = 16'b0000110000000000;
        noteAmplitudes[9] = 16'b0010010000000000;
        noteAmplitudes[10] = 16'b0001000000000000;
        noteAmplitudes[11] = 16'b0001010000000000;


        #100ps;
    end
endmodule
