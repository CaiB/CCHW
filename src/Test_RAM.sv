`define RAM_FPGA
//`define RAM_FPGA

`timescale 1 ps / 1 ps
module Test_RAM;
    localparam W_ADDR = 13;
    localparam W_DATA = 16;

    logic [W_ADDR-1:0] Address;
    logic [W_DATA-1:0] DataOut, DataIn;
    logic DoWrite;
    logic clk, rst;

`ifdef RAM_ASIC
    RAM_16B_8192_AR4_LP DUT(.Q(DataOut), .CLK(clk), .CEN('0), .WEN(~DoWrite), .A(Address), .D(DataIn), .EMA('0), .EMAW('0), .EMAS('0), .RET1N('1));
`elsif RAM_FPGA
    RAM_8192 DUT(.address(Address), .clock(clk), .data(DataIn), .wren(DoWrite), .q(DataOut));
`else
    initial $display("ERROR: MEMORY TYPE NOT SELECTED VIA DEFINE!");
`endif

    initial
    begin
        clk <= '1;
        forever #50 clk <= ~clk;
    end

    task Reset;
        Address = '0;
        DataIn = '0;
        DoWrite = '0;
        rst = '1;
        repeat(5) @(posedge clk);
        rst = '0; @(posedge clk);
    endtask

    task Read(logic [W_ADDR-1:0] addr);
        #20;
        DoWrite = '0;
        Address = addr;
        DataIn = 16'h1A1A;
        @(posedge clk);
    endtask

    task Write(logic [W_ADDR-1:0] addr, logic [W_DATA-1:0] data);
        #20;
        DoWrite = '1;
        Address = addr;
        DataIn = data;
        @(posedge clk);
    endtask

    initial
    begin
        Reset();
        Read(10);
        Write(11, 16'h8114);
        Write(12, 16'h2677);
        Read(12);
        Read(11);
        Read(12);
        Read(10);
        Read(10);
        $stop;
    end
endmodule