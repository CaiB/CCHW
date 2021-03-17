module Test_LEDModel;
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



module Test_LEDStripModel;

    localparam LEDS =  5;               // number of leds being tested
    
    logic [LEDS-1:0][23:0] rgb;
    logic [LEDS:0] SDIO, CKIO;          // XXI and XXO mix and are instead called XXIO
    logic [LEDS-1:0][23:0] expected;    // debug data

    localparam period = 80ns;           // assumes 12.5 MHz clock input
    integer i,k;
    genvar j;

    // generates LEDS
    generate
        for (j = 0; j < LEDS; j++) begin : LED_Strip
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