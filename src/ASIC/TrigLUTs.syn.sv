module SinTables_N16_BINS24_NS6
(
    output logic signed [15:0] value,
    input logic unsigned [4:0] bin,
    input logic unsigned [5:0] position
);
    logic signed [15:0] SinValues [0:1535];
    initial $readmemh("../other/sintable.txt", SinValues);
    assign value = SinValues[{bin, position}];
endmodule

module CosTables_N16_BINS24_NS6
(
    output logic signed [15:0] value,
    input logic unsigned [4:0] bin,
    input logic unsigned [5:0] position
);
    logic signed [15:0] CosValues [0:1535];
    initial $readmemh("../other/costable.txt", CosValues);
    assign value = CosValues[{bin, position}];
endmodule