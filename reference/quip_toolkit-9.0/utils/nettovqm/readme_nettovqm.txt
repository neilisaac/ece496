This document describes the purpose and use of the "Net To VQM" application 
included in this distribution of QUIP.
        
CONTENTS
--------------------------------------------------------------------------------
  I. What is Net To VQM?
 II. Using Net To VQM
III. File Formats
 IV. Notes
  V. Example


I.  What is Net To VQM?
--------------------------------------------------------------------------------

The Net To VQM application is designed to provide a convenient way for users to 
take a VPR .net netlist and convert it to Altera's .vqm netlist format, which can
be read by the Quartus II design software.

VPR is a popular academic placement and routing tool for FPGAs.  It can read
circuit netlists in the .net format.  Documentation for the .net format, along with
some sample .net format circuits are included with the VPR distribution,
which you can get from the University of Toronto:

   http://www.eecg.toronto.edu/~vaughn/vpr/vpr.html

II. Using Net To VQM
--------------------------------------------------------------------------------

This distribution contains the C source code for Net To VQM, which must be 
compiled before being used.  This can be done with any standard C compiler by 
using a command equivalent to:

                        cc -o nettovqm nettovqm.c

Once compiled, the application can be called from the command line using the 
following format:

              nettovqm [ -a architecture ] [ -k lutsize ] designname

This tells the nettovqm program to read a file called designname.net and 
produces a file called designname.vqm.  The .net file should be in VPR's .net 
netlist format.  The .vqm file will be in Altera's .vqm netlist format, 
which can then be used by the Quartus II design software.

The optional -a flag to nettovqm specifies the Altera architecture that
you are targeting.  Each target has a slightly different .vqm file format.
The legal architectures are "Stratix", "Cyclone" and "MaxII".  The default
architecture is "Stratix".

The optional -k flag to nettovqm specifies the number of inputs to a LUT.  The
'lutsize' should be an integer and defaults to a value of 4.

III. File Formats
--------------------------------------------------------------------------------

The input file to nettovqm must be a VPR .net format input file for
a VPR architecture with the following attributes:

1) one BLE per CLB
2) k input LUT (default k=4)
3) each BLE has these pins, in this order:
   a) the k LUT inputs
   b) one output
   c) one clock input
4) each CLB has the same number of pins as the BLE, in the same order as
   the BLE.

The output file will be a version of the input netlist in Altera's .vqm
netlist format.  You should be able to read the .vqm file into Quartus II,
version 3.0 or later.


IV. Notes
--------------------------------------------------------------------------------


VPR's .net format does not say what the function of each LUT should be.
The nettovqm program is forced to make one up, and makes each LUT into
a wide NAND.  If this is a problem, change the vqm_print_lcell() routine
in nettovqm.c by adjusting the LUT masks in the final switch statement in
this routine.  For more information on LUT masks and their format, please see
the quip_tutorial.pdf file included with this distribution.


V. Example
--------------------------------------------------------------------------------


This simple small.net format file:

   .input a      # Input pad.
   pinlist: a    # Blocks can have the same name as nets with no conflict.
   
   .input bpad
   pinlist: b
   
   .clb simplei                           # Logic block.
   pinlist: a b open open and2 open       # 2 LUT inputs used, clock input unconnected.
   subblock: sb_one 0 1 open open 4 open  # Subblock line says the same thing.
   
   .output out_and2    # Output pad.
   pinlist: and2


will produce this small.vqm file:

   module small (
   	a,
   	b,
   	and2);
   input a;
   input b;
   output and2;
   
   stratix_io \a~I (
   	.padio(a),
   	.combout(\a~internal ));
   defparam \a~I .operation_mode = "input";
   
   stratix_io \bpad~I (
   	.padio(b),
   	.combout(\b~internal ));
   defparam \bpad~I .operation_mode = "input";
   
   stratix_lcell \sb_one~I (
   	.dataa(\a~internal ),
   	.datab(\b~internal ),
   	.combout(\and2~internal ));
   defparam \sb_one~I .operation_mode = "normal";
   defparam \sb_one~I .lut_mask = "7777";
   
   stratix_io \out_and2~I (
   	.padio(and2),
   	.datain(\and2~internal ));
   defparam \out_and2~I .operation_mode = "output";
   endmodule
