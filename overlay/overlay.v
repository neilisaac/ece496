`include "params.v"

module OVERLAY (
	PCLK, PRST, UCLK, URST,
	SIN, SE,
	INPUTS, OUTPUTS
);

parameter NUM_IO = 2 * `IO_PER_CB * (`ROWS + `COLS);

input PCLK, PRST, UCLK, URST, SIN, SE;
input [NUM_IO-1:0] INPUTS;
output [NUM_IO-1:0] OUTPUTS;

// connections between tiles
wire [`CLB_INPUTS/4-1:0] lb_in_left[`ROWS-1:0][`COLS:0], lb_in_down[`ROWS:0][`COLS-1:0];
wire [`BLE_PER_CLB/4-1:0] lb_out_right[`ROWS-1:0][`COLS:0], lb_out_up[`ROWS:0][`COLS-1:0];
wire [`TRACKS-1:0] bus_up[`ROWS:0][`COLS:0], bus_right[`ROWS:0][`COLS:0], bus_down[`ROWS:0][`COLS:0], bus_left[`ROWS:0][`COLS:0];

// shift chain between tiles
wire [`COLS:0] shift_chain[`ROWS:0];
assign shift_chain[0][0] = SIN;

// I/O connections
wire [`IO_PER_CB*`ROWS-1:0] io_in_west, io_out_west, io_in_east, io_out_east;
wire [`IO_PER_CB*`COLS-1:0] io_in_north, io_out_north, io_in_south, io_out_south;

// top and left inputs are ordered left-to-right and bottom-to-top so they are
// assigned directly
assign io_in_north = INPUTS[`IO_PER_CB*`COLS-1:0];
assign io_in_west = INPUTS[2*`IO_PER_CB*`COLS+2*`IO_PER_CB*`ROWS-1:2*`IO_PER_CB*`COLS+`IO_PER_CB*`ROWS];
assign OUTPUTS[`IO_PER_CB*`COLS-1:0] = io_out_north;
assign OUTPUTS[2*`IO_PER_CB*(`COLS+`ROWS)-1:`IO_PER_CB*(2*`COLS+`ROWS)] = io_out_west;

genvar x;
genvar y;
genvar i;

// right side inputs/outputs are ordered top-to-bottom, so they the connection
// block numbers they are connected to needs to be reversed
generate
	for (y = 0; y < `ROWS; y = y + 1) begin : REVERSE_EAST
		for (i = 0; i < `IO_PER_CB; i = i + 1) begin : REVERSE_EAST_BITWISE
			assign io_in_east[`IO_PER_CB*y+i] = INPUTS[`IO_PER_CB*`COLS+`IO_PER_CB*(`ROWS-y-1)+`IO_PER_CB-i-1];
			assign OUTPUTS[`IO_PER_CB*`COLS+`IO_PER_CB*y+i] = io_out_east[`IO_PER_CB*(`ROWS-y-1)+`IO_PER_CB-i-1];
		end
	end
endgenerate

// bottom side inputs/outputs are ordered right-to-left, so they the connection
// block numbers they are connected to needs to be reversed
generate
	for (x = 0; x < `COLS; x = x + 1) begin : REVERSE_SOUTH
		for (i = 0; i < `IO_PER_CB; i = i + 1) begin : REVERSE_SOUTH_BITWISE
			assign io_in_south[`IO_PER_CB*x+i] = INPUTS[`IO_PER_CB*(`COLS+`ROWS)+`IO_PER_CB*(`COLS-x-1)+`IO_PER_CB-i-1];
			assign OUTPUTS[`IO_PER_CB*(`COLS+`ROWS)+`IO_PER_CB*x+i] = io_out_south[`IO_PER_CB*(`COLS-x-1)+`IO_PER_CB-i-1];
		end
	end
endgenerate
		
// generate the logic tile grid
generate
	// top side boundary "border" tiles (1 connection block + 1 switch block)
	for (x = 0; x < `COLS; x = x + 1) begin : TOP
		wire shift_north_border;
		NORTH_BORDER north_border_inst (
				.PCLK			(PCLK),
				.SE				(SE),
				.NORTH_IO_IN	(io_in_north[`IO_PER_CB*x+`IO_PER_CB-1:`IO_PER_CB*x]),
				.NORTH_IO_OUT	(io_out_north[`IO_PER_CB*x+`IO_PER_CB-1:`IO_PER_CB*x]),
				.SOUTH_CB_IN	(lb_out_up[`ROWS][x]),
				.SOUTH_CB_OUT	(lb_in_down[`ROWS][x]),
				.EAST_BUS_IN	(bus_left[`ROWS][x+1]),
				.SOUTH_BUS_IN	(bus_up[`ROWS][x]),
				.WEST_BUS_IN	(bus_right[`ROWS][x]),
				.EAST_BUS_OUT	(bus_right[`ROWS][x+1]),
				.SOUTH_BUS_OUT	(bus_down[`ROWS][x]),
				.WEST_BUS_OUT	(bus_left[`ROWS][x]),
				.SB_SIN			(shift_chain[`ROWS][x]),
				.SB_SOUT		(shift_north_border),
				.CB_SIN			(shift_north_border),
				.CB_SOUT		(shift_chain[0][x+1])
		);
	end

	// right side "border" tiles
	for (y = 0; y < `ROWS; y = y + 1) begin : RIGHT
		wire shift_east_border;
		EAST_BORDER east_border_inst (
				.PCLK			(PCLK),
				.SE				(SE),
				.EAST_IO_IN		(io_in_east[`IO_PER_CB*y+`IO_PER_CB-1:`IO_PER_CB*y]),
				.EAST_IO_OUT	(io_out_east[`IO_PER_CB*y+`IO_PER_CB-1:`IO_PER_CB*y]),
				.WEST_CB_IN		(lb_out_right[y][`COLS]),
				.WEST_CB_OUT	(lb_in_left[y][`COLS]),
				.NORTH_BUS_IN	(bus_down[y+1][`COLS]),
				.SOUTH_BUS_IN	(bus_up[y][`COLS]),
				.WEST_BUS_IN	(bus_right[y][`COLS]),
				.NORTH_BUS_OUT	(bus_up[y+1][`COLS]),
				.SOUTH_BUS_OUT	(bus_down[y][`COLS]),
				.WEST_BUS_OUT	(bus_left[y][`COLS]),
				.SB_SIN			(shift_chain[y][`COLS]),
				.SB_SOUT		(shift_east_border),
				.CB_SIN			(shift_east_border),
				.CB_SOUT		(shift_chain[y+1][`COLS])
		);
	end

	// instantiate top right switch block to connect right-most north border tile
	// to the top-most east border tile
	SWITCH_BLOCK corner_sb_inst (
		.CLK (PCLK),
		.IN_N (0),
		.IN_E (0),
		.IN_S (bus_up[`ROWS][`COLS]),
		.IN_W (bus_right[`ROWS][`COLS]),
		.OUT_N (),
		.OUT_E (),
		.OUT_S (bus_down[`ROWS][`COLS]),
		.OUT_W (bus_left[`ROWS][`COLS]),
		.SE (SE),
		.SIN (shift_chain[`ROWS][`COLS]),
		.SOUT () // end of the shift chain
	);

	// instantiate the logic tiles
	for (y = 0; y < `ROWS; y = y + 1) begin : OVERLAY_ROW
		assign bus_right[y][0] = 0;
		assign bus_left[y][`COLS] = 0;
		
		assign lb_out_right[y][0][`IO_PER_CB-1:0] = io_in_west[`IO_PER_CB*y+`IO_PER_CB-1:`IO_PER_CB*y];
		assign io_out_west[`IO_PER_CB*y+`IO_PER_CB-1:`IO_PER_CB*y] = lb_in_left[y][0][`IO_PER_CB-1:0];
		for (x = 0; x < `COLS; x = x + 1) begin : OVERLAY_COL
			wire [2:0] shift_internal;

			// logic tile (containing a LB, 2 CBs, and a SB)
			// note: this is done connected genericly, but some outputs on the
			//   left and bottom aren't used.  XST generates warnings for
			//   trimmed signals: lb_in_left, lb_in_down, bus_left, bus_down
			//   which can should be ignored.
			TILE tile_inst (
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

			if (y == 0) begin: SOUTH_OUTPUT
				assign lb_out_up[0][x][`IO_PER_CB-1:0] = io_in_south[`IO_PER_CB*x+`IO_PER_CB-1:`IO_PER_CB*x];
				assign io_out_south[`IO_PER_CB*x+`IO_PER_CB-1:`IO_PER_CB*x] = lb_in_down[0][x][`IO_PER_CB-1:0];

				assign bus_up[0][x] = 0;
				assign bus_down[`ROWS][x] = 0;
			end
		end
	end
endgenerate

// assign remaining unused boundary signals
assign bus_up[0][`COLS] = 0;
assign bus_right[`ROWS][0] = 0;

endmodule

