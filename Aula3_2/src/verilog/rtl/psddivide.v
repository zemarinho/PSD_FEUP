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

reg [31:0] divisor_reg;
reg [31:0] quotient_work;
reg [32:0] remainder_work;
reg [5:0] iteration;
reg busy;

wire [32:0] shifted_remainder =
	{remainder_work[31:0], quotient_work[31]};
//==========division datapath==========
always @(posedge clock)
begin
	if (reset)
	begin
		divisor_reg <= 32'b0;
		quotient_work <= 32'b0;
		remainder_work <= 33'b0;
		iteration <= 6'b0;
		busy <= 1'b0;
	end
	else if (start)
	begin
		divisor_reg <= divisor;
		quotient_work <= dividend;
		remainder_work <= 33'b0;
		iteration <= 6'b0;
		busy <= 1'b1;
	end
	else if (busy)
	begin
		if (shifted_remainder >= {1'b0, divisor_reg})
		begin
			remainder_work <= shifted_remainder - {1'b0, divisor_reg};
			quotient_work <= {quotient_work[30:0], 1'b1};
		end
		else
		begin
			remainder_work <= shifted_remainder;
			quotient_work <= {quotient_work[30:0], 1'b0};
		end

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

always @(posedge clock)
begin
	if (reset)
	begin
		quotient <= 32'b0;
		rest <= 32'b0;
	end
	else if (stop)
	begin
		if (divisor_reg == 32'b0)
		begin
			// Division by zero is undefined; match Verilog's X result.
			quotient <= 32'hxxxxxxxx;
			rest <= 32'hxxxxxxxx;
		end
		else
		begin
			quotient <= quotient_work;
			rest <= remainder_work[31:0];
		end
	end
end

endmodule
