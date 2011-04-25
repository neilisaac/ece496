module fitness (
	CLOCK_50,
	UART_RXD,
	SW,
	KEY,
	UART_TXD,
	LEDR,
	LEDG
);

input CLOCK_50;
input UART_RXD;
input [3:0] KEY;
input [9:0] SW;

output UART_TXD;
output [7:0] LEDG;
output [9:0] LEDR;

wire VDD = 1'b1;
wire GND = 1'b0;

wire reset = ~KEY[0];


wire sig1, sig2, second;

// 100kHz
divider # (500000, 20) divider1 (
	.clk_in(CLOCK_50),
	.reset(reset),
	.clk_out(sig1)
);

// 10kHz
divider # (5000000, 23) divider2 (
	.clk_in(CLOCK_50),
	.reset(reset),
	.clk_out(sig2)
);

// 1 second (single-cycle pulse)
delay # (50000000, 26) divider3 (
	.clk_in(CLOCK_50),
	.reset(reset),
	.clk_out(second)
);

assign LEDR[0] = second;


reg freq_select;
always @ (posedge CLOCK_50)
begin
	
end


wire in1 = freq_select ? sig1 : sig2;
wire out1;
wire unused;
assign LEDR[9] = unused;

individual mutant (
	.in1(in1),
	.out1(out1),
	.tie_unused(unused)
);

endmodule

