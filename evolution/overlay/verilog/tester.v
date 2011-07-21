module tester (
	input clock,
	input reset,
	input start,
	input test_out,
	output test_in,
	output done,
	output select,
	output [31:0] score,
	output unused
);

wire sig1, sig2, test;

// 200kHz signal
divider # (500, 9) divider1 (
	.clk_in(clock),
	.reset(reset),
	.clk_out(sig1)
);

// 20kHz signal
divider # (5000, 13) divider2 (
	.clk_in(clock),
	.reset(reset),
	.clk_out(sig2)
);

// test clock
delay # (1000000, 20) delay1 (
	.clk_in(clock),
	.reset(reset),
	.clk_out(test)
);



// testing inputs/outputs
reg freq_select, complete;
wire in1 = freq_select ? sig1 : sig2;
assign test_in = in1;
wire out1 = test_out;



// control states
reg waiting, running;

// score counters for each input
reg [31:0] count1, count2;

// run test
always @ (posedge clock) begin

	if (reset) begin
		waiting <= 0;
		running <= 0;
		complete <= 0;
		count1 <= 0;
		count2 <= 0;
	end

	else begin

		// start signal starts test
		if (start) begin
			waiting <= 1;
			running <= 0;
			complete <= 0;
		end
		
		// need to wait for test clock
		if (waiting & test) begin
			waiting <= 0;
			running <= 1;
			count1 <= 0;
			count2 <= 0;
			freq_select <= 0;
		end
		
		// done testing first signal
		if (running & test)
			freq_select <= 1;

		// test complete
		if (running & test & freq_select) begin
			running <= 0;
			complete <= 1;
		end

		// while running we count 1s for each signal
		if (running) begin
			if (freq_select)
				count1 <= count1 + out1;
			else
				count2 <= count2 + out1;
		end
	end
end



assign done = ~start & complete;
assign select = freq_select;

// calculate score: score = abs(1s for sig1 - 1s for sig2)
assign score = (count1 > count2) ? (count1 - count2) : (count2 - count1);



endmodule

