FILES
-----

Under the "circuits" directory of the EDA Toolkit, you should find
the following files:

	- nios_ref_32_system.qar
	- nios_standard_custom_instruction_32.qar
	- twister.qar
	- uber2.qar
	- uber2_gx.qar
	- readme.txt (this file)


OPENING THE PROJECT
-------------------

To open an archived Quartus project, please follow the instructions below:

1) Start Quartus II
2) Click on the "Project" menu item, select "Restore Archived Project..."
3) For the archive name, specify the full path of the archived project file
4) For the destination folder, specify a directory in which the project
will reside in
5) Click OK
6) Click OK when it asks whether Quartus should create the directory for you
7) Click OK when the "Project Restoration Complete" dialog box shows up
8) You now have the Quartus project opened inside Quartus


DESIGN DESCRIPTIONS
-------------------

--------------------------------------------------------------------------
Design: Twister

Target family: Cyclone

Description: 

Twister uses the following features:
	
	- LCELL, I/O, RAM, PLL and JTAG
	- Register packing with LCELLS and I/O's
	- Fast output register
	- Hierarchical LogicLock Regions (floating)

Twister also serves as a test case for the following:

	- Register packing honours lab clock regions, so it is forced to 
		not pack into at least one I/O. You should see two user 
		warning messages saying "Can't pack node
		<some-node-name> as a fast register"

	- Long node names are handled properly. Twister contains a node
		with very long name in xor_llr

--------------------------------------------------------------------------
Design: Uber2

Target family: Stratix

Description:

Uber2 uses the following features:

	- LCELL, I/O
	- MegaRAM
	- RAM
	- LVDS Receiver and Transmitter
	- PLL
	- MACs with and without scan chain connections
	- JTAG
	- Fast output register
	- Stratix Remote Update Block
	- Stratix CRC Block
	- Location constraint
	- Counter that uses carry chains

--------------------------------------------------------------------------	
Design: Uber2_gx

Target family: Stratix GX

Description:

Uber2 GX is the Straix GX version of Uber2. It uses the following features:

	- LCELL, I/O
	- MegaRAM
	- RAM
	- LVDS DPA Receive and Transmitter
	- PLL
	- MACs with and without scan chain connections
	- JTAG
	- Fast output register
	- Stratix Remote Update BLock
	- Stratix CRC Block
	- Location constraint
	- Counter that uses carry chains
	- 3.125 Gbps XAUI Quad
	- Stratix GX GXB Duplex
	- LVDS Receiver (non DPA mode)

--------------------------------------------------------------------------

Design: nios_ref_32_system.qar AND nios_standard_custom_instruction_32.qar

Target family: Stratix

Description:

These are the NIOS designs that come with the NIOS Development Kit. Both
are SOPC designs that feature a NIOS CPU. 

--------------------------------------------------------------------------


-- END OF FILE --
Quartus Version Number
--------------------------------------------------------------------------------
The Quartus version used to build this toolkit was:
Version 9.0 Build 132 02/25/2009 SJ Full Version
