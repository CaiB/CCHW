// Input synchronizer to avoid metastability caused by asynchronous inputs.
// Composed of 2 DFFs in series.
module Synchronizer
(
    output logic out,
    input logic in,
    input logic clk, rst
);
    logic [1:0] FFs;

    always_ff @(posedge clk)
    begin
        if(rst) FFs <= '0;
        else
        begin
            FFs[1] <= FFs[0];
            FFs[0] <= in;
        end
    end

    assign out = FFs[1];
endmodule



module Synchronizer_Test();
    logic out, in, clk, rst;

    Synchronizer DUT(.out, .in, .clk, .rst);

    parameter Delay = 20;

	initial // Clock
	begin
		clk <= 0;
		forever #(Delay / 2) clk <= ~clk;
	end

    initial
    begin
        in <= '0; @(posedge clk);
        rst <= '1; @(posedge clk);
        rst <= '0; @(posedge clk); #(Delay / 4)
        assert(out == '0);

        in <= '1; @(negedge clk); in <= '0; // too short
        @(posedge clk); #(Delay / 4)
        assert(out == '0);
        @(posedge clk); #(Delay / 4)
        assert(out == '0);

        in <= '1; @(posedge clk); #(Delay / 4)
        in <= '0; // long enough (1 cyc)
        assert(out == '0);
        @(posedge clk); #(Delay / 4)
        assert(out == '1);
        @(posedge clk); #(Delay / 4)
        assert(out == '0);

        in <= '1; @(posedge clk); #(Delay / 4) // long enough (3 cyc)
        assert(out == '0);
        @(posedge clk); #(Delay / 4)
        assert(out == '1);
        @(posedge clk); #(Delay / 4)
        assert(out == '1);
        in <= '0;
        @(posedge clk); #(Delay / 4)
        assert(out == '1);
        @(posedge clk); #(Delay / 4)
        assert(out == '0);
        $stop;
    end
endmodule