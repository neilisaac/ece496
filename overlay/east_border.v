`include "params.v"

module EAST_BORDER (
	PCLK, SE,
	EAST_IO_IN, EAST_IO_OUT, WEST_CB_IN, WEST_CB_OUT,
	NORTH_BUS_IN, SOUTH_BUS_IN, WEST_BUS_IN,
	NORTH_BUS_OUT, SOUTH_BUS_OUT, WEST_BUS_OUT,
	CB_SIN, SB_SIN,
	CB_SOUT, SB_SOUT
);

input PCLK;
input [`IO_PER_CB-1:0] EAST_IO_IN;
input [`TRACKS-1:0] NORTH_BUS_IN, SOUTH_BUS_IN, WEST_BUS_IN;
output [`TRACKS-1:0] NORTH_BUS_OUT, SOUTH_BUS_OUT, WEST_BUS_OUT;
input [`BLE_PER_CLB/4-1:0] WEST_CB_IN;
output [`CLB_INPUTS/4-1:0] WEST_CB_OUT;
input SE, CB_SIN, SB_SIN;
output CB_SOUT, SB_SOUT;
output [`IO_PER_CB-1:0] EAST_IO_OUT;



wire [`TRACKS-1:0] bus_up, bus_down;
wire [`CLB_INPUTS/4-1:0] io_in;
wire [`BLE_PER_CLB/4-1:0] io_out;

assign io_in[`IO_PER_CB-1:0] = EAST_IO_IN;
assign EAST_IO_OUT = io_out[`IO_PER_CB-1:0];

SWITCH_BLOCK # ( .W(`TRACKS) ) sb_inst (
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
	.W (`TRACKS),
	.O (`CLB_INPUTS/4),
	.P (`BLE_PER_CLB/4)
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

