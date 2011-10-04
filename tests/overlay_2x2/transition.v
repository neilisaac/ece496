// Watch SIGNAL for a low->high transition,
// then make the output high for one cycle.

module TRANSITION (
	input CLK,
	input RST,
	input SIGNAL,
	output TRANS
);


reg seen_edge;
reg active;

always @ (posedge CLK or posedge RST) begin
	if (RST)
		seen_edge <= 0;
	else begin
		if (~SIGNAL)
			seen_edge <= 0;

		if (SIGNAL & ~seen_edge) begin
			active <= 1;
			seen_edge <= 1;
		end
		else
			active <= 0;
	end
end

assign TRANS = active;


endmodule

