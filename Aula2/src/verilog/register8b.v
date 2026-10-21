`timescale 1ns/1ns
/*
Structural model of a 8-bit register
*/

module register8b(  input  [7:0] d,     // D input
                    input        clock, // clock
			     input        reset, // reset, synchronous with te clock
				input        enable,
			     output [7:0] q      // Q output
			  );

// instantiate 8 D-type flip-flops:
ffd  dff0(.d( d[0] ), .clock( clock ), .reset( reset ), .enable( enable ), .q( q[0] ) ),
     dff1(.d( d[1] ), .clock( clock ), .reset( reset ), .enable( enable ), .q( q[1] ) ),
     dff2(.d( d[2] ), .clock( clock ), .reset( reset ), .enable( enable ), .q( q[2] ) ),
     dff3(.d( d[3] ), .clock( clock ), .reset( reset ), .enable( enable ), .q( q[3] ) ),
     dff4(.d( d[4] ), .clock( clock ), .reset( reset ), .enable( enable ), .q( q[4] ) ),
     dff5(.d( d[5] ), .clock( clock ), .reset( reset ), .enable( enable ), .q( q[5] ) ),
     dff6(.d( d[6] ), .clock( clock ), .reset( reset ), .enable( enable ), .q( q[6] ) ),
     dff7(.d( d[7] ), .clock( clock ), .reset( reset ), .enable( enable ), .q( q[7] ) );

endmodule
