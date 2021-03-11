module LEDDriver2 #(
    parameter LEDS  = 50,                   // number of LEDs being drivern
    parameter FREQ  = 12_500_000,           // clk frequency
    parameter BIN_QTY = 12
) (
    output logic dOut, clkOut,              // outputs to LED
    output logic done,                      // comms output to visualizer

    input logic [BIN_QTY - 1 : 0][23 : 0] rgb,
    input logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts,
    input logic start,                     // comms input from visualizer
    input logic clk, rst                   // standard inputs
);

    localparam waitCntrSize = $clog2(FREQ/2000); // 0.5~1 ms wait

    logic [BIN_QTY - 1 : 0][23 : 0] rgbRegistered;
    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCountsRegistered;

    logic [waitCntrSize - 1 : 0] WaitCntr;
    logic [$clog2(BIN_QTY) - 1 : 0] BinCntr;
    logic [5 : 0] SerialCntr;

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
            WAIT_S: if (&WaitCntr)                          ns = CNTR_S;
            CNTR_S: if (ColorCount == 0)                    ns = WAIT_S;
                    else if (rgbRegistered[BinCntr] == 0)   ns = CNTR_S;
                    else                                    ns = LOAD_S;
            LOAD_S: if (&SerialCntr)                        ns = CNTR_S;
            default:                                        ns = WAIT_S;
        endcase
    end

    // state logic
    always_ff @(posedge clk) begin
        if (rst) begin
            WaitCntr <= '0;
            BinCntr <= '0;
            SerialCntr <= '0;
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
                    if (LEDCountsRegistered[BinCntr] <= 1) BinCntr <= BinCntr + 1;
                    SerialCntr <= 23;

                    // ensures 50 LEDs are always filled
                    if (BinCntr == (BIN_QTY - 1)) begin 
                        BinCntr <= BinLast;
                        LEDCountsRegistered[BinLast] = ColorCount;
                    end

                end
                LOAD_S: begin
                    // save the most recently used color and bin
                    BinLast <= BinCntr;

                    // set output clock to valid
                    data_v <= '1;
                    dOut <= Color[SerialCntr];
                    SerialCntr <= SerialCntr - 1;
                end
            endcase 
        end
    end

    assign clkOut = data_v & ~clk;
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
        .FREQ(TB_FREQ)
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