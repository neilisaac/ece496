module top(
	input SYSCLK,
	input SYSRST,
	input PUSH_N, PUSH_S, PUSH_E, PUSH_W, PUSH_C,
	input [7:0] DIP,
	input RS232_IN,
	output RS232_OUT,
	output LED_N, LED_S, LED_E, LED_W, LED_C,
	output [7:0] LEDS
);

reg user_clk;
reg user_seen_edge;
always @ (posedge SYSCLK)
	if (~user_seen_edge && PUSH_N) begin
		user_clk <= 1;
		user_seen_edge <= 1;
	end
	else if (~PUSH_N) begin
		user_seen_edge <= 0;
		user_clk <= 0;
	end
	else begin
		user_clk <= 0;
	end

reg [6:0] shift_select;
wire shift_head1;
wire shift_head2 = 0;
wire shift_head = (shift_select == 0) ? shift_head2 : shift_head1;
reg shift_enable;
reg seen_edge;

always @ (posedge SYSCLK) begin
	if (~PUSH_S)
		seen_edge <= 0;
		
	if (PUSH_S && ~seen_edge) begin
		shift_select <= 0;
		shift_enable <= 1;
		seen_edge <= 1;
	end
	else if (shift_select == 64) begin
		shift_select <= 0;
		shift_enable <= 0;
	end
	else if (shift_enable)
		shift_select <= shift_select + 1;
end

wire [6:0] shift_addr = shift_select - 1;

LUT6 # (
	// reversed because we start from address 0
	// true unless all switches are either on or all off
	.INIT(64'h7FFF_FFFF_FFFF_FFFE)
) static_shift_rom1 (
	.O(shift_head1),
	.I0(shift_addr[0]),
	.I1(shift_addr[1]),
	.I2(shift_addr[2]),
	.I3(shift_addr[3]),
	.I4(shift_addr[4]),
	.I5(shift_addr[5])
);


wire out, shift_out;

ble ble_inst1 (
	.PCLK(SYSCLK),
	.UCLK(user_clk),
	.SE(shift_enable),
	.SIN(shift_head),
	.SOUT(shift_out),
	.A(DIP[5:0]),
	.F(out)
);

assign LED_S = out;
assign LEDS = shift_select;
assign RS232_OUT = 1'b0;
assign { LED_C, LED_N, LED_E, LED_W } = 4'b0;

endmodule

