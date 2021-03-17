/*  The ColorCalc transforms the hue and its amplitude into a color with both pieces of information embedded within it
*   It takes a total of 3 cycles to compute, the cycles together form a sequential computation
*       cycle 0 - quantize the hue to sixths and split into whole and decimal parts
                - choose which amplitude to use and apply final amplificaiton and limits
*       cycle 1 - compute the reduced values for the weaker components of each color
*       cycle 2 - combine the components into a single color
*
*   The hue computation is difficult to comprehend - the analogous sequential c# code is located at:
*    https://github.com/CaiB/ColorChord.NET/blob/master/ColorChord.NET/Visualizers/VisualizerTools.cs
*    and is contained partly in the HsvToRgb function
*/

module ColorCalc #(
    parameter W = 5,                        // number of whole bits in the fixed point format
    parameter D = 11,                       // number of decimal  bits in the fixed point format - precision to ~.001  - !!! D must be at least 8 !!!

    // =============== Fixed Point Specific Parameters ===============
    // The following parameters are computed based on the above parameters W and D. 
    // See LinearVisualizer.sv : line 24 for instruction on how to recompute
    parameter SaturationAmplifier = 1638,   // 1.6000.. ~ 3277 ~ 1_10011001101 - scales the hue amplitude up to the LEDLimit
    parameter quantizeToSix = 12,           // 0.0.005859375 (~1/170.5) ~ 12 ~ 00000001100 - quantizes the result to be between 0 and 6
    parameter LEDLimit = 2047,              // ~1.0 ~ 2047 ~ 11111111111 - sets the final hue amplitude upper limit 
    parameter steadyBright = 'b0            // (0) use the original amplitudes if they are greater than threshold, 0 otherwise
                                            // (1) use amplitude - threshold value if it is greater than 0, 0 otherwise
) (
    output logic [23:0] rgb,                // array of unique color words
    output logic data_v,                    // set when the computation is complete

    input logic [W + D - 1 : 0] noteAmplitude_i,        // original LV amplitudes but reduced and filtered
    input logic [W + D - 1 : 0] noteAmplitudeFast_i,    // original LV amplitudes but filtered
    input logic [D - 2 : 0] noteHue_i,                  // the hue of the note mapped to a value between 0 and 1023
    input logic start, clk, rst                         // system clock and reset
);

    // propogates the start signal so that the done signal goes high after 3 cycles
    logic [2:0] valid_delay;

    // =============== cycle 0 outputs and registers ===============
    logic unsigned [D + D - 1 : 0] hueDivided;
    logic unsigned [D - 1 : 0] hueWhole, hueWhole_d1, hueWhole_d2;
    logic unsigned [D - 1 : 0] hueDec, hueDec_d1;

    // =============== cycle 1 outputs and registers ===============
    logic unsigned [W + D - 1 : 0] noteAmplitude;
    logic unsigned [W + D - 1 + (1 + D): 0] noteAmplitudeMult;    // multiplied by 11 bit param SaturationAmplifier (1 whole 10 dec)
    logic unsigned [D - 1 : 0] noteAmplitudeDec;
    logic unsigned [D - 1 : 0] noteAmplitudeLimited, noteAmplitudeLimited_d1, noteAmplitudeLimited_d2;

    // =============== cycle 2 outputs and registers ===============
    logic unsigned [D + D - 1 : 0] colorValueXHue, colorValueXHuex;
    logic unsigned [7 : 0] colorValueMax;
    logic unsigned [7 : 0] colorValueXHue_d1, colorValueXHuex_d1;

    always_comb begin
        // cycle 0: devide the hue into sixths and choose the final/used amplitude

            // divide hue by 1023/6, choose which amplitude, multiply and mux
        hueDivided = noteHue_i * quantizeToSix;
        hueWhole = hueDivided[D + D - 1 : D];       // the whole number component
        hueDec = hueDivided[D - 1 : 0];             // the decimal number component

            // find the final amplitude value
        noteAmplitude = steadyBright ? noteAmplitude_i : noteAmplitudeFast_i;   // choose which of the two amplitudes to use
        noteAmplitudeMult = noteAmplitude * SaturationAmplifier;                // scale with the amplifier parameter

            // apply the upper limits of the amplitude
                // sets the upper limit of note amplitude to the maximum D bit decimal value
        noteAmplitudeDec = (noteAmplitudeMult[W + D - 1 + (1 + D) : D + D] == 0) ?  noteAmplitudeMult[D + D - 1 : D] : '1;

                // sets the upper limit of note amplitude to the D bit LEDLimit value
        noteAmplitudeLimited = (noteAmplitudeDec > LEDLimit) ? LEDLimit : noteAmplitudeDec; 

        // cycle 1:
            // multiply out the reduced value components of the color
            // noteAmplitudeLimited = max
            // XHue = max * decimal part of the hue
            // XHuex = max * (1 - decimal part of the hue)
        colorValueXHue  = noteAmplitudeLimited_d1 *  hueDec_d1;  // amp * hueDec
        colorValueXHuex = noteAmplitudeLimited_d1 * ((2**D - 1) - hueDec_d1);  // amp * (1 - hueDec)

        // cycle 2:
            // choose result in range 0-255
            // note: since the maximum value of the color is less than one (max = D'b1) we can just use the top 8 bits
            //       for the color value of each of rgb
            // these configurations are based on the c# code defined in the file described in the header
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

        // apply a check to ensure that a 0 amplitude note doesn't produce any color at all
        rgb = noteAmplitudeLimited_d2 == 0 ? '0 : rgb;

        // data_v logic
        data_v = valid_delay[2];

    end

    always_ff @(posedge clk) begin
        if (rst) begin
            valid_delay <= '0;
        end
        else begin
            // register stage outputs
            hueWhole_d1 <= hueWhole;
            hueWhole_d2 <= hueWhole_d1;
            hueDec_d1 <= hueDec;
            noteAmplitudeLimited_d1 <= noteAmplitudeLimited; 
            noteAmplitudeLimited_d2 <= noteAmplitudeLimited_d1;

            // take the top 8 bits to represent each of R G and B
            colorValueMax <= noteAmplitudeLimited_d1[D - 1 : D - 8]; 
            colorValueXHue_d1  <= colorValueXHue [D + D - 1 : D + D - 8];
            colorValueXHuex_d1 <= colorValueXHuex[D + D - 1 : D + D - 8];

            valid_delay <= {valid_delay[1:0], start};
        end
    end

endmodule