`timescale 1ns/1ns
/*
   4-bit adder-subtractor testbench
*/
module addsub_tb;

// Define registers to hold the data driving the inputs:
reg [3:0] A, B;
reg       addsub;

// Define wires connecting to the outputs:
wire [3:0] S;
wire       COUT;

// Instantiate the block to verify (or "test"):
four_bit_adder_sub DUV
             ( .addb_sub( addsub ), // 0 for addition, 1 for subtraction
			   .a( A ),
               .b( B ),
			   .sumsub( S ),
			   .cout( COUT )
			  );

// create a VCD file (value change data) with the transitions of
// all signals under module addsub_tb (the testbench):
initial
begin
  $dumpfile("addsub_simdata.vcd");
  $dumpvars(0, addsub_tb );
end

// Create "signed" wires and connect them to the A dn B inputs and the S output.
// In this example the signed attribute only makes difference in the way the system task $monitor()
// prints the values as signed decimal numbers.
wire signed [3:0] Asign, Bsign, Ssign;
assign Asign = A;
assign Bsign = B;
assign Ssign = S;

// 5-bit inputs to assign to inputs A and B:
reg [4:0] Ai, Bi;

initial
begin
  // Launch the process $monitor(): print a record whenever a signal changes:
  $monitor($time, "  add/sub=%1d: A=%2d, B=%2d, SUM=%2d, Cout=%1d  (signed: A=%2d, B=%2d, SUM=%2d )",
            addsub, A, B, S, COUT, Asign, Bsign, Ssign );

// Simulate a few initial cases (do a "smoke test": if something is VERY wrong a simple first test will fail):
  A = 0;  B = 0;  addsub = 0;
  #10 // wait 10 time units = 10 ns

  A = 4;  B = 3;  addsub = 0;
  #10 // wait 10 time units = 10 ns

  A = 4;  B = 3;  addsub = 1;
  #10 // wait 10 time units = 10 ns

  A = 1;  B = 5;  addsub = 1;
  #100 // wait 100 time units = 100 ns
  // $stop;

  // Now run an exaustive simulation for all the 512 input values:
  // Ai and Bi must be 5 bit long to break the loop when it reaches 16
  // Note that if Ai and Bi are only 4 bits long the loops will never end !

  addsub = 0; // Verify additions:
  for(Ai=0; Ai<16; Ai=Ai+1 )
  begin
	  for( Bi=0; Bi<16; Bi=Bi+1 )
	  begin
	    A = Ai[3:0];
		B = Bi[3:0];
	    #10
		if ( S != ( addsub ? (A - B) : (A + B) ) )
		  $display("ERROR ! add/sub=%1d: A=%2d, B=%2d, SUM=%2d, Cout=%1d\n",
             addsub, A, B, S, COUT );
	  end
  end

  addsub = 1; // Verify subtractions:
  for(Ai=0; Ai<16; Ai=Ai+1 )
  begin
	  for( Bi=0; Bi<16; Bi=Bi+1 )
	  begin
	    A = Ai[3:0];
		B = Bi[3:0];
	    #10
		if ( S != ( addsub ? (A - B) : (A + B) ) )
		  $display("ERROR ! add/sub=%1d: A=%2d, B=%2d, SUM=%2d, Cout=%1d\n",
             addsub, A, B, S, COUT );
	  end
  end

  #100
  $finish;
end

endmodule
