`timescale 1ns/1ns
/*
Structural model of an 8-bit up/down counter with parallel load and max wrap
*/

module updowncounter8b_loadmax(
                   input        upb_down,// 0 ("b" == "bar") for counting up, 1 for counting down
                                clock,   // clock
			                    reset,   // reset (synchronous in ffd)
				                enable,  // enable
				   input  [7:0] step_count,     // the value to increment/decrement
			       output [7:0] counter_output, // the counter output

				   // additional inputs:
				   input load,					// set to 1 to load the counter register with data
				                                // at the input din_load[7:0]
                   input [7:0] din_load,        // data input to load to the counter register when load is 1
				   input [7:0] max_count        // maximum counting value: counter should not exceed this value
			  );

wire [7:0] next_count;
wire [7:0] add_result;
wire [7:0] count_next;
wire [7:0] wrap_val;
wire       add_cout;
wire       greater_than_max;
wire       less_than_zero;
wire       wrap;

//------------------------------------------------------
// Instantiate one 8-bit register:
register8b  register8b_1(
                   .d( next_count ),
                   .clock( clock ),
			       .reset( reset ),
				   .enable( enable ),
			       .q( counter_output )
				   );

//------------------------------------------------------
// 8-bit adder/subtractor with two 4-bit adders:
wire [7:0] bneg;

assign bneg[0] = step_count[0] ^ upb_down;
assign bneg[1] = step_count[1] ^ upb_down;
assign bneg[2] = step_count[2] ^ upb_down;
assign bneg[3] = step_count[3] ^ upb_down;
assign bneg[4] = step_count[4] ^ upb_down;
assign bneg[5] = step_count[5] ^ upb_down;
assign bneg[6] = step_count[6] ^ upb_down;
assign bneg[7] = step_count[7] ^ upb_down;

wire cout34;
four_bit_adder  four_bit_add_low
                    ( .cin( upb_down ),
                      .a( counter_output[3:0] ),
                      .b( bneg[3:0] ),
					  .sum( add_result[3:0] ),
					  .cout( cout34 )
					 ),

				four_bit_add_high
                    ( .cin( cout34 ),
                      .a( counter_output[7:4] ),
                      .b( bneg[7:4] ),
					  .sum( add_result[7:4] ),
					  .cout( add_cout )
					 );

assign greater_than_max = ({add_cout, add_result} > {1'b0, max_count});
assign less_than_zero   = (counter_output < step_count);
assign wrap             = (~upb_down & greater_than_max) | (upb_down & less_than_zero);
assign wrap_val         = upb_down ? max_count : 8'd0;
assign count_next       = wrap ? wrap_val : add_result;

// load=1 -> din_load; load=0 -> wrapped add/sub result
mux2_8bit myMux (	.din_load(din_load),
					.din_max(count_next),
					.load(load),
					.mux_out(next_count));

endmodule
