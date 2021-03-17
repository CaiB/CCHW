import CCHW::*;

/*  The LEDDriver2 is an improvment on the LEDDriver which is no longer used in the project
*   LEDDriver2 serializes color words (24 bit) and organizes them into frames each "LEDS" words long
*   Frames are spaced by a minimum 500us to meet the spec of the WS2801 LED Driver recieving the color data
*   Each serielized data bit is sent with a parallel clock signal rising a half cycle after the data signal
*    is set so that the WS2801 LED Driver captures the bit
*
*   The LEDDriver2 is organized as a 3 state FSM:
*       WAIT_S - stops serializtation to make space between frames  (500+ us)
*       CNTR_S - evaluates which of the input color words should next be serialized (1-12 clk cycles)
*       LOAD_S - serializes and outputs the chosen color word (24 * FREQ_DIV clk cycles)
*/

module LEDDriver2 #(
    parameter LEDS  = 50,                   // the number of color words per frame
    parameter FREQ  = 12_500_000,           // input clock frequency in Hz
    parameter BIN_QTY = 12,                 // number "unique" color words being serialized
    parameter FREQ_DIV = 4,                 // ratio of the system clock to the serial output "clock" (powers of 2 only)
    parameter WaitMultiplier = 2            // multiplierfor the time period between frames (powers of 2 only)
) (
    output logic dOut, clkOut,              // data and clock outputs to WS2801 
    output logic done,                      // debug logic

    input logic [BIN_QTY - 1 : 0][23 : 0] rgb,                          // array of unique color words
    input logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts,      // numbers of words associated with the colors
    input logic start,                                                  // input register enable
    input logic clk, rst                                                // system clock and reset
);

    localparam FD_LOG = $clog2(FREQ_DIV);                       

    // ======== input data registers ========
    logic unsigned [BIN_QTY - 1 : 0][23 : 0] rgbRegistered;                         // internally registered array of unique color words
    logic unsigned [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCountsRegistered;     // internally registered numbers of words associated with the colors

    // ======== fsm counters ========
    logic unsigned [$clog2(FREQ/2000) + $clog(WaitMultiplier) - 1 : 0] WaitCntr;    // counts to ~500us*WaitMultiplier and used in WAIT_S
    logic unsigned [$clog2(BIN_QTY) - 1 : 0] BinCntr;                               // iterator for the color words, expected to always be between 0 and BIN_QTY
    logic unsigned [$clog2(LEDS) - 1 : 0] ColorCount;                               // frame word counter - preset to the LEDS, the number of color words per frame
    logic unsigned [5 + FD_LOG : 0] SerialCntr;                                     // color word bit iterator, top bits used to iterate through 24 bits, bottom bits slow iteration

    // ======== edge case logic ========
    logic unsigned [$clog2(BIN_QTY) - 1 : 0] BinLast;   // retains the array location of the most recently loaded color word

    // ======== output data ========
    logic [23 : 0] Color;                               // registered color word being serialized on dOut in the LOAD_S state
    logic DataV;                                        // allows the clkOut signal to go high when valid data is on the dOut line

    // ======== state variables ========
    typedef enum logic [1:0] {WAIT_S, CNTR_S, LOAD_S} state;
    state ps, ns;


    // fsm edge traversal - applies state transitions
    always_ff @(posedge clk) begin
        if (rst) ps <= WAIT_S;
        else ps <= ns;
    end

    // fsm edge logic - computes the next state
    always_comb begin
        case (ps)
            WAIT_S: if (&WaitCntr)                              ns = CNTR_S; // wait until the waitCntr overflows to start new frame
                    else                                        ns = ps;

            CNTR_S: if (ColorCount == 0)                        ns = WAIT_S; // the frame is complete once LEDS words have been serialized
                    else if (LEDCountsRegistered[BinCntr] == 0) ns = CNTR_S; // if the number of words associated with a color is 0 don't serialize it
                    else                                        ns = LOAD_S; // serialize the computed color

            LOAD_S: if (&SerialCntr)                            ns = CNTR_S; // once serialization is complete compute the next color word to be serialized
                    else                                        ns = ps;

            default:                                            ns = WAIT_S;
        endcase
    end

    // fsm state logic - computes internal signals to use for the following state
    always_ff @(posedge clk) begin

        // on a reset set all counters to 0 and block serial output
        if (rst) begin
            WaitCntr    <= '0;
            BinCntr     <= '0;
            SerialCntr  <= '0;
            DataV       <= '0;
        end

        else begin
            // assume data is invalid unless in the LOAD_S state
            DataV <= '0;

            case (ns)
                WAIT_S: begin
                    // increment the counter
                    WaitCntr <= WaitCntr + 1;
                    
                    // register the the new input values if input valid signal is high
                    if (start) rgbRegistered <= rgb;
                    if (start) LEDCountsRegistered <= LEDCounts;

                    // set values to their defaults
                    ColorCount <= LEDS;
                    BinLast <= '0;
                    BinCntr <= '0;
                end
                CNTR_S: begin
                    // reset the timer for the interframe pause
                    WaitCntr <= '0;

                    // load color based on the iterator (binCntr) and preset the load counter 
                    Color <= rgbRegistered[BinCntr];
                    SerialCntr <= {5'd23,{FD_LOG{1'b1}}};

                    // decrement the remaining frame word count and the current color word count after a load
                    if (ps == LOAD_S) begin 
                        ColorCount <= ColorCount - 1;
                        LEDCountsRegistered[BinCntr] <= LEDCountsRegistered[BinCntr] - 1;
                    end

                    // if the color count is depleted increment the iterator - move to the next color
                    if (LEDCountsRegistered[BinCntr] == 0) BinCntr <= BinCntr + 1;

                    // if all colors have been iterated through return to the last used color and finish the frame with it 
                    if (BinCntr >= (BIN_QTY - 1)) begin
                        BinCntr <= BinLast;
                        Color <= rgbRegistered[BinLast];
                        LEDCountsRegistered[BinLast] <= ColorCount;
                    end
                end
                LOAD_S: begin
                    // save the color location
                    BinLast <= BinCntr;         

                    // set the data and enable the parallel clock output line (clkOut)
                    // bits FD_LOG - 1 : 0 slow down the output clock
                    // bits 5 + FD_LOG : FD_LOG are in the range 0 : 23 and determine which color word bit is on the dOut line
                    DataV <= '1;
                    dOut <= Color[SerialCntr[5 + FD_LOG : FD_LOG]]; 

                    // decrement the the counter
                    SerialCntr <= SerialCntr - 1;
                end
            endcase 
        end
    end

    // clkOut allows dOut to be captured by the WS2801 and is gated by the DataV signal
    // the topmost of the "clock divider" bits is used as the output clock but is negated
    //  so it goes high at least half a cycle after the dOut line is set
    assign clkOut = DataV & ~SerialCntr[FD_LOG-1];

    // the debug done signal is high as long as the driver is not in the middle of a frame
    assign done = (ps == WAIT_S);

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
        //testInputs({'0},{'0});
        //testInputs({'0},{'0});

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
