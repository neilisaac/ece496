`include "params.v"

module NORTH_BORDER (
	PCLK, SE,
	NORTH_IO_IN, NORTH_IO_OUT, SOUTH_CB_IN, SOUTH_CB_OUT,
	EAST_BUS_IN, SOUTH_BUS_IN, WEST_BUS_IN,
	EAST_BUS_OUT, SOUTH_BUS_OUT, WEST_BUS_OUT,
	CB_SIN, SB_SIN,
	CB_SOUT, SB_SOUT
);

input PCLK;
input [`IO_PER_CB-1:0] NORTH_IO_IN;
input [`TRACKS-1:0] EAST_BUS_IN, SOUTH_BUS_IN, WEST_BUS_IN;
output [`TRACKS-1:0] EAST_BUS_OUT, SOUTH_BUS_OUT, WEST_BUS_OUT;
input [`BLE_PER_CLB/4-1:0] SOUTH_CB_IN;
output [`CLB_INPUTS/4-1:0] SOUTH_CB_OUT;
input SE, CB_SIN, SB_SIN;
output CB_SOUT, SB_SOUT;
output [`IO_PER_CB-1:0] NORTH_IO_OUT;



wire [`TRACKS-1:0] bus_left, bus_right;
wire [`CLB_INPUTS/4-1:0] io_in;
wire [`BLE_PER_CLB/4-1:0] io_out;

assign io_in[`IO_PER_CB-1:0] = NORTH_IO_IN;
assign NORTH_IO_OUT = io_out[`IO_PER_CB-1:0];

SWITCH_BLOCK # ( .W(`TRACKS) ) sb_inst (
	.CLK (PCLK),
	.IN_N (),
	.IN_E (bus_left),
	.IN_S (SOUTH_BUS_IN),
	.IN_W (WEST_BUS_IN),
	.OUT_N (),
	.OUT_E (bus_right),
	.OUT_S (SOUTH_BUS_OUT),
	.OUT_W (WEST_BUS_OUT),
	.SE (SE),
	.SIN (SB_SIN),
	.SOUT (SB_SOUT)
);


CONNECTION_BLOCK # (
	.W (`TRACKS),
	.O (`CLB_INPUTS/4),
	.P (`BLE_PER_CLB/4)
) cb_inst (
	.CLK (PCLK),
	.LB1_IN (io_in),
	.LB2_IN (SOUTH_CB_IN),
	.SB1_IN (bus_right),
	.SB2_IN (EAST_BUS_IN),
	.LB1_OUT (io_out),
	.LB2_OUT (SOUTH_CB_OUT),
	.SB1_OUT (bus_left),
	.SB2_OUT (EAST_BUS_OUT),
	.SE (SE),
	.SIN (CB_SIN),
	.SOUT (CB_SOUT)
);


endmodule

