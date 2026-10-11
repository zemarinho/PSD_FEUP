`timescale 1ns/1ns
/*
   up/down counter with load and max wrap — testbench
*/
module updowncounter_loadmax_tb;

reg [7:0] stepcount;
reg       up0_down1;
reg       reset;
reg       clock;
reg       enable;
reg       load;
reg [7:0] din_load;
reg [7:0] max_count;

wire [7:0] counteroutput;

integer errors;

updowncounter8b_loadmax DUV
              (
                .upb_down( up0_down1 ),
                .clock( clock ),
			    .reset( reset ),
				.enable( enable ),
				.step_count( stepcount ),
			    .counter_output( counteroutput ),
				.load( load ),
				.din_load( din_load ),
				.max_count( max_count )
			  );

initial
begin
  $dumpfile("updowncounter_loadmax_simdata.vcd");
  $dumpvars(0, updowncounter_loadmax_tb );
end

initial
begin
  clock  = 1'b0;
  forever #5 clock = ~clock;
end

task check;
  input [7:0] exp;
  begin
    @(posedge clock);
    #1;
    if (counteroutput !== exp) begin
      errors = errors + 1;
      $display("ERROR t=%0t got=%0d exp=%0d", $time, counteroutput, exp);
    end
  end
endtask

initial
begin
  reset = 1'b0;
  #22 reset = 1'b1;
  #10 reset = 1'b0;
end

initial
begin
  errors    = 0;
  enable    = 1'b0;
  up0_down1 = 1'b0;
  stepcount = 8'd0;
  load      = 1'b0;
  din_load  = 8'd0;
  max_count = 8'd10;

  #1
  @(negedge reset);

  // Count up, step=1, max=10: 0,1,...,10 then wrap to 0
  stepcount = 8'd1;
  up0_down1 = 1'b0;
  load      = 1'b0;
  enable    = 1'b1;
  check(8'd1);
  check(8'd2);
  check(8'd3);
  check(8'd4);
  check(8'd5);
  check(8'd6);
  check(8'd7);
  check(8'd8);
  check(8'd9);
  check(8'd10);
  check(8'd0);
  check(8'd1);

  // Parallel load
  load     = 1'b1;
  din_load = 8'd7;
  check(8'd7);
  load     = 1'b0;

  // Count down, step=3, max=10 from 7: 4, 1, wrap to 10
  up0_down1 = 1'b1;
  stepcount = 8'd3;
  check(8'd4);
  check(8'd1);
  check(8'd10);

  // enable=0 holds
  enable = 1'b0;
  check(8'd10);
  check(8'd10);

  // 8-bit overflow while counting up: 254 + 2 with max=255 wraps to 0
  enable    = 1'b1;
  load      = 1'b1;
  din_load  = 8'd254;
  max_count = 8'd255;
  up0_down1 = 1'b0;
  stepcount = 8'd2;
  check(8'd254);
  load = 1'b0;
  check(8'd0);

  #100
  if (errors == 0)
    $display("PASS: loadmax counter");
  else
    $display("FAIL: %0d error(s)", errors);
  $finish;
end

endmodule
