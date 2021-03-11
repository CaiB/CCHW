module ColorCalc #(
    parameter W = 6,
    parameter D = 10,                       // !!! D must be at least 8 !!!
    parameter SaturationAmplifier = 1638,   // 1.599.. ~ 1638 ~ 1_1111000000
    parameter quantizeToSix = 'b0000000110, // 0.005859375 (~1/170.5) ~ 6 ~ 0000000110
    parameter LEDLimit = 1023,              // ~1.0 ~ 1023 ~ 1111111111

    parameter steadyBright = 'b0 
) (
    output logic [23:0] rgb,
    output logic data_v,

    input logic [W + D - 1 : 0] noteAmplitude_i,
    input logic [W + D - 1 : 0] noteAmplitudeFast_i,
    input logic [D - 1 : 0] noteHue_i,
    input logic start, clk, rst
);

    logic [2:0] valid_delay;

    logic unsigned [D + D - 1 : 0] hueDivided;
    logic unsigned [D - 1 : 0] hueWhole, hueWhole_d1, hueWhole_d2;
    logic unsigned [D - 1 : 0] hueDec, hueDec_d1;
    logic unsigned [W + D - 1 : 0] noteAmplitude;
    logic unsigned [W + D - 1 + (1 + D): 0] noteAmplitudeMult;    // multiplied by 11 bit param SaturationAmplifier (1 whole 10 dec)
    logic unsigned [D - 1 : 0] noteAmplitudeDec;
    logic unsigned [D - 1 : 0] noteAmplitudeLimited, noteAmplitudeLimited_d1, noteAmplitudeLimited_d2;

    logic unsigned [D + D - 1 : 0] colorValueXHue, colorValueXHuex;
    logic unsigned [7 : 0] colorValueMax;
    logic unsigned [7 : 0] colorValueXHue_d1, colorValueXHuex_d1;

    always_comb begin
        // cycle 1:
            // divide hue by 1023/6, choose which amplitude, multiply and mux4
        hueDivided = noteHue_i * quantizeToSix;
        hueWhole = hueDivided[D + D - 1 : D];
        hueDec = hueDivided[D - 1 : 0];

            // find the final amplitude value
        noteAmplitude = steadyBright ? noteAmplitude_i : noteAmplitudeFast_i;
        noteAmplitudeMult = noteAmplitude * SaturationAmplifier;

            // sets the upper limit of note amplitude to the maximum D bit decimal value
        noteAmplitudeDec = (noteAmplitudeMult[W + D - 1 + (1 + D) : D + D] == 0) ?  noteAmplitudeMult[D + D - 1 : D] : '1;

            // sets the upper limit of note amplitude to the D bit LEDLimit value
        noteAmplitudeLimited = (noteAmplitudeDec > LEDLimit) ? LEDLimit : noteAmplitudeDec; 

        // cycle 2:
            // multiply out vf and (~v)f
        colorValueXHue  = noteAmplitudeLimited_d1 *  hueDec_d1;  // amp * hueDec
        //colorValueXHuex = noteAmplitudeLimited_d1 * ~hueDec_d1;  // amp * (1 - hueDec)
        colorValueXHuex = noteAmplitudeLimited_d1 * ((2**D - 1) - hueDec_d1);  // amp * (1 - hueDec)

        // cycle 3:
            // choose result in range 0-255
            // note: since the maximum value of the color is less than one (max = D'b1) we can just use the top 8 bits
            //       for the color value of each of rgb
        case(hueWhole_d2)
            0 : rgb = colorValueMax      << 16 | colorValueXHue_d1 << 8;
            1 : rgb = colorValueXHuex_d1 << 16 | colorValueMax     << 8;
            2 : rgb = colorValueMax      <<  8 | colorValueXHue_d1;
            3 : rgb = colorValueXHuex_d1 <<  8 | colorValueMax;
            4 : rgb = colorValueXHue_d1  << 16 | colorValueMax;
            5 : rgb = colorValueMax      << 16 | colorValueXHuex_d1;
            6 : rgb = colorValueMax      << 16 | colorValueXHue_d1 << 8;
            
            default: rgb = {'0};
        endcase

        rgb = noteAmplitudeLimited_d2 == 0 ? '0 : rgb;

        // data_v logic
        data_v = valid_delay[2];

    end

    always_ff @(posedge clk) begin
        if (rst) begin
            valid_delay <= '0;
        end
        else begin
            hueWhole_d1 <= hueWhole;
            hueWhole_d2 <= hueWhole_d1;
            hueDec_d1 <= hueDec;
            noteAmplitudeLimited_d1 <= noteAmplitudeLimited; 
            noteAmplitudeLimited_d2 <= noteAmplitudeLimited_d1;

            // take the top 8 bits
            colorValueMax <= noteAmplitudeLimited_d1[D - 1 : D - 8]; 
            colorValueXHue_d1  <= colorValueXHue [D + D - 1 : D + D - 8];
            colorValueXHuex_d1 <= colorValueXHuex[D + D - 1 : D + D - 8];

            valid_delay = {valid_delay[1:0], start};
        end
    end

endmodule

module ColorCalc_testbench();

    parameter W = 6;
    parameter D = 10;
    
    parameter TB_PERIOD = 100ns;

    logic [23:0] rgb;
    logic data_v;
    logic [W + D - 1 : 0] noteAmplitude_i;
    logic [W + D - 1 : 0] noteAmplitudeFast_i;
    logic [D - 1 : 0] noteHue_i;
    logic start, clk, rst;

    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    ColorCalc #(
        .W(W),
        .D(D),
        .SaturationAmplifier(1638),
        .quantizeToSix('b0000000110),
        .LEDLimit(1023),
        .steadyBright('0)
    ) dut (
        .rgb                (rgb                ),
        .data_v             (data_v             ),
        .noteAmplitude_i    (noteAmplitude_i    ),
        .noteAmplitudeFast_i(noteAmplitudeFast_i),
        .noteHue_i          (noteHue_i          ),
        .start              (start              ),
        .clk                (clk                ),
        .rst                (rst                )
    );

    initial begin
        rst = 1; repeat(5) @(posedge clk);
        rst = 0;
        start = '1;

        noteAmplitude_i = 10'b0101100000;
        noteAmplitudeFast_i = 10'b1011111010;
        noteHue_i = 10'b1111010010;

        @(posedge clk);
        @(posedge clk);
        wait(data_v);

        noteAmplitude_i = 10'b1100011001;
        noteAmplitudeFast_i = 10'b0110101101;
        noteHue_i = 10'b0111110101;


        @(posedge clk);
        @(posedge clk);
        wait(data_v);

        noteAmplitude_i = 10'b1001111010;
        noteAmplitudeFast_i = 10'b0100001110;
        noteHue_i = 10'b0100000000;


        @(posedge clk);
        @(posedge clk);
        wait(data_v);
        
        $stop();
    end
endmodule