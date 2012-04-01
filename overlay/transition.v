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

reg [25:0] timeout;

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

always @ (posedge CLK or posedge RST) begin
	if (RST)
		timeout <= 0;
	else begin
		if (timeout == 20000000)
			timeout <= 0;
		else if (timeout != 0)
			timeout <= timeout + 1;
		else if (TRANS)
			timeout <= 1;
	end
end

assign TRANS = active & (timeout == 0);


endmodule

