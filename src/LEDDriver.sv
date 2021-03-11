/* driver for the WS2801 3 Channel Constant Current LED Driver
** data comes in from red[7] to blue[0]
**/

module LEDDriver #(
    parameter LEDS  = 50,                   // number of LEDs being drivern
    parameter FREQ  = 12_500_000            // clk frequency
) (
    output logic dOut, clkOut,              // outputs to LED
    output logic done,                      // comms output to visualizer

    input  logic [(24*LEDS)-1:0] led_rgb,   // data input from visualizer
    input  logic start,                     // comms input from visualizer
    input  logic clk, rst                   // standard inputs
);

    //logic [(24*LEDS)-1:0] led_rgb;

    initial assert (FREQ <= 25_000_000); // WS2801 LEDs take a maximum frequency of 25 MHz

    localparam waitCntrSize = $clog2(FREQ/1000); // 1~2 ms wait
    localparam loadCntrSize = $clog2(LEDS*24);   // one # per line

    // TODO: counters can be optimized for "fast counting"
    logic [waitCntrSize:0] waitCntr;
    logic [loadCntrSize:0] loadCntr;
    
    typedef enum logic {loadState, waitState} state_e;
    state_e ps, ns;

    always_ff @(posedge clk) begin : transition
        if (rst) ps <= waitState;
        else     ps <= ns;
    end

    // transistion condition logic
    always_comb begin : transition_logic
        case (ps)
            waitState: if (waitCntr[waitCntrSize] & start) ns = loadState;
                       else                                ns = ps;
            loadState: if (loadCntr[loadCntrSize])         ns = waitState;
                       else                                ns = ps;
            default  :                                     ns = waitState;
        endcase
    end

    // counter update logic
    always_ff @(negedge clk) begin : ns_output
        if (rst) begin
            waitCntr <= '0;
            loadCntr <= '0;
        end

        else begin
            waitCntr <= (ns == waitState) ? waitCntr + 1 : '0;
            loadCntr <= (ns == loadState) ? loadCntr + 1 : '0;
        end
    end

    // output logic
    assign dOut   = led_rgb[LEDS*24 - 1 - loadCntr] && (ns == loadState);   // reads data from msb to lsb
    assign clkOut = clk && (ps == loadState);
    assign done   = (ps == waitState);

endmodule

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

    localparam waitCntrSize = $clog2(FREQ/1000); // 1~2 ms wait

    logic [BIN_QTY - 1 : 0][23 : 0] rgbRegistered;
    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCountsRegistered;

    logic [waitCntrSize - 1 : 0] WaitCntr;
    logic [$clog2(BIN_QTY) - 1 : 0] BinCntr;
    logic [5 : 0] SerialCntr;

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
            CNTR_S: if (BinCntr == 12)                      ns = WAIT_S;
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
                    BinCntr <= 0;
                end
                CNTR_S: begin
                    WaitCntr <= '0;
                    Color <= rgbRegistered[BinCntr];
                    LEDCountsRegistered[BinCntr] <= LEDCountsRegistered[BinCntr] - 1;
                    if (LEDCountsRegistered[BinCntr] == 0) BinCntr <= BinCntr + 1;
                    SerialCntr <= 23;
                end
                LOAD_S: begin
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
    localparam TB_PERIOD =  80ps;

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

    initial begin
        rst = '1; repeat(10) @(posedge clk);
        rst = '0;
        start = 1;

        rgb = {'0,24'hAAAAAA, 24'hF0F0F0F0, 24'hFFFFFF};
        LEDCounts = {'0, 6'd20, 6'd20, 6'd10};

        wait(!done);
        wait(done);

        $stop();
    end

endmodule

