module MASTER (
	input SYSCLK,
	input SYSRST,
	input PUSH_N, PUSH_S, PUSH_E, PUSH_W, PUSH_C,
	input [7:0] DIP,
	input UART_RX,
	output UART_TX,
	output LED_N, LED_S, LED_E, LED_W, LED_C,
	output [7:0] LEDS
);

parameter W = 5; //width of interconnecting bus (one way)
parameter O = 4; //width of input into logic blocks (per side)
parameter P = 1; //width of output from logic blocks (per side)

wire uart_rx_valid;
wire uart_tx_ready;
wire uart_tx_valid;
wire [7:0] uart_rx_data;
wire [7:0] uart_tx_data;

UART UART_inst (
	.SCLK(SYSCLK),
	.RESET(~SYSRST),
	.RX(UART_RX),
	.RX_VALID(uart_rx_valid),
	.RX_DATA(uart_rx_data),
	.TX(UART_TX),
	.TX_READY(uart_tx_ready),
	.TX_VALID(uart_tx_valid),
	.TX_DATA(uart_tx_data)
);


wire shift_head;
wire shift_tail;
wire shift_enable;

wire [9:0] scan_chain;
assign scan_chain[0] = shift_head;
assign shift_tail = scan_chain[9];

DECODER decoder_inst (
	.SCLK(SYSCLK),
	.RESET(~SYSRST),
	.UART_READY(uart_tx_ready),
	.RX_VALID(uart_rx_valid),
	.TX_VALID(uart_tx_valid),
	.RX_DATA(uart_rx_data),
	.TX_DATA(uart_tx_data),
	.SHIFT_HEAD(shift_head),
	.SHIFT_TAIL(shift_tail),
	.SHIFT_ENABLE(shift_enable)
);


wire user_clock;
wire user_reset;
wire [O*4-1:0] ble1_in;
wire [O*4-1:0] ble2_in;
wire [O*4-1:0] ble3_in;
wire [O*4-1:0] ble4_in;
wire [3:0] ble1_out;
wire [3:0] ble2_out;
wire [3:0] ble3_out;
wire [3:0] ble4_out;
wire [W-1:0] bus_n_in;
wire [W-1:0] bus_n_out;
wire [W-1:0] bus_e_in;
wire [W-1:0] bus_e_out;
wire [W-1:0] bus_s_in;
wire [W-1:0] bus_s_out;
wire [W-1:0] bus_w_in;
wire [W-1:0] bus_w_out;
wire [W-1:0] n_in;
wire [W-1:0] n_out;
wire [W-1:0] e_in;
wire [W-1:0] e_out;
wire [W-1:0] s_in;
wire [W-1:0] s_out;
wire [W-1:0] w_in;
wire [W-1:0] w_out;

assign n_in = DIP[4:0];
assign LEDS[4:0] = n_out;
assign LEDS[7:5] = 0;

TRANSITION user_clock_tran_inst(SYSCLK, ~SYSRST, PUSH_E, user_clock);
TRANSITION user_reset_tran_inst(SYSCLK, ~SYSRST, PUSH_N, user_reset);	

LOGIC_BLOCK lb_inst1 (
	.PCLK	(SYSCLK),
	.PRST	(~SYSRST),
	.UCLK	(user_clock),
	.URST	(user_reset),
	.IN	(ble1_in),
	.SIN	(scan_chain[0]),
	.SOUT	(scan_chain[1]),
	.SE	(shift_enable),
	.OUT	(ble1_out)
);

LOGIC_BLOCK lb_inst2 (
	.PCLK	(SYSCLK),
	.PRST	(~SYSRST),
	.UCLK	(user_clock),
	.URST	(user_reset),
	.IN	(ble2_in),
	.SIN	(scan_chain[2]),
	.SOUT	(scan_chain[3]),
	.SE	(shift_enable),
	.OUT	(ble2_out)
);

LOGIC_BLOCK lb_inst3 (
	.PCLK	(SYSCLK),
	.PRST	(~SYSRST),
	.UCLK	(user_clock),
	.URST	(user_reset),
	.IN	(ble3_in),
	.SIN	(scan_chain[8]),
	.SOUT	(scan_chain[9]),
	.SE	(shift_enable),
	.OUT	(ble3_out)
);

