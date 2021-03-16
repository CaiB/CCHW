package CCHW;
    typedef struct packed
    {
        logic [15:0] position;
        logic [15:0] amplitude;
        logic valid;
    } Note;
endpackage