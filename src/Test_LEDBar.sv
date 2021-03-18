/*  
*   Contains code used to test that the output of the LEDDriver and anything behind it 
*/

module LEDBar_testbench;

    parameter LEDS = 50;

    // ========================  LEDModel Testing =====================
    // clock and data signals between individual WS2801s. For LED[i], SDIO[i] is the input and SDIO[i+1] is the output
    logic [LEDS:0] SDIO, CKIO;

    logic [LEDS-1:0][23:0] FrameColorContent;
    logic [LEDS-1:0][23:0] FrameColorContentExpected;

    // TODO: Make sure this genvar is not in use is not already in use,
    // if the "automatic" statement works you may not need to change loop iteration variable
    genvar i;

    // since the checkLEDs task is automatic it is okay if j is used elsewhere
    integer j;

    generate
        for ( i = 0; i < LEDS; i++) begin : LEDBar
            LEDModel led (.rgb(FrameColorContent[i]), .SDO(SDIO[i+1]), .CKO(CKIO[i+1]), .SDI(SDIO[i]), .CKI(CKIO[i]));
        end
    endgenerate

    
    // Note: surround with a fork join statement to stop the wait statements from blocking
    task automatic checkLEDs(logic [LEDS-1:0][23:0] ColorContent);
        begin
            FrameColorContentExpected = ColorContent;

            wait(CKIO[0]);
            // TODO: replace with a signal that suggests that the values have been registered (500us after transmisison finished)
            wait(done);
            wait(!done);

            for (j = 0; j < LEDS; j++) begin
                assert(FrameColorContent[j] == FrameColorContentExpected[j]) $display("LED %d at time %d is correct", j, $time);
                    else $display("LED %d at time %d is INCORRECT ; Expected = %6h, Recieved = %6h", j, $time, FrameColorContentExpected[j], FrameColorContent[j]);
            end
        end
    endtask
endmodule