LOGIC_BLOCK lb_inst4 (
	.PCLK	(SYSCLK),
	.PRST	(~SYSRST),
	.UCLK	(user_clock),
	.URST	(user_reset),
	.IN	(ble4_in),
	.SIN	(scan_chain[6]),
	.SOUT	(scan_chain[7]),
	.SE	(shift_enable),
	.OUT	(ble4_out)
);

ConnectionBlock #(.W(W), .O(O), .P(P)) cb_inst_n (
	.LB1_IN	(ble1_out[1]),
	.LB2_IN	(ble2_out[3]),
	.CB1_IN	(n_in),
	.CB2_IN	(bus_n_in),
	.LB1_OUT	(ble1_in[7:4]),
	.LB2_OUT	(ble2_in[15:12]),
	.CB1_OUT	(n_out),
	.CB2_OUT	(bus_n_out),
	.CLK	(SYSCLK),
	.CE	(shift_enable),
	.SIN	(scan_chain[1]),
	.SOUT	(scan_chain[2])
);

ConnectionBlock #(.W(W), .O(O), .P(P)) cb_inst_e (
	.LB1_IN	(ble2_out[2]),
	.LB2_IN	(ble3_out[0]),
	.CB1_IN	(bus_e_in),
	.CB2_IN	(e_in),
	.LB1_OUT	(ble2_in[11:8]),
	.LB2_OUT	(ble3_in[3:0]),
	.CB1_OUT	(bus_e_out),
	.CB2_OUT	(e_out),
	.CLK	(SYSCLK),
	.CE	(shift_enable),
	.SIN	(scan_chain[3]),
	.SOUT	(scan_chain[4])
);

ConnectionBlock #(.W(W), .O(O), .P(P)) cb_inst_s (
	.LB1_IN	(ble4_out[1]),
	.LB2_IN	(ble3_out[3]),
	.CB1_IN	(bus_s_in),
	.CB2_IN	(s_in),
	.LB1_OUT	(ble4_in[7:4]),
	.LB2_OUT	(ble3_in[15:12]),
	.CB1_OUT	(bus_s_out),
	.CB2_OUT	(s_out),
	.CLK	(SYSCLK),
	.CE	(shift_enable),
	.SIN	(scan_chain[7]),
	.SOUT	(scan_chain[8])
);

ConnectionBlock #(.W(W), .O(O), .P(P)) cb_inst_w (
	.LB1_IN	(ble1_out[2]),
	.LB2_IN	(ble4_out[0]),
	.CB1_IN	(w_in),
	.CB2_IN	(bus_w_in),
	.LB1_OUT	(ble1_in[11:8]),
	.LB2_OUT	(ble4_in[3:0]),
	.CB1_OUT	(w_out),
	.CB2_OUT	(bus_w_out),
	.CLK	(SYSCLK),
	.CE	(shift_enable),
	.SIN	(scan_chain[5]),
	.SOUT	(scan_chain[6])
);

SwitchBlock #(.W(W)) sb_inst (
	.IN_N	(bus_n_out),
	.IN_E	(bus_e_out),
	.IN_S	(bus_s_out),
	.IN_W	(bus_w_out),
	.OUT_N	(bus_n_in),
	.OUT_E	(bus_e_in),
	.OUT_S	(bus_s_in),
	.OUT_W	(bus_w_in),
	.CLK	(SYSCLK),
	.CE	(shift_enable),
	.SIN	(scan_chain[4]),
	.SOUT	(scan_chain[5])
);

reg [7:0] test;
always @ (posedge SYSCLK) if (shift_enable) test <= { shift_head, test[7:1] };
//assign LEDS = PUSH_S ? test : ble_out;

//assign LEDS = { 4'b0, ble_out };
assign { LED_N, LED_W, LED_S, LED_E, LED_C } = { PUSH_N, PUSH_W, PUSH_S, PUSH_E, PUSH_C };


endmodule