module LEDDriver_testbench();

    localparam TB_FREQ = 12_500_000;
    localparam TB_PERIOD =  80ps;

    logic [23:0] led_rgb;
    logic dOut, clkOut;
    logic done;
    logic start;
    logic clk, rst;

    integer i;


    // DUT
    LEDDriver #(
        .LEDS(1), 
        .FREQ(TB_FREQ)
    ) dut (
        .dOut    (dOut   ),
        .clkOut  (clkOut ),
        .done    (done   ),
        .led_rgb (led_rgb),
        .start   (start  ),
        .clk     (clk    ),
        .rst     (rst    )
    );

    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    task loadColor (input [23:0] rgb, output success);
        begin

            success = 1;

            // waits until the the first rising edge of the load state
            wait(done);
            led_rgb <= rgb;
            start   <= '1;
            wait(clkOut);
            
            // checks data 5ps after clock edge for defined behavior
            for (i = 0; i < 24; i++) begin
                // assert that output value is expected
                assert(dOut == rgb[23 - i]) else begin
                    $display("time = %0t expected = %b recieved = %b", $time, rgb[23 - i], dOut);
                    success = 0;
                end
                // wait for the next output
                @(posedge clk);    
            end
        end
    endtask

    assert property (@(posedge clk, negedge clk) $changed(dOut) |-> ##1 $rose(clkOut));

    initial begin
        $timeformat(-9, 2, " ns", 20);  // formats to ns
        
        rst <= '1; repeat(5) @(posedge clk);
        rst <= '0;

        loadColor(24'h800000, i);
        assert(i) $display("successfully loaded %h", 24'h800000); else $error("failed loading %h", 24'h800000);
        loadColor(24'hffffff, i);
        assert(i) $display("successfully loaded %h", 24'hffffff); else $error("failed loading %h", 24'hffffff);
        loadColor(24'h555555, i);
        assert(i) $display("successfully loaded %h", 24'h555555); else $error("failed loading %h", 24'h555555);
        loadColor(24'h000001, i);
        assert(i) $display("successfully loaded %h", 24'h000001); else $error("failed loading %h", 24'h000001);

        $stop();
    end
endmodule


module LEDStripDriver_testbench();

    localparam TB_LEDS = 5;             // number of LEDs

    localparam TB_FREQ = 12_500_000;
    localparam TB_PERIOD =  80ps;

    // driver logic
    logic done;
    logic [(24*TB_LEDS)-1:0] led_rgb;
    logic start;
    logic clk, rst;
    
    // strip logic
    logic [TB_LEDS-1:0][23:0] rgb;
    logic [TB_LEDS:0] SDIO, CKIO;
    logic [TB_LEDS-1:0][23:0] expected;


    integer i;
    genvar j;

    // generate the LED strip
    generate
        for (j = 0; j < TB_LEDS; j++) begin : LEDS
            LEDModel led (.rgb(rgb[j]), .SDO(SDIO[j+1]), .CKO(CKIO[j+1]), .SDI(SDIO[j]), .CKI(CKIO[j]));
        end
    endgenerate

    // Driver unit
    LEDDriver #(
        .LEDS(TB_LEDS), 
        .FREQ(TB_FREQ)
    ) driver (
        .dOut    (SDIO[0]),
        .clkOut  (CKIO[0]),
        .done    (done   ),
        .led_rgb (led_rgb),
        .start   (start  ),
        .clk     (clk    ),
        .rst     (rst    )
    );

    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    task loadColor (input [(24*TB_LEDS)-1:0] rgb);
        begin
            // waits until the the first rising edge of the load state
            wait(done);
            led_rgb <= rgb;
            start   <= '1;
            wait(CKIO[0]);
            
            // checks data 5ps after clock edge for defined behavior
            for (i = 0; i < 24*TB_LEDS; i++) begin
                #5ps assert(SDIO[0] == rgb[TB_LEDS*24 - 1 - i]) 
                    else $display("time = %0t expected = %b recieved = %b", $time, rgb[TB_LEDS*24 - 1 - i], SDIO[0]);
                @(posedge clk);    
            end
        end
    endtask

    initial begin
        $timeformat(-9, 2, " ns", 20);  // formats to ns
        
        rst <= '1; repeat(5) @(posedge clk);
        rst <= '0;

        loadColor({TB_LEDS{24'h800000}});
        loadColor({TB_LEDS{24'hffffff}});
        loadColor({TB_LEDS{24'h555555}});
        loadColor({TB_LEDS{24'h000001}});
    
        $display("If no assertions errors appeared the simulation was a success");

        $stop();
    end

endmodule