`timescale 1ns/1ns
/*
Behavioral model of single D-type flip-flop with reset and enable
*/

module ffd(    input d,       // D input
               input clock,   // clock, active on the positive edge
			   input reset,   // reset, synchronous with the clock
			   input enable,  // enable, active high
			   output reg q   // Q output
			  );

always @(posedge clock)
begin
  if ( reset )
    q <= 1'b0; // q "is loaded" with 0
  else
    if ( enable )
      q <= d;    // q is loaded with d, otherwise q keeps the current value
end

endmodule
