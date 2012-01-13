module EAST_BORDER (
	PCLK, SE,
	EAST_IO_IN, EAST_IO_OUT, WEST_CB_IN, WEST_CB_OUT,
	NORTH_BUS_IN, SOUTH_BUS_IN, WEST_BUS_IN,
	NORTH_BUS_OUT, SOUTH_BUS_OUT, WEST_BUS_OUT,
	CB_SIN, SB_SIN,
	CB_SOUT, SB_SOUT
);


parameter NUM_LB_IN = 16;
parameter NUM_LB_OUT = 4;
parameter BUS_WIDTH = 2;
parameter IO_PER_CB = 1;

input PCLK;
input [IO_PER_CB-1:0] EAST_IO_IN;
input [BUS_WIDTH-1:0] NORTH_BUS_IN, SOUTH_BUS_IN, WEST_BUS_IN;
output [BUS_WIDTH-1:0] NORTH_BUS_OUT, SOUTH_BUS_OUT, WEST_BUS_OUT;
input [NUM_LB_OUT/4-1:0] WEST_CB_IN;
output [NUM_LB_IN/4-1:0] WEST_CB_OUT;
input SE, CB_SIN, SB_SIN;
output CB_SOUT, SB_SOUT;
output [IO_PER_CB-1:0] EAST_IO_OUT;



wire [BUS_WIDTH-1:0] bus_up, bus_down;
wire [NUM_LB_IN/4-1:0] io_in;
wire [NUM_LB_OUT/4-1:0] io_out;

assign io_in[IO_PER_CB-1:0] = EAST_IO_IN;
assign EAST_IO_OUT = io_out[IO_PER_CB-1:0];

SWITCH_BLOCK # ( .W(BUS_WIDTH) ) sb_inst (
	.CLK (PCLK),
	.IN_N (bus_down),
	.IN_E (),
	.IN_S (SOUTH_BUS_IN),
	.IN_W (WEST_BUS_IN),
	.OUT_N (bus_up),
	.OUT_E (),
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
) cb_inst (
	.CLK (PCLK),
	.LB1_IN (WEST_CB_IN),
	.LB2_IN (io_in),
	.SB1_IN (NORTH_BUS_IN),
	.SB2_IN (bus_up),
	.LB1_OUT (WEST_CB_OUT),
	.LB2_OUT (io_out),
	.SB1_OUT (NORTH_BUS_OUT),
	.SB2_OUT (bus_down),
	.SE (SE),
	.SIN (CB_SIN),
	.SOUT (CB_SOUT)
);


endmodule

