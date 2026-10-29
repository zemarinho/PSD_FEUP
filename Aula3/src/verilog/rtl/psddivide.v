//-----
//  FEUP / M.EEC - Digital Systems Design 2024/2025
//
// Your names:
//    Tweety the Bird
//    Silvester the Cat
//
//-----

`timescale 1ns / 1ns

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

	reg [31:0] rdivisor;
	reg [32:0] mux1;
	reg [32:0] mux2;
	reg [30:0] mux3;
	reg [63:0] rdiv;
	reg [32:0] prest;
	reg [5:0] iteration;
	reg busy;
	//=========rdivisor============
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
	//=========rdivisor============


	//=========MUX1============
	always @(*)
	begin
		mux1 = {prest[31:0], rdiv[31]};
	end
	//=========MUX1============

	//=========MUX2============
	always @(*) //!SEE  if prest[32] ou start
	begin
		if (prest[32])
		begin
			mux2 = mux1 + {1'b0, rdivisor};
		end
		else
		begin
			mux2 = mux1 - {1'b0, rdivisor};
		end
	end
	/*
	always @(*)
	begin
		if (start)
		begin
			mux2 <={32'd0, dividend[31]};
		end
		else
		begin
			mux2 <= mux1;
		end
	end
	*/
	//=========MUX2============

	//=========MUX3============
	always @(*)
	begin
		mux3 = rdiv[30:0];
	end
	/*
	always @(*)
	begin
		if (start)
		begin
			mux3 <=dividend[30:0];
		end
		else
		begin
			mux3 <= {rdiv[29:0], ~prest[32]};
		end
	end
	*/
	//=========MUX3============

	//=========rdiv============
	always @(posedge clock)
	begin
		if (reset)
		begin
			rdiv <= 64'b0;
		end
		else if (start)
		begin
			rdiv <= {32'b0, dividend};
		end
		else if (busy)
		begin
			rdiv <= {32'b0, mux3, ~mux2[32]};
		end
	end
	/*
	always @(posedge clock or posedge reset)
	begin
		if (reset)
		begin
			rdiv <= 64'b0;
		end
		else
		begin
			rdiv <= {mux2, mux3};
		end
	end
	*/
	//=========rdiv============


	//=========prest============
	always @(posedge clock)
	begin
		if (reset)
		begin
			prest <= 33'b0;
			iteration <= 6'b0;
			busy <= 1'b0;
		end
		else if (start)
		begin
			prest <= 33'b0;
			iteration <= 6'b0;
			busy <= 1'b1;
		end
		else if (busy)
		begin
			prest <= mux2;
			if (iteration == 6'd31)
			begin
				busy <= 1'b0;
			end
			else
			begin
				iteration <= iteration + 1'b1;
			end
		end
	end
	/*always @(posedge clock or posedge reset)
	begin
    	if (reset)
    	    prest <= 33'b0;
    	else
    	    prest <= rdiv[63:31] - {1'b0, rdivisor};
	end
	*/
	//=========prest============


	//=========rest============
	always @(posedge clock)
	begin
		if (reset)
		begin
			rest <= 32'b0;
		end
		else if (stop)
		begin
			if (prest[32])
			begin
				rest <= prest[31:0] + rdivisor;
			end
			else
			begin
				rest <= prest[31:0];
			end
		end
	end
	/*
	always @(posedge clock or posedge reset)
	begin
		if (reset)
		begin
			rest <= 32'b0;
		end
		else if (stop)
		begin
			rest <= rdiv[63:32];
		end
	end
	*/
	//=========rest============


	//=========quotient============
	always @(posedge clock)
	begin
		if (reset)
		begin
			quotient <= 32'b0;
		end
		else if (stop)
		begin
			quotient <= rdiv[31:0];
		end
	end
	//=========quotient============
endmodule
