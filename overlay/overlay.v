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
wire [NUM_LB_IN/4-1:0] lb_in_left[ROWS:0][COLS:0], lb_in_down[ROWS:0][COLS:0];
wire [NUM_LB_OUT/4-1:0] lb_out_right[ROWS:0][COLS:0], lb_out_up[ROWS:0][COLS:0];
wire [BUS_WIDTH-1:0] bus_up[ROWS:0][COLS:0], bus_right[ROWS:0][COLS:0], bus_down[ROWS:0][COLS:0], bus_left[ROWS:0][COLS:0];

// shift chain between tiles
wire [COLS:0] shift_chain[ROWS:0];
assign shift_chain[0][0] = SIN;

// I/O connections
wire [IO_PER_CB*ROWS-1:0] io_in_west, io_out_west, io_in_east, io_out_east;
wire [IO_PER_CB*COLS-1:0] io_in_north, io_out_north, io_in_south, io_out_south;

assign io_in_north = INPUTS[IO_PER_CB*COLS-1:0];
assign io_in_east = INPUTS[IO_PER_CB*COLS+IO_PER_CB*ROWS-1:IO_PER_CB*COLS];
assign io_in_south = INPUTS[2*IO_PER_CB*COLS+IO_PER_CB*ROWS-1:IO_PER_CB*COLS+IO_PER_CB*ROWS];
assign io_in_west = INPUTS[2*IO_PER_CB*COLS+2*IO_PER_CB*ROWS-1:2*IO_PER_CB*COLS+IO_PER_CB*ROWS];

assign OUTPUTS = {io_out_west, io_out_south, io_out_east, io_out_north};

genvar x;
genvar y;

generate
	// top side
	for (x = 0; x < COLS; x = x + 1) begin : TOP
		wire shift_north_border;
		NORTH_BORDER # (
				.NUM_LB_IN	(NUM_LB_IN),
				.NUM_LB_OUT	(NUM_LB_OUT),
				.BUS_WIDTH	(BUS_WIDTH),
				.IO_PER_CB	(IO_PER_CB)
		) north_border_inst (
				.PCLK			(PCLK),
				.SE				(SE),
				.NORTH_IO_IN	(io_in_north[IO_PER_CB*x+IO_PER_CB-1:IO_PER_CB*x]),
				.NORTH_IO_OUT	(io_out_north[IO_PER_CB*x+IO_PER_CB-1:IO_PER_CB*x]),
				.SOUTH_CB_IN	(lb_out_up[ROWS][x]),
				.SOUTH_CB_OUT	(lb_in_down[ROWS][x]),
				.EAST_BUS_IN	(bus_left[ROWS][x+1]),
				.SOUTH_BUS_IN	(bus_up[ROWS][x]),
				.WEST_BUS_IN	(bus_right[ROWS][x]),
				.EAST_BUS_OUT	(bus_right[ROWS][x+1]),
				.SOUTH_BUS_OUT	(bus_down[ROWS][x]),
				.WEST_BUS_OUT	(bus_left[ROWS][x]),
				.SB_SIN			(shift_chain[ROWS][x]),
				.SB_SOUT		(shift_north_border),
				.CB_SIN			(shift_north_border),
				.CB_SOUT		(shift_chain[0][x+1])
		);
	end

	// right side
	for (y = 0; y < ROWS; y = y + 1) begin : RIGHT
		wire shift_east_border;
		EAST_BORDER # (
				.NUM_LB_IN	(NUM_LB_IN),
				.NUM_LB_OUT	(NUM_LB_OUT),
				.BUS_WIDTH	(BUS_WIDTH),
				.IO_PER_CB	(IO_PER_CB)
		) east_border_inst (
				.PCLK			(PCLK),
				.SE				(SE),
				.EAST_IO_IN		(io_in_east[IO_PER_CB*y+IO_PER_CB-1:IO_PER_CB*y]),
				.EAST_IO_OUT	(io_out_east[IO_PER_CB*y+IO_PER_CB-1:IO_PER_CB*y]),
				.WEST_CB_IN		(lb_out_right[y][COLS]),
				.WEST_CB_OUT	(lb_in_left[y][COLS]),
				.NORTH_BUS_IN	(bus_down[y+1][COLS]),
				.SOUTH_BUS_IN	(bus_up[y][COLS]),
				.WEST_BUS_IN	(bus_right[y][COLS]),
				.NORTH_BUS_OUT	(bus_up[y+1][COLS]),
				.SOUTH_BUS_OUT	(bus_down[y][COLS]),
				.WEST_BUS_OUT	(bus_left[y][COLS]),
				.SB_SIN			(shift_chain[y][COLS]),
				.SB_SOUT		(shift_east_border),
				.CB_SIN			(shift_east_border),
				.CB_SOUT		(shift_chain[ROWS][COLS])
		);
	end
	
	// instantiate top right switch block
	SWITCH_BLOCK # ( .W(BUS_WIDTH) ) corner_sb_inst (
	.CLK (PCLK),
	.IN_N (),
	.IN_E (),
	.IN_S (bus_up[ROWS][COLS]),
	.IN_W (bus_right[ROWS][COLS]),
	.OUT_N (),
	.OUT_E (),
	.OUT_S (bus_down[ROWS][COLS]),
	.OUT_W (bus_left[ROWS][COLS]),
	.SE (SE),
	.SIN (shift_chain[ROWS][COLS]),
	.SOUT (SOUT)
	);

	// instantiate tiles
	for (y = 0; y < ROWS; y = y + 1) begin : OVERLAY_ROW
		assign lb_out_right[y][0][0] = io_in_west[y];
		assign io_out_west[y] = lb_in_left[y][0][0];
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
			if (y==0) begin: SOUTH_OUTPUT
				assign lb_out_up[0][x][0] = io_in_south[x];
				assign io_out_south[x] = lb_in_down[0][x][0];
			end
		end
	end
endgenerate

//assign lb_out_up[0][COLS-1:0][IO_PER_CB-1:0] = io_in_south;
//assign lb_out_right[ROWS-1:0][0][IO_PER_CB-1:0] = io_in_west;
//assign io_out_south = lb_in_down[0][COLS-1:0][IO_PER_CB-1:0];
//assign io_out_west = lb_in_left[ROWS-1:0][0][IO_PER_CB-1:0];

endmodule

