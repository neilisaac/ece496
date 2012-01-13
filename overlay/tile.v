module TILE (
	PCLK, PRST, UCLK, URST, SE,
	NORTH_LB_IN, EAST_LB_IN, SOUTH_LB_IN, WEST_LB_IN,
	NORTH_LB_OUT, EAST_LB_OUT, SOUTH_LB_OUT, WEST_LB_OUT,
	NORTH_BUS_IN, EAST_BUS_IN, SOUTH_BUS_IN, WEST_BUS_IN,
	NORTH_BUS_OUT, EAST_BUS_OUT, SOUTH_BUS_OUT, WEST_BUS_OUT,
	LB_SIN, CB1_SIN, CB2_SIN, SB_SIN,
	LB_SOUT, CB1_SOUT, CB2_SOUT, SB_SOUT
);


parameter NUM_LB_IN = 16;
parameter NUM_LB_OUT = 4;
parameter BUS_WIDTH = 2;

input PCLK, PRST, UCLK, URST;
input [BUS_WIDTH-1:0] NORTH_BUS_IN, EAST_BUS_IN, SOUTH_BUS_IN, WEST_BUS_IN;
output [BUS_WIDTH-1:0] NORTH_BUS_OUT, EAST_BUS_OUT, SOUTH_BUS_OUT, WEST_BUS_OUT;
input [NUM_LB_IN/4-1:0] NORTH_LB_IN, EAST_LB_IN;
input [NUM_LB_OUT/4-1:0] SOUTH_LB_IN, WEST_LB_IN;
output [NUM_LB_OUT/4-1:0] NORTH_LB_OUT, EAST_LB_OUT;
output [NUM_LB_IN/4-1:0] SOUTH_LB_OUT, WEST_LB_OUT;
input SE, LB_SIN, CB1_SIN, CB2_SIN, SB_SIN;
output LB_SOUT, CB1_SOUT, CB2_SOUT, SB_SOUT;


wire [NUM_LB_IN-1:0] lb_in;
assign lb_in[NUM_LB_IN/2-1:0] = { EAST_LB_IN, NORTH_LB_IN };

wire [NUM_LB_OUT-1:0] lb_out;
assign NORTH_LB_OUT = lb_out[NUM_LB_OUT/4-1:0];
assign EAST_LB_OUT = lb_out[NUM_LB_OUT/2-1:NUM_LB_OUT/4];

LOGIC_BLOCK # (
	.N_BLE (NUM_LB_OUT),
	.N_INPUT (NUM_LB_IN)
) lb_ne_inst (
	.PCLK	(PCLK),
	.PRST	(PRST),
	.UCLK	(UCLK),
	.URST	(URST),
	.IN		(lb_in),
	.SIN	(LB_SIN),
	.SOUT	(LB_SOUT),
	.SE		(SE),
	.OUT	(lb_out)
);


wire [BUS_WIDTH-1:0] bus_up, bus_down, bus_left, bus_right;

SWITCH_BLOCK # ( .W(BUS_WIDTH) ) sb_sw_inst (
	.CLK (PCLK),
	.IN_N (bus_down),
	.IN_E (bus_left),
	.IN_S (SOUTH_BUS_IN),
	.IN_W (WEST_BUS_IN),
	.OUT_N (bus_up),
	.OUT_E (bus_right),
	.OUT_S (SOUTH_BUS_OUT),
	.OUT_W (WEST_BUS_OUT),
	.SE (SE),
	.SIN (SB_SIN),
	.SOUT (SB_SOUT)
);


CONNECTION_BLOCK # (
	.W (BUS_WIDTH),
	.O (NUM_LB_IN/4),
	.P (NUM_LB_OUT/4)
) cb_nw_inst (
	.CLK (PCLK),
	.LB1_IN (WEST_LB_IN),
	.LB2_IN (lb_out[NUM_LB_OUT-1:NUM_LB_OUT*3/4]),
	.SB1_IN (NORTH_BUS_IN),
	.SB2_IN (bus_up),
	.LB1_OUT (WEST_LB_OUT),
	.LB2_OUT (lb_in[NUM_LB_IN-1:NUM_LB_IN*3/4]),
	.SB1_OUT (NORTH_BUS_OUT),
	.SB2_OUT (bus_down),
	.SE (SE),
	.SIN (CB2_SIN),
	.SOUT (CB2_SOUT)
);


CONNECTION_BLOCK # (
	.W (BUS_WIDTH),
	.O (NUM_LB_IN/4),
	.P (NUM_LB_OUT/4)
) cb_se_inst (
	.CLK (PCLK),
	.LB1_IN (lb_out[NUM_LB_OUT*3/4-1:NUM_LB_OUT/2]),
	.LB2_IN (SOUTH_LB_IN),
	.SB1_IN (bus_right),
	.SB2_IN (EAST_BUS_IN),
	.LB1_OUT (lb_in[NUM_LB_IN*3/4-1:NUM_LB_IN/2]),
	.LB2_OUT (SOUTH_LB_OUT),
	.SB1_OUT (bus_left),
	.SB2_OUT (EAST_BUS_OUT),
	.SE (SE),
	.SIN (CB1_SIN),
	.SOUT (CB1_SOUT)
);


endmodule

