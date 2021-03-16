include Common.sv;
import CCHW::*;

module LEDDriver2 #(
    parameter LEDS  = 50,                   // number of LEDs being drivern
    parameter FREQ  = 12_500_000,           // clk frequency
    parameter BIN_QTY = 12,
    parameter FREQ_DIV = 4,
    parameter WaitMultiplier = 2
) (
    output logic dOut, clkOut,              // outputs to LED
    output logic done,                      // comms output to visualizer

    input logic [BIN_QTY - 1 : 0][23 : 0] rgb,
    input logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts,
    input logic start,                     // comms input from visualizer
    input logic clk, rst                   // standard inputs
);

    localparam waitCntrSize = $clog2(FREQ/2000) + WaitMultiplier - 1; // 0.5~1 ms *2 ^ * WaitMultiplier - 1) 
    localparam FD_LOG = $clog2(FREQ_DIV);

    logic [BIN_QTY - 1 : 0][23 : 0] rgbRegistered;
    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCountsRegistered;

    logic [waitCntrSize - 1 : 0] WaitCntr;
    logic [$clog2(BIN_QTY) - 1 : 0] BinCntr;
    logic [5 + FD_LOG : 0] SerialCntr;

    logic [$clog2(BIN_QTY) - 1 : 0] BinLast;

    logic [23 : 0] Color;
    logic [$clog2(LEDS) - 1 : 0] ColorCount;

    logic data_v;


    typedef enum logic [1:0] {WAIT_S, CNTR_S, LOAD_S} state;
    state ps, ns;


    // state transitioning
    always_ff @(posedge clk) begin
        if (rst) ps <= WAIT_S;
        else ps <= ns;
    end

    // next state logic
    always_comb begin
        case (ps)
            WAIT_S: if (&WaitCntr & start)                  ns = CNTR_S;
                    else                                    ns = ps;
            CNTR_S: if (ColorCount == 0)                    ns = WAIT_S;
                    else if (rgbRegistered[BinCntr] == 0)   ns = CNTR_S;
                    else                                    ns = LOAD_S;
            LOAD_S: if (&SerialCntr)                        ns = CNTR_S;
                    else                                    ns = ps;
            default:                                        ns = WAIT_S;
        endcase
    end

    // state logic
    always_ff @(posedge clk) begin
        if (rst) begin
            WaitCntr <= '0;
            BinCntr <= '0;
            SerialCntr <= '0;
            data_v <= '0;
        end
        else begin

            data_v <= '0;

            case (ns)
                WAIT_S: begin
                    WaitCntr <= WaitCntr + 1;
                    rgbRegistered <= rgb;
                    LEDCountsRegistered <= LEDCounts;
                    ColorCount <= LEDS;
                    BinCntr <= '0;
                end
                CNTR_S: begin
                    WaitCntr <= '0;
                    Color <= rgbRegistered[BinCntr];
                    LEDCountsRegistered[BinCntr] <= LEDCountsRegistered[BinCntr] - 1;
                    if (ps == LOAD_S) ColorCount <= ColorCount - 1;
                    if (LEDCountsRegistered[BinCntr] < 2) BinCntr <= BinCntr + 1;
                    SerialCntr <= {5'd23,{FD_LOG{1'b1}}};

                    // ensures 50 LEDs are always filled
                    if (BinCntr == (BIN_QTY - 1)) begin 
                        BinCntr <= BinLast;
                        Color <= rgbRegistered[BinLast];
                        LEDCountsRegistered[BinLast] <= ColorCount;
                    end

                end
                LOAD_S: begin
                    // save the most recently used color and bin
                    BinLast <= BinCntr;

                    // set output clock to valid
                    data_v <= '1;
                    dOut <= Color[SerialCntr[5 + FD_LOG : FD_LOG]];
                    SerialCntr <= SerialCntr - 1;
                end
            endcase 
        end
    end

    assign clkOut = data_v & ~SerialCntr[FD_LOG-1];
    assign done = ps == WAIT_S;

endmodule

