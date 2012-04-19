// This file defines the parameters used to instantiate the virtual FPGA.


// width and height of the grid of CLBs
//
// note: VPR crashes if these are not equal
`define COLS 7
`define ROWS `COLS

// number of BLE input pins
//
// note1: we currently support 6-LUTs
`define LUT_PINS 6

// number of BLEs in each CLB
//
// note1: must be a multiple of 4 (for symmetry because each BLE's output is
//   routed out from the CLB in up/down/left/right and there must be an equal
//   number of outputs in each direction.)
// note2: this is equivalent to the number of CLB outputs
// note3: we only tested with 4 BLEs per CLB, but 8+ should work
`define BLE_PER_CLB 4

// tracks per channel (in each direction)
//
// note: tracks are unidirectional
`define TRACKS 8

// total inputs to a CLB (must be a multiple of 4 so they are distributed
// equally around top/bottom/left/right.)
`define CLB_INPUTS 16

// number of IOs connected to each connection block (CB) on the periphery
//
// note1: each IO supports an inputs AND an output
// note2: peripheral CBs have BLE_PER_CLB/4 inputs so
//   `IO_PER_CB <= BLE_PER_CLB/4
// note3: despite note2, we only currently support 1 input and output per CB
`define IO_PER_CB 1

// enable use of SRLC32E shift register for virtual LUTs and routing MUXes
//
// note1: available on Virtex-5 or later host FPGAs
// note2: comment this out to use fallback shift register implementation
`define USE_SRLC32E

// enable use of the F7 multiplexer 
//
// note1: available on Virtex-5
// note2: comment this out to use a generic verilog mux
`define USE_F7_MUX

