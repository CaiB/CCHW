// Simple IIR Filter
// N is in/out width, NI is internal width
// IIRCONST is filter strength
module FilterIIR
#(parameter N = 16, parameter NI = N, parameter IIRCONST = 6)
(
    output logic signed [N-1:0] out,
    input logic signed [N-1:0] in,
    input logic clk, rst
);
    logic signed [NI-1:0] diff, adjusted;
    logic signed [N-1:0] NewOut;

    assign diff = in - out;
    assign adjusted = diff >>> IIRCONST;
    assign NewOut = adjusted + out;

    always_ff @(posedge clk)
        if(rst) out <= '0;
        else out <= NewOut;
endmodule


module Test_FilterIIR;
    localparam N = 16;
    localparam CONST = 6;
    logic signed [N-1:0] out, in;
    logic clk, rst;

    // TODO Test filter
endmodule