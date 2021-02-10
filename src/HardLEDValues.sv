// testing module for the LEDDriver.sv. Meant to provide hardcoded color values to verify LEDDriver works

module HardLEDValues #(
    parameter LEDS = 50,        // number of LEDs being driven
    parameter COMPLEXITY = 0    // how complex of an output do we want 
)(
    output logic [(24*LEDS)-1:0] led_rgb,
    output logic start,

    input  logic done,
    input  logic rst
);

    // bits 10:0 count up ~2000 and bits 13:11 used for color output
    // note: 2000 is used because driver waits 500us between new loads and
    //       this is aimed at 1Hz color changes
    logic [13:0] counter;

    always_ff @(posedge done, posedge rst) begin
        counter <= rst ? '0 : counter + 1;
    end

    always_comb begin

        // set to a single solid color (red)
        if (COMPLEXITY == 0) begin
            led_rgb = {LEDS{24'hff0000}};   // set to red for basic test
        end

        // alternate between 8 solid colors
        else if (COMPLEXITY == 1) begin
            case(counter[13:11])
                'd0: led_rgb = {LEDS{24'h000000}};  // no light
                'd1: led_rgb = {LEDS{24'h0000ff}};  // blue
                'd2: led_rgb = {LEDS{24'h00ff00}};  // green
                'd3: led_rgb = {LEDS{24'h00ffff}};  // cyan
                'd4: led_rgb = {LEDS{24'hff0000}};  // red
                'd5: led_rgb = {LEDS{24'hff00ff}};  // violet
                'd6: led_rgb = {LEDS{24'hffff00}};  // yellow
                'd7: led_rgb = {LEDS{24'hffffff}};  // white

                default: led_rgb = {LEDS{24'hff8e03}}; // orange
            endcase
        end

        // alternate between equal splits of colors
        else begin
            case(counter[13:11])
                'd0: led_rgb = {{(LEDS/2){24'h000000}}, {(LEDS-(LEDS/2)){24'hffffff}}};  // black, white
                'd1: led_rgb = {{(LEDS/2){24'h0000ff}}, {(LEDS-(LEDS/2)){24'h000000}}};  // blue, black
                'd2: led_rgb = {{(LEDS/2){24'h00ff00}}, {(LEDS-(LEDS/2)){24'h0000ff}}};  // green, blue
                'd3: led_rgb = {{(LEDS/2){24'h00ffff}}, {(LEDS-(LEDS/2)){24'h00ff00}}};  // cyan, green
                'd4: led_rgb = {{(LEDS/2){24'hff0000}}, {(LEDS-(LEDS/2)){24'h00ffff}}};  // red, cyan
                'd5: led_rgb = {{(LEDS/2){24'hff00ff}}, {(LEDS-(LEDS/2)){24'hff0000}}};  // violet, red
                'd6: led_rgb = {{(LEDS/2){24'hffff00}}, {(LEDS-(LEDS/2)){24'hff00ff}}};  // yelow, violet
                'd7: led_rgb = {{(LEDS/2){24'hffffff}}, {(LEDS-(LEDS/2)){24'hffff00}}};  // white, yellow

                default: led_rgb = {LEDS{24'hff8e03}}; // orange
            endcase
        end
    end

    assign start = done;

endmodule

module HardLEDValues_testbench();
    parameter LEDS = 5;
    parameter COMPLEXITY = 1;

    logic [(24*LEDS)-1:0] led_rgb;
    logic start;
    logic done;
    logic rst;

    HardLEDValues #(.LEDS(LEDS), .COMPLEXITY(COMPLEXITY)) dut (.led_rgb, .start, .done, .rst);

    task toggle_done (input integer times);
        begin
            done = '0;
            repeat(times) begin
                done = ~done; #10ps; done = ~done; #10ps;
            end
        end
    endtask

    task driverCycle ();
        begin
            done = '1;
            #500us;
            done = '0;
            repeat(24*LEDS) #10ps;
        end
    endtask

    initial begin
        rst = '1; #1000ps; rst = '0;
        toggle_done(2**14);
        rst = '1; #1000ps; rst = '0;
        driverCycle();
    end

endmodule

module HardcodedDriver_testbench();
    localparam LEDS = 5;
    localparam FREQ = 12_500_000;
    localparam PERIOD =  80ps;
    localparam COMPLEXITY = 1;

    logic [(24*LEDS)-1:0] led_rgb;
    logic start;
    logic done;
    logic rst, clk;
    logic dOut, clkOut;

    // DUTs
    LEDDriver #(
        .LEDS(LEDS), 
        .FREQ(FREQ)
    ) dut_driver (
        .dOut    (dOut   ),
        .clkOut  (clkOut ),
        .done    (done   ),
        .led_rgb (led_rgb),
        .start   (start  ),
        .clk     (clk    ),
        .rst     (rst    )
    );

    HardLEDValues #(
        .LEDS(LEDS), 
        .COMPLEXITY(COMPLEXITY)
    ) dut_hardcoded (
        .led_rgb(led_rgb), 
        .start  (start  ), 
        .done   (done   ), 
        .rst    (rst    )
    );

        // clock setup
    initial begin
        clk = '0;
        forever #(PERIOD/2) clk = ~clk;
    end

    initial begin
        $timeformat(-6, 2, " us", 20);  // formats to us
        
        rst <= '1; repeat(5) @(posedge clk); rst <= '0; @(posedge clk);
        repeat(2**12) @(posedge done);
        $stop;
    end

endmodule