`timescale 1 ps / 1 ps
module Test_FullSystem;
    logic unsigned [11:0] peaksForDebug;
    logic signed [15:0] inputSample;
    logic sampleReady, doingRead, ledClock, ledData;
    logic clk, rst;

    ColorChordTop DUT(.peaksForDebug, .doingRead, .ledClock, .ledData, .inputSample, .minThreshold('0), .sampleReady, .clk, .rst);

    parameter LEN = 9000;
    logic signed [15:0] InputData [0:LEN-1];
    initial $readmemh("../other/dfttestdata.txt", InputData);

    real OutNotesR [0:11];

    genvar i;
    generate
        for(i = 0; i < 12; i++)
        begin
            assign OutNotesR[i] = DUT.notes[i].valid ? (DUT.notes[i].position * (2.0 ** -11)) : 0.0;
        end
    endgenerate

    initial
    begin
        clk <= '1;
        forever #40ns clk <= ~clk;
    end

    task Reset;
        inputSample = '0;
        sampleReady = '0;
        rst = '1;
        repeat(5) @(posedge clk);
        rst = '0; @(posedge clk);
    endtask

    task InsertData(int samples);
        for(int i = 0; i < samples; i++)
        begin
            sampleReady = '1;
            inputSample = InputData[i];
            @(posedge clk);
            sampleReady = '0;
            repeat(250) @(posedge clk);
            if(i < 20 || i % 10 == 0) $display("Sample %4d finished", i);
        end
    endtask

    
    // ========================  LEDModel Testing =====================
    parameter LEDS = 50;

    // clock and data signals between individual WS2801s. For LED[i], SDIO[i] is the input and SDIO[i+1] is the output
    logic [LEDS:0] SDIO, CKIO;

    logic [LEDS-1:0][23:0] FrameColorContent;
    logic [LEDS-1:0][23:0] FrameColorContentExpected;

    assign SDIO[0] = ledData;
    assign CKIO[0] = ledClock;

    // TODO: Make sure this genvar is not in use is not already in use,
    // if the "automatic" statement works you may not need to change loop iteration variable
    genvar z;

    // since the checkLEDs task is automatic it is okay if j is used elsewhere
    integer j;

    generate
        for ( z = 0; z < LEDS; z++) begin : LEDs
            LEDModel led (.rgb(FrameColorContent[z]), .SDO(SDIO[z+1]), .CKO(CKIO[z+1]), .SDI(SDIO[z]), .CKI(CKIO[z]));
        end
    endgenerate

    
    // Note: surround with a fork join statement to stop the wait statements from blocking
    task automatic checkLEDs(logic [LEDS-1:0][23:0] ColorContent);
        begin
            FrameColorContentExpected = ColorContent;

            wait(CKIO[0]);
            // TODO: replace with a signal that suggests that the values have been registered (500us after transmisison finished)
            wait(DUT.OutDriver.done);
            wait(!DUT.OutDriver.done);

            for (j = 0; j < LEDS; j++) begin
                assert(FrameColorContent[j] == FrameColorContentExpected[j]) $display("LED %d at time %d is CORRECT; Expected = %6h, Recieved = %6h", j, $time, FrameColorContentExpected[j], FrameColorContent[j]);
                    else $display("LED %d at time %d is INCORRECT ; Expected = %6h, Recieved = %6h", j, $time, FrameColorContentExpected[j], FrameColorContent[j]);
            end
        end
    endtask

    // ==================================================================

    initial
    begin
        Reset();
        InsertData(LEN);
        checkLEDs({{29{24'hffdf00}},{20{24'h3700ff}},24'b0});
        
        $stop;
    end
endmodule