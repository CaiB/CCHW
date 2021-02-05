/* model implementation of the WS2801 3 Channel Constant Current LED Driver
** note: only relevant ports are included, color, power and polarity control are omitted 
** note: not used in synthesis but only simulation
** data comes in from red[7] to blue[0]
**/

module LEDModel (
    output logic [23:0] rgb,
    output logic SDO, CKO,
    input  logic SDI, CKI
);

    // ----------------------- Internal Hardware ------------------------

    // RGB with red[7] as msb and blue[0] as lsb
    typedef struct packed {
        logic [7:0] red;
        logic [7:0] green;
        logic [7:0] blue;    
    } rgbRegStruct;

    rgbRegStruct latchedReg, shiftReg;  // internal data registers
    logic [8:0]  latchCntr = 0;         // counts to 500 us before latching
    logic [4:0]  relayCntr = 0;         // counts to 24 before entering relay mode

    logic        relayMode;             // "state" bit
    logic        relayMode_d1;          // state bit delayed 1 cycle
    logic        osc;                   // internal oscillator

    // generate internal oscillaor
    initial  begin
        osc = '1;
        forever #500ns osc = ~osc;      // 1 MHz clock assumed
    end

    // ------------------------------------------------------------------

    // ----------------------- Behavioral Discription -------------------

    // oscillator counts up to 500 before latching shift register and restarting
    always_ff @(posedge osc) begin 
        if (latchCntr == 'd500) begin 
            latchedReg <= shiftReg;
            latchCntr  <= '0;
            relayCntr  <= '0;
        end
        else latchCntr <= latchCntr + 1;
    end

    // external clock resets latching timer and loads 24 bits before relaying forward
    always_ff @(posedge CKI) begin
        if (!relayMode) begin
            relayCntr  <= relayCntr + 1;
            shiftReg   <= {shiftReg[22:0], SDI};
        end
        
        relayMode_d1 <= relayMode;
        latchCntr <= '0;
    end

    // "forwards" the clock/data signal once all 24 register positions are filled
    assign relayMode = (relayCntr == 'd24);
    
    // relay outputs kick in a cycle after getting into relay mode
    assign CKO = relayMode&relayMode_d1 ? CKI : '0;
    assign SDO = relayMode&relayMode_d1 ? SDI : '0;
    assign rgb = latchedReg;

    // ------------------------------------------------------------------

endmodule

module LEDModel_testbench();
    logic [23:0] rgb;
    logic SDO, CKO;
    logic SDI, CKI;

    localparam period = 80ns; // assumes 12.5 MHz clock input
    integer i;

    LEDModel dut (.rgb, .SDO, .CKO, .SDI, .CKI);

    // wait 500 us for latch and checks latched value against expected
    task latch(input [23:0] expected); 
        begin
            CKI = 0;
            #501us;
            assert(rgb == expected) 
                $display("latched value at %t matches expected value of %h", $time, expected);
                else $display("latched value at %t DOES NOT match expected value of %h", $time, expected);
        end
    endtask

    // loads 24 bit rgb into a single LED register
    task loadColor6Hex(input [23:0] rgb) ;
        begin
            SDI = 0; CKI = 0;

            for (i = 23; i >= 0 ; i--) begin
                SDI = rgb[i];
                #(period/2);
                CKI = '1;
                #(period/2);
                CKI = '0;
            end
        end
    endtask


    // stim
    initial begin
        $timeformat(-9, 2, " ns", 20);  // formats to ns
        
        loadColor6Hex(24'hFFFFFF);
        loadColor6Hex(24'hF0F0F0);
        latch(24'hFFFFFF);

        loadColor6Hex(24'hF0F0F0);
        loadColor6Hex(24'hFFFFFF);
        latch(24'hF0F0F0);

        loadColor6Hex(24'hAAAAAA);
        loadColor6Hex(24'h555555);
        latch(24'hAAAAAA);
        latch(24'hAAAAAA);


        $stop();
    end

endmodule



module LEDStripModel_testbench();

    localparam LEDS =  5;               // number of leds being tested
    
    logic [LEDS-1:0][23:0] rgb;
    logic [LEDS:0] SDIO, CKIO;          // XXI and XXO mix and are instead called XXIO
    logic [LEDS-1:0][23:0] expected;    // debug data

    localparam period = 80ns;           // assumes 12.5 MHz clock input
    integer i,k;
    genvar j;

    // generates LEDS
    generate
        for (j = 0; j < LEDS; j++) begin
            LEDModel led (.rgb(rgb[j]), .SDO(SDIO[j+1]), .CKO(CKIO[j+1]), .SDI(SDIO[j]), .CKI(CKIO[j]));
        end
    endgenerate


    // wait 500 us for latch and check that latched value matches expectation
    task latch(input [LEDS-1:0][23:0] expected); 
        begin
            CKIO[0] = 0;
            #501us;
            assert(rgb == expected) 
                $display("latched value at %t matches expected value of %h", $time, expected);
                else $display("latched value at %t DOES NOT match expected value of %h", $time, expected);
        end
    endtask

    // loads 24 bit rgb into a singleLED register
    task loadColor6Hex(input [23:0] rgb);
        begin
            SDIO[0] = 0; CKIO[0] = 0;

            for (i = 23; i >= 0 ; i--) begin
                SDIO[0] = rgb[i];
                #(period/2);
                CKIO[0] = '1;
                #(period/2);
                CKIO[0] = '0;
            end
        end
    endtask

    // loads all LEDS with the same rgb data
    task loadAllRGBHex(input [23:0] rgb);
        begin
           for (k = 0; k < LEDS; k++) begin
               loadColor6Hex(rgb);
               expected[k] = rgb;
           end 
        end
    endtask


    // stim
    initial begin
        $timeformat(-9, 2, " ns", 20);  // formats to ns


        loadAllRGBHex(24'hFFFFFF);
        loadColor6Hex(24'hFFFFFF);
        latch(expected);

        loadAllRGBHex(24'hFFF000);
        loadColor6Hex(24'hFFF000);
        latch(expected);
        latch(expected);

        $stop();
    end

endmodule