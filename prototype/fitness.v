module fitness (
	CLOCK_50,
	UART_RXD,
	SW,
	KEY,
	UART_TXD,
	LEDR,
	LEDG,
	HEX0,
	HEX1,
	HEX2,
	HEX3
);

input CLOCK_50;
input UART_RXD;
input [3:0] KEY;
input [9:0] SW;

output UART_TXD;
output [7:0] LEDG;
output [9:0] LEDR;
output [6:0] HEX0, HEX1, HEX2, HEX3;

wire VDD = 1'b1;
wire GND = 1'b0;

wire clock = CLOCK_50;
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

assign LEDR[8] = second;


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


wire uart_read, uart_active;
wire [7:0] uart_out;

uart serial (
	.main_clk(CLOCK_50),
	.rx(UART_RXD),
	.tx(UART_TXD),
	.reset(reset),
	.out_valid(uart_read),
	.out_data(uart_out),
	.active(uart_active)
);

reg [7:0] uart_buf;
always @ (posedge clock)
	if (uart_read)
		uart_buf <= uart_out;

assign LEDR[0] = uart_active;
assign LEDG = uart_buf;

hex_digits display0 (1, uart_buf[3:0], HEX0);
hex_digits display1 (1, uart_buf[7:4], HEX1);
hex_digits display2 (0, 0, HEX2);
hex_digits display3 (0, 0, HEX3);


endmodule

