// Outputs high for 1 clock cycle on the rising edge of the input signal, regardless of how long it stays high.
module PulseExtract
(
    output logic pulse,
    input logic signal,
    input logic clk, rst
);
    logic Last;
    
    always_ff @(posedge clk)
        if(rst) Last <= '0;
        else Last <= signal;

    assign pulse = (~Last && signal);
endmodule