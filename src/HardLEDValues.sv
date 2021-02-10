// testing module for the LEDDriver.sv. Meant to provide hardcoded color values to verify LEDDriver works

module HardLEDValues #(
    parameter LEDS = 50;        // number of LEDs being driven
    parameter COMPLEXITY = 0;   // how complex of an output do we want 
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
        if (COMPLEXITY = 0) begin
            led_rgb = {LEDS{24'hff0000}};   // set to red for basic test
        end

        // alternate between 8 solid colors
        else if (COMPLEXITY = 1) begin
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
                'd0: led_rgb = {(LEDS/2){24'h000000}, (1-(LEDS/2)){24'hffffff}};  // black, white
                'd1: led_rgb = {(LEDS/2){24'h0000ff}, (1-(LEDS/2)){24'h000000}};  // blue, black
                'd2: led_rgb = {(LEDS/2){24'h00ff00}, (1-(LEDS/2)){24'h0000ff}};  // green, blue
                'd3: led_rgb = {(LEDS/2){24'h00ffff}, (1-(LEDS/2)){24'h00ff00}};  // cyan, green
                'd4: led_rgb = {(LEDS/2){24'hff0000}, (1-(LEDS/2)){24'h00ffff}};  // red, cyan
                'd5: led_rgb = {(LEDS/2){24'hff00ff}, (1-(LEDS/2)){24'hff0000}};  // violet, red
                'd6: led_rgb = {(LEDS/2){24'hffff00}, (1-(LEDS/2)){24'hff00ff}};  // yelow, violet
                'd7: led_rgb = {(LEDS/2){24'hffffff}, (1-(LEDS/2)){24'hffff00}};  // white, yellow

                default: led_rgb = {LEDS{24'hff8e03}}; // orange
            endcase
        end
    end

    assign start = done;

endmodule

module HardLEDValues_testbench();
    logic [(24*LEDS)-1:0] led_rgb;
    logic start;
    logic done;
    logic rs;


    
endmodule