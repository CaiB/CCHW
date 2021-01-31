module SinTables
(
    output logic signed [15:0] value,
    input logic [4:0] bin,
    input logic enableIncr,
    input logic clk, rst
);
    logic signed [15:0] sinValues [0:(64*24)];
    logic [5:0] position;

    initial
    begin
        $readmemh("../other/sintable.txt", sinValues);
    end

    always_ff @(posedge clk)
    begin
        if(rst) position <= 0;
        else if(enableIncr) position++;
    end

    always_comb
    begin
        value = sinValues[{bin, position}];
    end
endmodule

module CosTables
(
    output logic signed [15:0] value,
    input logic [4:0] bin,
    input logic enableIncr,
    input logic clk, rst
);
    logic signed [15:0] cosValues [0:(64*24)];
    logic [5:0] position;

    initial
    begin
        $readmemh("../other/costable.txt", cosValues);
    end

    always_ff @(posedge clk)
    begin
        if(rst) position <= 0;
        else if(enableIncr) position++;
    end

    always_comb
    begin
        value = cosValues[{bin, position}];
    end
endmodule