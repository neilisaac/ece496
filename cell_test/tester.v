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

wire shift_head;
reg [5:0] shift_select;
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
	else if (shift_select == 32) begin
		shift_select <= 0;
		shift_enable <= 0;
	end
	else if (shift_enable)
		shift_select <= shift_select + 1;
end

LUT6 # (
	// reversed because we start from address 0
	// programs a '1'b1' to the output-select flow (enables the flop)
	// programs 32'h7FFF_FFFE to the virtual lut
	// (true unless all switches are either on or all off)
	.INIT(64'h0000_0000_FFFF_FFFD)
) static_shift_rom (
	.O(shift_head),
	.I0(shift_select[0]),
	.I1(shift_select[1]),
	.I2(shift_select[2]),
	.I3(shift_select[3]),
	.I4(shift_select[4]),
	.I5(shift_select[5])
);

wire out, shift_out;

ble ble_inst1 (
	.PCLK(SYSCLK),
	.UCLK(user_clk),
	.SE(shift_enable),
	.SIN(shift_head),
	.SOUT(shift_out),
	.A(DIP[4:0]),
	.F(out)
);

assign LED_S = out;
assign LEDS = shift_select;
assign RS232_OUT = 1'b0;
assign { LED_C, LED_N, LED_E, LED_W } = 4'b0;

endmodule

