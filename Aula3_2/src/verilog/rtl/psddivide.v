//-----
//  FEUP / M.EEC - Digital Systems Design 2024/2025
//
// Your names:
//    Tweety the Bird
//    Silvester the Cat
//
//-----

module psddivide
   (
	input             clock,		//master clock
	input             reset,		//synch reset, active high
	input             start,		//start a new division
	input             stop,			//load output registers
	input      [31:0] dividend,		// dividend
	input      [31:0] divisor,		// divisor
	output reg [31:0] quotient,		// quotient
	output reg [31:0] rest			// rest
	);

// ADD YOUR CODE HERE

reg [31:0] rdivisor;
//==========rdivisor==========
always @(posedge clock)
begin
	if (reset)
	begin
		rdivisor <= 32'b0;
	end
	else if (start)
	begin
		rdivisor <= divisor;
	end
end
//==========rdivisor==========

reg [32:0] prest;
//==========A-B==========
always @(posedge clock)
begin
	if (reset)
	begin
		prest <= 33'b0;
	end
	else
	begin
		prest <= rdiv[63:31] - {1'b0, rdivisor};
	end
end
//==========A-B==========

reg [32:0] mux1;
//==========mux1==========
always @(posedge clock)
begin
	if (prest[32])
	begin
		mux1 <= rdiv[62:30];
	end
	else
	begin
		mux1 <= {prest[31:0], rdiv[30]};
	end
end
//==========mux1==========

reg [32:0] mux2;
//==========mux2==========
always @(posedge clock)
begin
	if (start)
	begin
		mux2 <= {32'd0, dividend[31]};
	end
	else
	begin
		mux2 <= mux1;
	end
end
//==========mux2==========

reg [30:0] mux3;
//==========mux3==========
always @(posedge clock)
begin
	if (start)
	begin
		mux3 <= dividend[30:0];
	end
	else
	begin
		mux3 <= {rdiv[29:0], ~prest[32]};
	end
end
//==========mux3==========

reg [63:0] rdiv;
//==========rdiv==========
always @(posedge clock)
begin
	rdiv <= {mux2, mux3};
end
//==========rdiv==========

//==========rest==========
always @(posedge clock)
begin
	if (stop)
	begin
		rest <= rdiv[63:32];
	end
end
//==========rest==========

//==========quotient==========
always @(posedge clock)
begin
	if (stop)
	begin
		quotient <= rdiv[31:0];
	end
end
//==========quotient==========

endmodule
