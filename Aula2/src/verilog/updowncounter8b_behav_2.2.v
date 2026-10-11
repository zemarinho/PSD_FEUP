`timescale 1ns/1ns
/*
Behavioral model of a 8-bit up/dounw counter with enable and parallel load
*/

module updowncounter8b( 
                   input  upb_down,// 0 ("b" == "bar") for counting up, 1 for counting dopwn
                   input  clock,   // clock
			       input  reset,   // reset, assynchronous
				   input  enable,  // enable
				   input  load,    // set to 1 to load counter with data at din_load[7:0]
				   input  [7:0] din_load,       // the value to load to counter when load==1
				   input  [7:0] max_count,      // the maximum value to count, return to zero if counting up
				                                // if counting down return to max_count when reaching zero
				   input  [7:0] step_count,     // the value to increment/decrement
			       output [7:0] counter_output  // the counter output
			  );
			  
// INternal 8-bit register:
reg [7:0] counter;		
	  
// The comparator with max_count for counting up (9-bit so 8-bit wrap is not missed):
wire   greater_than_max;
assign greater_than_max = ( {1'b0, counter} + step_count ) > {1'b0, max_count};

// Unsigned underflow when counting down:
wire   less_than_zero;
assign less_than_zero = ( counter < step_count );
			  

always @(posedge clock or posedge reset)
begin
  if ( reset )
    counter <= 8'd0;
  else
    if ( enable )   // Enable must be ative to change the counter state
	begin
	  if ( load )
	    counter <= din_load;
	  else
	    if ( ~upb_down )
		begin
		  if ( greater_than_max )
		    counter <= 8'd0;
		  else
	        counter <= counter + step_count;
		end
	    else
		begin
		  if ( less_than_zero )
		    counter <= max_count;
		  else
	        counter <= counter - step_count;
		end
	end
end


// Connect the register to the module output:
assign counter_output = counter;
				   
endmodule	