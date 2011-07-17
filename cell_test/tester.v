module top(
	input SYSCLK,
	input SYSRST,
	input [4:0] PUSH,
	input [7:0] DIP,
	input RS232_IN,
	output RS232_OUT,
	output [4:0] POS_LEDS,
	output [7:0] LEDS
);

reg user_clk;
reg user_seen_edge;
always @ (posedge SYSCLK)
	if (~user_seen_edge && PUSH[1]) begin
		user_clk <= 1;
		user_seen_edge <= 1;
	end
	else if (~PUSH[1]) begin
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

always @ (posedge SYSCLK)
	if (~PUSH[0])
		seen_edge <= 0;
		
	if (PUSH[0] && ~seen_edge) begin
		shift_select <= shift_select + 1;
		shift_enable <= 1;
		seen_edge <= 1;
	end
	else if (shift_select == 32) begin
		shift_select <= 0;
		shift_enable <= 0;
	end
	else if (shift_select > 0)
		shift_select <= shift_select + 1;

wire [5:0] rom_select = 63 - shift_select;

LUT6 # (
	.INIT(64'h0000000080000000)
) static_shift_rom (
	.O(shift_head),
	.I0(rom_select[0]),
	.I1(rom_select[1]),
	.I2(rom_select[2]),
	.I3(rom_select[3]),
	.I4(rom_select[4]),
	.I5(rom_select[5])
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

assign POS_LEDS[0] = out;
assign LEDS = DIP;
assign POS_LEDS[4:1] = 4'b0;
assign RS232_OUT = 1'b0;

endmodule

