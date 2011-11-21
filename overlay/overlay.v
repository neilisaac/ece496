module OVERLAY (
	PCLK, PRST, UCLK, URST,
	SIN, SOUT, SE,
	INPUTS, OUTPUTS
);

parameter NUM_LB_IN = 16;
parameter NUM_LB_OUT = 4;
parameter BUS_WIDTH = 2;

parameter ROWS = 1;
parameter COLS = 1;
parameter IO_PER_CB = 1;

parameter NUM_IO = 2 * IO_PER_CB * (ROWS + COLS);

input PCLK, PRST, UCLK, URST, SIN, SE;
output SOUT;
input [NUM_IO-1:0] INPUTS;
output [NUM_IO-1:0] OUTPUTS;

// connections between tiles
wire [NUM_LB_IN-1:0] lb_in_left[COLS:0][ROWS:0], lb_in_down[COLS:0][ROWS:0];
wire [NUM_LB_OUT-1:0] lb_out_right[COLS:0][ROWS:0], lb_out_up[COLS:0][ROWS:0];
wire [BUS_WIDTH-1:0] bus_up[COLS:0][ROWS:0], bus_right[COLS:0][ROWS:0],
	bus_down[COLS:0][ROWS:0], bus_left[COLS:0][ROWS:0];

// shift chain between tiles
wire [ROWS:0] shift_chain[COLS:0];
assign shift_chain[0][0] = SIN;

genvar x;
genvar y;

generate
	// top side
	for (x = 0; x < COLS; x = x + 1) begin : TOP

	end

	// right side
	for (y = 0; y < ROWS; y = y + 1) begin : RIGHT

	end

	// instantiate tiles
	for (y = 0; y < ROWS; y = y + 1) begin : OVERLAY_ROW
		for (x = 0; x < COLS; x = x + 1) begin : OVERLAY_COL
			wire [2:0] shift_internal;

			TILE # (
				.NUM_LB_IN		(NUM_LB_IN),
				.NUM_LB_OUT		(NUM_LB_OUT),
				.BUS_WIDTH		(BUS_WIDTH)
			) tile_inst (
				.PCLK			(PCLK),
				.PRST			(PRST),
				.UCLK			(UCLK),
				.URST			(URST),
				.SE				(SE),
				.NORTH_LB_IN	(lb_in_down[y+1][x]),
				.EAST_LB_IN		(lb_in_left[y][x+1]),
				.SOUTH_LB_IN	(lb_out_up[y][x]),
				.WEST_LB_IN		(lb_out_right[y][x]),
				.NORTH_LB_OUT	(lb_out_up[y+1][x]),
				.EAST_LB_OUT	(lb_out_right[y][x+1]),
				.SOUTH_LB_OUT	(lb_in_down[y][x]),
				.WEST_LB_OUT	(lb_in_left[y][x]),
				.NORTH_BUS_IN	(bus_down[y+1][x]),
				.EAST_BUS_IN	(bus_left[y][x+1]),
				.SOUTH_BUS_IN	(bus_up[y][x]),
				.WEST_BUS_IN	(bus_right[y][x]),
				.NORTH_BUS_OUT	(bus_up[y+1][x]),
				.EAST_BUS_OUT	(bus_right[y][x+1]),
				.SOUTH_BUS_OUT	(bus_down[y][x]),
				.WEST_BUS_OUT	(bus_left[y][x]),
				.SB_SIN			(shift_chain[y][x]),
				.SB_SOUT		(shift_internal[0]),
				.CB1_SIN		(shift_internal[0]),
				.CB1_SOUT		(shift_internal[1]),
				.CB2_SIN		(shift_internal[1]),
				.CB2_SOUT		(shift_internal[2]),
				.LB_SIN			(shift_internal[2]),
				.LB_SOUT		(shift_chain[y+1][x])
			);
		end
	end
endgenerate

endmodule

