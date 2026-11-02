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

	// CHANGED: Previous pipelined implementation retained here for reference.

	reg [31:0] rdivisor;
	reg [63:0] rdiv;
	wire [32:0] prest;

	assign prest = rdiv[63:31] - {1'b0, rdivisor};
	always @(posedge clock)
	begin
		if (reset)
		begin
			rdivisor <= 32'd0;
			rdiv <= 64'd0;
			rest <= 32'd0;
			quotient <= 32'd0;
		end
		else
		begin
			if (start)
			begin
				rdiv <= {32'b0, dividend};
				rdivisor <= divisor;
			end
			else
			begin
				if (prest[32])
				begin
					rdiv <= {rdiv[63:0], ~prest[32]};
				end
				else
				begin
					rdiv <= {prest[31:0], rdiv[30:0], ~prest[32]};
				end
			end

			if (stop)
			begin
				if (rdivisor)
				begin
					rest <= rdiv[63:32];
					quotient <= rdiv[31:0];
				end
				else
				begin
					rest <= 32'bX;
					quotient <= 32'bX;
				end
			end
		end
	end
endmodule
