package CCHW;
    typedef struct packed
    {
        logic [15:0] position;
        logic [15:0] amplitude;
        logic valid;
    } Note;
endpackage

package CCHWTest;
    function logic [15:0] RealToFixed(input real in, input int fpf);
        static int Whole = (in >= 0 ? int'($floor(in)) : int'($ceil(in)));
        static real Fractional = in - real'(Whole);
        RealToFixed = (Whole << fpf) | (int'(Fractional * (1 << fpf)));
    endfunction

    function real FixedToReal(input logic [15:0] in, input int fpf);
        FixedToReal = (in * (2.0 ** -fpf));
    endfunction
endpackage