module LEDDriver2_testbench();

    parameter LEDS  = 50;
    parameter FREQ  = 12_500_000;
    parameter BIN_QTY = 12;
    localparam TB_FREQ = 12_500_000;
    localparam TB_PERIOD =  80ns;

    logic dOut, clkOut;              // outputs to LED
    logic done;                      // comms output to visualizer
    logic [BIN_QTY - 1 : 0][23 : 0] rgb;
    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts;
    logic start;                     // comms input from visualizer
    logic clk, rst;                  // standard inputs

    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    // DUT
    LEDDriver2 #(
        .LEDS(LEDS), 
        .FREQ(TB_FREQ),
        .FREQ_DIV(5)
    ) dut (
        .dOut    (dOut   ),
        .clkOut  (clkOut ),
        .done    (done   ),
        .rgb     (rgb    ),
        .LEDCounts(LEDCounts),
        .start   (start  ),
        .clk     (clk    ),
        .rst     (rst    )
    );

    task reset(integer duration); begin
            rst = '1; repeat(duration) @(posedge clk);
            rst = '0;
            start = 1;
        end
    endtask

    task testInputs (input logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] count,
                     input logic [BIN_QTY - 1 : 0][23 : 0] color);
         begin
             rgb = color;
            LEDCounts = count;

            wait(!done);
            wait(done);
         end

    endtask

    initial begin
        reset(10);

        testInputs({'0, 6'd10, 6'd10, 6'd10},{'0,24'hAAAAAA, 24'hF0F0F0F0, 24'hFFFFFF});
        testInputs({'0, 6'd10, 6'd10, 6'd10},{'0,24'hAAAAAA, 24'hF0F0F0F0, 24'hFFFFFF});

        $stop();
    end

endmodule

module LV_Driver_testbench();
    localparam TB_FREQ = 12_500_000;
    localparam TB_PERIOD =  80ns;
    parameter W = 6;                        // max whole value 63
    parameter D = 10;                       // decimal precision to ~.001
    parameter LEDS  = 50;                   // number of LEDs being driven
    parameter BIN_QTY = 12;
    parameter steadyBright = 'b0;           // True

    // these assume the W and D above, use fixedPointCalculator.py to recalculate if needed
    parameter LEDFloor = 102;               // 0.0996... ~ 102 ~ 0001100110
    parameter LEDLimit = 1023;              // ~1.0 ~ 1023 ~ 1111111111
    parameter SaturationAmplifier = 1638;   // 1.599.. ~ 1638 ~ 1_1111000000
    parameter yellowToRedSlope  = 21824;    // 21.3125 ~  21824 ~  'b10101_0101000000
    parameter redToBlueSlope    = 43648;    // 42.625  ~  41600 ~ 'b101010_1010000000
    parameter blueToYellowSlope = 65472;    // 63.9375 ~ 130944 ~ 'b111111_1111000000

    integer i;

    logic dOut, clkOut;
    logic [BIN_QTY - 1 : 0][23 : 0] rgb;
    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts;
    Note [BIN_QTY - 1 : 0] notes;

    logic ld_done, lv_dv;
    logic lv_start;
    logic clk, rst;

    LEDDriver2 #(
        .LEDS(LEDS), 
        .FREQ(TB_FREQ),
        .FREQ_DIV(5)
    ) ld_u (
        .dOut    (dOut      ),
        .clkOut  (clkOut    ),
        .done    (ld_done   ),
        .rgb     (rgb       ),
        .LEDCounts(LEDCounts),
        .start   (lv_dv     ),
        .clk     (clk       ),
        .rst     (rst       )
    );


    LinearVisualizer #(
        .W                  (W              ),
        .D                  (D              ),
        .LEDS               (LEDS           ),
        .BIN_QTY            (BIN_QTY        ),
        .steadyBright       (steadyBright   ),
        .LEDFloor           (102            ),
        .LEDLimit           (LEDLimit       ),
        .SaturationAmplifier(SaturationAmplifier),
        .yellowToRedSlope   (yellowToRedSlope   ),
        .redToBlueSlope     (redToBlueSlope     ),
        .blueToYellowSlope  (blueToYellowSlope  )
    ) lv_u (
        .rgb            (rgb            ),
        .LEDCounts      (LEDCounts      ),
        .data_v         (lv_dv          ),
        .notes          (notes          ),
        .start          (lv_start       ),
        .clk            (clk            ),
        .rst            (rst            )
    );

    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    logic [W + D - 1 : 0] testAmplitudes [BIN_QTY - 1 : 0];
    logic [W + D - 1 : 0] testPositions [BIN_QTY - 1 : 0];

    initial begin
        $readmemb("../other/testNotePositions.mem", testPositions);
        $readmemb("../other/testNoteAmplitudes.mem", testAmplitudes);
    end

    task reset(input duration);
        begin
            rst = '1; @(posedge clk);
            repeat(10) @(posedge clk);
            rst = '0;
        end
    endtask

    task runCycle(input logic [W + D - 1 : 0] amplitudes [BIN_QTY - 1 : 0],
                  input logic [W + D - 1 : 0] positions [BIN_QTY - 1 : 0]);
        begin
            lv_start = 1;

            for (i = 0; i < BIN_QTY; i++) begin
                notes[i].amplitude = amplitudes[i];
                notes[i].position = 24 * positions[i];
                notes[i].valid = '1;
            end

            wait(!ld_done);
            wait(ld_done);
            lv_start = 0;
        end
    endtask

    initial begin

        reset(10);
        runCycle(testAmplitudes, testPositions);

        $stop();
    end
endmodule
