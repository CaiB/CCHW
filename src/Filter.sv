// Simple IIR Filter
// N is in/out width, NI is internal width
// IIRCONST is filter strength
module FilterIIR
#(parameter N = 16, parameter NI = N, parameter IIRCONST = 6)
(
    output logic signed [N-1:0] out,
    input logic signed [N-1:0] in,
    input logic write,
    input logic clk, rst
);
    logic signed [NI-1:0] diff, adjusted;
    logic signed [N-1:0] NewOut;

    assign diff = in - out;
    assign adjusted = diff >>> IIRCONST;
    assign NewOut = adjusted + out;

    always_ff @(posedge clk, posedge rst)
        if(rst) out <= '0;
        else if(write) out <= NewOut;
endmodule

// Takes more device resources but makes testing filter values much faster.
module FilterIIRAdjustable
#(parameter N = 16, parameter NI = N)
(
    output logic signed [N-1:0] out,
    input logic signed [N-1:0] in,
    input logic [4:0] iirConst,
    input logic write,
    input logic clk, rst
);
    logic signed [NI-1:0] diff, adjusted;
    logic signed [N-1:0] NewOut;

    assign diff = in - out;
    assign adjusted = diff >>> iirConst;
    assign NewOut = adjusted + out;

    always_ff @(posedge clk, posedge rst)
        if(rst) out <= '0;
        else if(write) out <= NewOut;
endmodule