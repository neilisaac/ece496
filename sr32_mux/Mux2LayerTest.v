module Mux2LayerTest(
	input SYSCLK,
	input SYSRST,
	input PUSH_N, PUSH_S, PUSH_E, PUSH_W, PUSH_C,
	input [7:0] DIP,
	input UART_RX,
	output UART_TX,
	output LED_N, LED_S, LED_E, LED_W, LED_C,
	output [7:0] LEDS
   );
	
wire [24:0] a;
assign a[7:0] = DIP[7:0];
assign a[24:8] = 17'hFFFFF;

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

reg [7:0] shift_select;
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
	else if (shift_select == 192) begin
		shift_select <= 0;
		shift_enable <= 0;
	end
	else if (shift_enable)
		shift_select <= shift_select + 1;
end

wire [7:0] shift_addr = shift_select - 1;

wire shift_master = (PUSH_E? 0 : shift_head);

LUT6 # (
	// reversed because we start from address 0
	// 5555_5555 = pick 0
	// 3333_3333 = pick 1
	// 0F0F_0F0F = pick 2
	// 00FF_00FF = pick 3
	// 0000_FFFF = pick 4
	// 0000_0001 = AND gate
	.INIT(64'h0000_0001_3333_3333)
) static_shift_rom1 (
	.O(shift_head_a),
	.I0(shift_addr[0]),
	.I1(shift_addr[1]),
	.I2(shift_addr[2]),
	.I3(shift_addr[3]),
	.I4(shift_addr[4]),
	.I5(shift_addr[5])
);

LUT6 # (
	// reversed because we start from address 0
	// 5555_5555 = pick 0
	// 3333_3333 = pick 1
	// 0F0F_0F0F = pick 2
	// 00FF_00FF = pick 3
	// 0000_FFFF = pick 4
	// 0000_0001 = AND gate
	.INIT(64'h0000_0001_0000_0001)
) static_shift_rom2 (
	.O(shift_head_b),
	.I0(shift_addr[0]),
	.I1(shift_addr[1]),
	.I2(shift_addr[2]),
	.I3(shift_addr[3]),
	.I4(shift_addr[4]),
	.I5(shift_addr[5])
);

LUT6 # (
	// reversed because we start from address 0
	// 5555_5555 = pick 0
	// 3333_3333 = pick 1
	// 0F0F_0F0F = pick 2
	// 00FF_00FF = pick 3
	// 0000_FFFF = pick 4
	// 0000_0001 = AND gate
	.INIT(64'h0000_0001_0F0F_0F0F)
) static_shift_rom3 (
	.O(shift_head_c),
	.I0(shift_addr[0]),
	.I1(shift_addr[1]),
	.I2(shift_addr[2]),
	.I3(shift_addr[3]),
	.I4(shift_addr[4]),
	.I5(shift_addr[5])
);

wire shift_head_d = (shift_addr[6]? shift_head_b: shift_head_a);
assign shift_head1 = (shift_addr >= 128? shift_head_c: shift_head_d);

LayerMux2 mux_inst(
.A(a),
.CE(shift_enable),
.CLK(SYSCLK),
.D(shift_master),
.Z(LEDS[7]),
.Q(LED_C)
);

assign {LED_N, LED_E, LED_W, LED_S} = 4'b0;
assign LEDS[6:0] = 7'b0;
assign UART_TX = 1'b0;

endmodule