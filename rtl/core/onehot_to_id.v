`default_nettype none
`include "constants.vh"

module onehot_to_id (
	input  wire [`SPTAG_WIDTH-1:0] i_onehot,
	output reg  [2:0] 		       o_id
);

	always @(*) begin
		o_id = 0;
		case (i_onehot)
			5'b00001: o_id = 0;
			5'b00010: o_id = 1;
			5'b00100: o_id = 2;
			5'b01000: o_id = 3;
			5'b10000: o_id = 4;
		endcase 
	end

endmodule

`default_nettype wire
