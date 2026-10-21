/*
Digital Systems Design

Lab exercise 2 - Design and verification of a sequential non-restoring divider

	This Verilog code is property of University of Porto
	Its utilization beyond the scope of the course Digital Systems Design
	(Projeto de Sistemas Digitais) of the Master in Electrical
	and Computer Engineering requires explicit authorization from the author.

	jca@fe.up.pt, 2017 - 2025

*/
`timescale 1ns / 1ns;

module psddivide_tb;

// general parameters
parameter CLOCK_PERIOD = 10;                // Clock period in ns
parameter MAX_SIM_TIME = 1_000_000_000;     // Set the maximum simulation time (time units=ns)

// Set to zero to just count errors
// Set to 1 to stop when the first error is found
parameter STOP_ON_ERROR     = 0;
parameter PRINT_ERRORS      = 1;
parameter PRINT_ALL_RESULTS = 0;

// Number of random divisions to simulate:
parameter NTESTS = 1_000_000;

// Counts numer of calls to execdiv( ):
integer Ndiv = 0;

// iteration variable for the for loop:
integer i;

// Counts number of errors:
integer nerrors = 0;


// Registers for driving the inputs:
reg  clock, reset;
reg  start, stop;
reg  [31:0] dividend, divisor;

// Wires to connect to the outputs:
wire [31:0] quotient, rest;


// Instantiate the module under verification:
// psddivide #( .INJECT_ERROR( 1 ) )
psddivide
       psddivide_1
      (
	    .clock(clock), // master clock, active in the positive edge
        .reset(reset), // master reset, synchronous and active high

        .start(start), // set to 1 during one clock cycle to start a division
        .stop(stop),   // set to 1 during one clock cycle to load the output registers

        .dividend(dividend),  // the operands
        .divisor(divisor),

        .quotient(quotient),  // the results
        .rest(rest)
        );


//---------------------------------------------------
// Setup initial signals
// generate 50% duty-cycle clock signal
initial
begin
  clock = 1'b0;
  reset = 1'b0;
  dividend = 32'd0;
  divisor  = 32'd0;
  start = 1'b0;
  stop  = 1'b0;
  Ndiv = 0;

  forever
    # (CLOCK_PERIOD / 2 ) clock = ~clock;
end

//---------------------------------------------------
// Apply the initial reset for 1.5 clock cycles:
initial
begin
  # 23 // wait 23 ns to misalign the reset pulse with the clock edges:
  reset = 1;
  # (2 * CLOCK_PERIOD ) // wait 2 clock periods
  reset = 0;
end

//---------------------------------------------------
// Set the maximum simulation time:
initial
begin
  # ( MAX_SIM_TIME )
  $stop;
end


//---------------------------------------------------
// Example of a simple verification program
reg [31:0] dividend_test,
           divisor_test;
initial
begin

  #( 10*CLOCK_PERIOD );

  // Example of calling task 'execdivide' (see below):
  execdivide( 123456, 789 );

  check_errors;

  // Start a division and pulse synchronous reset between clock edges.
  // The pulse must not interrupt the operation.
  // (NOTE: this code could be embedded in the task "execdivide")
  $display("---------------------------------------------");
  $display("Check that reset is synchronous");
  $display("Activate a short reset pulse during a division process");

  dividend = 123456;   // Apply operands
  divisor  = 789;

  @(negedge clock);   // wait for the next negative edge of the clock
  start = 1'b1;       // Assert start
  @(negedge clock );
  start = 1'b0;

  // Run for 10 clock cycles:
  repeat (10) @(posedge clock);  // Repeat 32 times: wait for the next positive edge of the clock

  // Activate a short reset pulse, not overlapping with the posedge of the clock
  #1
  reset = 1;
  #4
  reset = 0;

  // Continue for the remaining 22 iterations:
  repeat (22) @(posedge clock);


  @(negedge clock);
  stop = 1'b1;        // Assert stop

  @(negedge clock);
  stop = 1'b0;

  check_division_result(dividend, divisor);
  @(negedge clock);

  check_errors;

  $display("---------------------------------------------");
  $display("Run some special cases, including divide by zero:");
  // Additional tests
  execdivide( 1, 1 );
  execdivide( 0, 1 );
  execdivide( 1, 0 ); // A zero divisor produces an all-ones quotient and the dividend as remainder.
  execdivide( 32'hFFFF_FFFF, 1 );
  execdivide( 1, 32'hFFFF_FFFF );
  execdivide( 32'hFFFF_FFFF, 32'hFFFF_FFFF );

  check_errors;

  // Walking ones for the dividend and divisor:
  $display("---------------------------------------------");
  $display("Run 32 tests with walking ones in oposite directions:");
  divisor_test  = 32'h0000_0001;
  dividend_test = 32'h8000_0000;
  for(i=0; i<32; i=i+1)
  begin
    execdivide( dividend_test, divisor_test );
	repeat (1)
	  @(negedge clock);
	dividend_test = dividend_test >> 1;
	divisor_test  = divisor_test << 1;
  end

  check_errors;

  $display("---------------------------------------------");
  $display("Running %1d divisions with random operands:", NTESTS );
  for(i=0; i< NTESTS; i=i+1)
  begin
    execdivide( $urandom, $urandom );
	if ( i%10_000 == 0 && i != 0 )
	  $display("%1d done...", i);
  end

  check_errors;


  #( 10*CLOCK_PERIOD );

  $stop;
end


// Check unsigned division, defining division by zero as all-ones quotient
// with the dividend retained as the remainder.
task check_division_result;
input [31:0] divdn, divdr;
reg [31:0] expected_quotient, expected_rest;
begin
  if (divdr == 0) begin
    expected_quotient = 32'hFFFF_FFFF;
    expected_rest = divdn;
  end
  else begin
    expected_quotient = divdn / divdr;
    expected_rest = divdn % divdr;
  end

  if (quotient !== expected_quotient || rest !== expected_rest) begin
    nerrors = nerrors + 1;
    if (PRINT_ERRORS)
      $display("ERROR: %d/%d : quotient=%d, rest=%d (expected: %d %d)",
               divdn, divdr, quotient, rest, expected_quotient, expected_rest);
    if (STOP_ON_ERROR)
      $stop;
  end
end
endtask


// Execute a division:
task execdivide;
input [31:0] divdn, divdr;
begin
  dividend = divdn;   // Apply operands
  divisor = divdr;

  @(negedge clock);   // wait for the next negative edge of the clock
  start = 1'b1;       // Assert start

  @(negedge clock );
  start = 1'b0;

  repeat (32) @(posedge clock);  // Repeat 32 times: wait for the next positive edge of the clock

  @(negedge clock);
  stop = 1'b1;        // Assert stop

  @(negedge clock);
  stop = 1'b0;

  @(negedge clock);


  if ( PRINT_ALL_RESULTS )
    $display("[%5d]  %d / %d : quotient=%d,  rest=%d", Ndiv, dividend, divisor, quotient, rest );

  Ndiv = Ndiv + 1;


  check_division_result(dividend, divisor);


  end
endtask

// Print final verification result: pass or fail
task check_errors;
begin
  if ( nerrors == 0 )
    $display("PASS, no errors found\n");
  else
    $display("Errors found: (%d errors)\n", nerrors );
  nerrors = 0;
end
endtask

endmodule
