`timescale 1ns/1ns

// Generic 8-bit 2:1 mux. din_max is the non-load input (wrapped next count).
module mux2_8bit (  input wire [7:0] din_load,
                    input wire [7:0] din_max,
                    input load,
                    output wire [7:0] mux_out);

    assign mux_out = load ? din_load : din_max;

endmodule