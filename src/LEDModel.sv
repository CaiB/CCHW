`timescale 1 ps / 1 ps

/* model implementation of the WS2801 3 Channel Constant Current LED Driver
** note: only relevant ports are included, color, power and polarity control are omitted 
** note: not used in synthesis but only simulation
** data comes in from red[7] to blue[0]
**/

module LEDModel (
    output logic [23:0] rgb,
    output logic SDO, CKO,
    input  logic SDI, CKI
);

    // ----------------------- Internal Hardware ------------------------

    // RGB with red[7] as msb and blue[0] as lsb
    typedef struct packed {
        logic [7:0] red;
        logic [7:0] green;
        logic [7:0] blue;    
    } rgbRegStruct;

    rgbRegStruct latchedReg, shiftReg;  // internal data registers
    logic [8:0]  latchCntr = 0;         // counts to 500 us before latching
    logic [4:0]  relayCntr = 0;         // counts to 24 before entering relay mode

    logic        relayMode;             // "state" bit
    logic        relayMode_d1;          // state bit delayed 1 cycle
    logic        osc;                   // internal oscillator

    // generate internal oscillaor
    initial  begin
        osc = '1;
        forever #500ns osc = ~osc;      // 1 MHz clock assumed
    end

    // ------------------------------------------------------------------

    // ----------------------- Behavioral Discription -------------------

    // oscillator counts up to 500 before latching shift register and restarting
    always_ff @(posedge osc) begin 
        if (latchCntr == 'd500) begin 
            latchedReg <= shiftReg;
            latchCntr  <= '0;
            relayCntr  <= '0;
        end
        else latchCntr <= latchCntr + 1;
    end

    // external clock resets latching timer and loads 24 bits before relaying forward
    always_ff @(posedge CKI) begin
        if (!relayMode) begin
            relayCntr  <= relayCntr + 1;
            shiftReg   <= {shiftReg[22:0], SDI};
        end
        
        relayMode_d1 <= relayMode;
        latchCntr <= '0;
    end

    // "forwards" the clock/data signal once all 24 register positions are filled
    assign relayMode = (relayCntr == 'd24);
    
    // relay outputs kick in a cycle after getting into relay mode
    assign CKO = relayMode&relayMode_d1 ? CKI : '0;
    assign SDO = relayMode&relayMode_d1 ? SDI : '0;
    assign rgb = latchedReg;

    // ------------------------------------------------------------------

endmodule