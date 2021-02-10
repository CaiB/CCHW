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

    localparam waitCntrSize = $clog2(FREQ/2000); // 500 us wait
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
    always_ff @(posedge clk) begin : ps_output
        if (rst) begin
            waitCntr <= '0;
            loadCntr <= '0;
        end

        else begin
            waitCntr <= (ps == waitState) ? waitCntr + 1 : '0;
            loadCntr <= (ps == loadState) ? loadCntr + 1 : '0;
        end
    end

    // output logic
    assign dOut   = led_rgb[LEDS*24 - 1 - loadCntr] && (ps == loadState);   // reads data from msb to lsb
    assign clkOut = clk && (ps == loadState);
    assign done   = (ps == waitState);

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

    task loadColor (input [23:0] rgb);
        begin

            // waits until the the first rising edge of the load state
            wait(done);
            led_rgb <= rgb;
            start   <= '1;
            wait(clkOut);
            
            // checks data 5ps after clock edge for defined behavior
            for (i = 0; i < 24; i++) begin
                #5ps assert(dOut == rgb[23 - i]) 
                    else $display("time = %0t expected = %b recieved = %b", $time, rgb[23 - i], dOut);
                @(posedge clk);    
            end
        end
    endtask

    initial begin
        $timeformat(-9, 2, " ns", 20);  // formats to ns
        
        rst <= '1; repeat(5) @(posedge clk);
        rst <= '0;

        loadColor(24'h800000);
        loadColor(24'hffffff);
        loadColor(24'h555555);
        loadColor(24'h000001);
    
        $display("If no assertions errors appeared the simulation was a success");

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