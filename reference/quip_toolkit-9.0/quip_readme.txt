Welcome to the Quartus University Interface Program (QUIP) kit!  This kit 
provides documentation, tutorials, data files and sample code to enable you to
enter and exit the Quartus II FPGA CAD suite at different stages.  With the 
information in this kit, plus a copy of Quartus II, you will be able to 
integrate your CAD tools and ideas into a complete FPGA CAD flow -- from 
Register Transfer Level (and even above) descriptions of circuits to programming
files for real FPGAs.

        
CONTENTS
--------------------------------------------------------------------------------
   I. What's new in 9.0?
  II. What can you do with QUIP?
 III. QUIP Advantages
  IV. Software Requirements
   V. Getting Started
  VI. Contents of this Release
 VII. Contacting us
VIII. Legal Notice 

I. What's new in 9.0?
--------------------------------------------------------------------------------
QUIP now contains additional device information.  The Altera Max II, Stratix
IIGX Cyclone III and Stratix III families are now included.  See
http://www.altera.com/products/devices/dev-index.jsp for more details on these
products.  

The 9.0 QUIP release continues to support the academic benchmark set. A high quality
benchmark set is an integral part of any research effort, but is often difficult
to assemble.  The circuits included in this release are larger and more recent 
than those in many existing benchmark sets, such as the MCNC benchmark set.  

In an effort to keep the QUIP benchmarks current, complete and fair we encourage 
you to submit any designs that might make good additions to the benchmark set. 
We also welcome any feedback regarding the current benchmark circuits.  We will
work hard to integrate your designs and feedback into future releases of the 
QUIP kit.

Please send any designs or feedback to quip@altera.com.


II.  What can you do with QUIP?
--------------------------------------------------------------------------------

QUIP is designed to enable university or other researchers to plug new CAD tools
and ideas into the Altera Quartus CAD flow.  QUIP describes Altera's devices, 
interfaces by which data can be sent into Quartus at various points in the 
CAD flow, and data formats in which data can be dumped out of Quartus.  This 
enables researchers to write point CAD tools that perform one CAD optimization
in a new or better way, and integrate their new CAD tool into a complete CAD 
flow so they can get realistic results on how this new idea improves circuit 
timing, routability, device utilization, compile time, or other metrics. 

Some of the CAD flows you could build with QUIP are:

1. Replace the Quartus Hardware Description Language (HDL) elaboration with 
   your own HDL elaboration.  You take in HDL, and output gates.  These gates 
   can then be fed into Quartus so it can complete the CAD flow -- logic 
   optimization, technology mapping, placement, routing and timing analysis.  
   You can then measure if you converted the HDL to gates in a way that led 
   to better timing or reduced device utilization.

2. Replace the Quartus technology mapping algorithm with a new one.  You 
   use Quartus to map any supported input format (VHDL, Verilog, schematics,
   etc.) into device primitives like logic cells.  Your tool would read in the 
   mapped netlist output from Quartus, re-optimize the logic and re-technology 
   map it into the circuit elements that exist in Altera chips -- logic cells, 
   RAMs, DSP blocks, etc.  You would then feed your technology-mapped netlist 
   back into Quartus so Quartus can complete the placement, routing and timing 
   analysis of the circuit.  You can even technology-map parts of the circuit, 
   and leave other parts as gates for Quartus to technology-map, so you can 
   test special-purpose technology mappers that only work well for certain 
   structures, or only understand some of the Altera device features.

3. Replace the Quartus placement algorithm with your own.  Your input is the
   technology-mapped netlist from Quartus, and your output is a placement to go
   back into Quartus.  You can even output partial placements -- place the parts
   of the circuit that your CAD tool understands (e.g. logic cells and IOs) and
   leave complex features (e.g. RAM and DSP blocks) for Quartus to place.

4. Add a floorplanner to the CAD flow.  You send a floorplan into Quartus
   as a set of constraints on the Quartus placement algorithm and see if you 
   can obtain better results than letting Quartus place the circuit without 
   your constraints.

5. Add a global router to the CAD flow.  You read the technology-mapped
   netlist and placement from Quartus, create a set of routing constraints 
   enforcing which channels should be used to route each signal, and send these
   constraints back into Quartus for detailed routing.

6. Perform physical synthesis.  Let Quartus completely implement a circuit,
   including placement and routing.  Based on the placement and the achieved 
   delays in this implementation, re-synthesize timing critical parts of the 
   circuit to increase the circuit speed, and feed this modified circuit 
   netlist back into Quartus.  You may choose to pass placement constraints 
   back into Quartus to try to keep the placement as similar as possible to the
   previous placement, or you may let Quartus completely re-place the circuit.

7. Develop an Engineering-Change-Order (ECO) flow.  Given an implementation of
   a circuit by Quartus, and a set of user modifications to the HDL of the 
   design, develop a method to modify the netlist, placement and routing of 
   Quartus so that the required changes are made as quickly and with as little 
   disturbance of the rest of the circuit as possible.


This is only a partial list -- many other CAD flows are possible.  To see some
of these CAD flows in action, you should go through the QUIP tutorial in 
tutorials/quip_tutorial/quip_tutorial.pdf.

If you have an interesting idea for a new CAD algorithm or flow, we may be
interested in supporting your research.  Contact quip@altera.com with the 
details of what you're planning if you would like to explore this.



III.  QUIP Advantages
-------------------------------------------------------------------------------- 

Some of the advantages of using QUIP to evaluate new CAD ideas instead of
the usual alternative of using a CAD flow based on entirely academic tools 
(e.g. SIS + RASP + VPR) are:

1. You plug into a complete flow that enables you to run benchmark circuits
   written in various hardware description languages (VHDL, Verilog, AHDL), or 
   captured in schematics, or even written in higher-level formats like Simulink
   and Matlab (via Altera's DSP Builder tool).  Since most circuits today are 
   written in hardware description languages, this powerful front-end lets you 
   run more real benchmarks than you can with current purely academic CAD flows.

2. You get industrial strength timing analysis, so comparisons of delay will 
   be of high-quality.  Since the Quartus timing analyzer is very 
   full-featured, you can evaluate the speed of circuits in many ways:
   clock speed, setup time from input pins (Tsu), clock to out time on output
   pins (Tco) and so on.

3. You can also test your new CAD algorithms against those in Quartus to see 
   if you can outperform a state-of-the-art industrial tool.  If you can, we 
   will certainly be interested in your results!

4. You can get real programming files for real devices, so you can test new
   circuit techniques in hardware if you wish. 

5. Since we are releasing all the details of our devices, you can investigate
   CAD algorithms for the more complex features in modern FPGAs that are usually
   abstracted away in academic CAD flows.  On the other hand, if these complex 
   features are not of interest to you, you can ignore them to get a simpler 
   CAD flow going that will still work for simpler benchmark circuits.

6. Since Quartus includes simulation support, you can test that any new 
   synthesis algorithms you develop in fact produce correct circuits, by 
   simulating the circuits with your algorithm on and off and checking that the 
   output is the same.

7. Quartus includes many visualization features that are useful in debugging
   and optimizing CAD tools.



IV. SOFTWARE REQUIREMENTS
--------------------------------------------------------------------------------

You will need the Quartus II version 9.0 software or later, in addition to the
material contained in this kit.  To obtain Quartus please fill out the 
University enrollment form at
https://www.altera.com/education/univ/enroll_form/unv-enroll_form.jsp and 
send it to Ralene Marcoccia, via email to RMARCOCC@altera.com or by fax 
to 408-544-6666 or via regular mail to:

	Ralene Marcoccia
	Altera Corporation
	101 Innovation Drive
	San Jose, CA 95134
	USA
	
If you want to get started right away, you can use the Quartus II version 9.0 
Web edition.  This will be fine for the Quartus tutorial, but you'll run into 
a few limitations with the QUIP Tutorial as it uses the Chip Editor, and the 
web edition doesn't have the Chip Editor enabled.  
For those portions of the tutorial that use the Chip Editor, you can mostly use
the Quartus Floorplan editor (which is enabled in the web edition) as an 
alternative.

Quartus II version 9.0 web edition can be found at:

https://www.altera.com/support/software/download/altera_design/quartus_we/dnl-quartus_we.jsp

You must follow the instructions carefully, which include both downloading the 
software and requesting a license from the automated license server.

Also note that should your research require FPGA devices (such as Stratix or 
Cyclone FPGAs) or FPGA development boards (such as the Nios Development Kit, 
Stratix Edition), Altera offers devices to University researchers at heavily 
discounted rates and sometimes as grants.
See http://www.altera.com/products/devkits/kit-dev_platforms.jsp for a list of 
the development kits (and list prices, which are higher than the University 
prices).


V. GETTING STARTED
--------------------------------------------------------------------------------
	
There are two tutorials in this release.  If you are unfamiliar with the 
general use of Quartus, go to the directory tutorials/quartus_tutorial and do 
the tutorial in the file quartus_tutorial.pdf.  (You'll need Adobe Acrobat 
Reader to read this).  

If you're familiar with Quartus, you can start with the QUIP tutorial, which 
shows you the basic ways of interfacing with Quartus II at different stages in the
CAD flow.  The QUIP Tutorial can be found in the directory 
tutorials/quip_tutorial in the file quip_tutorial.pdf.

VI. CONTENTS OF THIS RELEASE
--------------------------------------------------------------------------------

Beyond the tutorials, this release consists of documentation, device files and 
executable code that contain details on different aspects of the Quartus CAD 
flow, interfaces into and out of the flow, information about the FPGA chips that 
Quartus targets, and software interfaces that make it easy to automatically 
collect the data you'll need to create CAD tools that plug into the flow.
These are grouped into separate directories, the contents of which are 
summarized below:


  i)  Documentation that provides useful reference information and describes 
      the provided interfaces.  All documents can be found in the 
      documents directory.
  
      The documents provided include:

	-  qsf_assignment_descriptions.pdf, which describes how to take your 
           placement output and insert it into the Quartus II flow.

	-  quip_synthesis_interface.pdf, which describes how to communicate 
	   netlists between Quartus and SIS, and suggested flows for synthesis
 	   comparisons and research.

	-  quip_benchmarking.pdf, which describes how to set constraints and
	   extract appropriate information from Quartus to fairly compare 
	   timing, area (resource use) or wiring requirements between different
	   CAD tools or algorithms.

	-  quip_benchmarks.pdf summarizes the characteristics of the benchmark
	   circuits that ship with QUIP.

	-  vqmx_doc.pdf, which describes a file format used to pass a primitive 
	   design (only wires, logic blocks, pins, etc.) to the Quartus flow.
		
	-  altera_xml_architecture_description_file_detailed_design.pdf, which 
	   describes the file format used to provide all the essential 
	   information about Altera FPGA architectures.
	   
	-  constrained_routing_tutorial_and_reference.pdf, which describes how 
	   to specify or change routing for designs in Quartus.
	   
	-  altera_xml_point_to_point_delay_file_detailed_design.pdf, which 
	   describes the file format used to provide intra-cell delays for 
	   Altera blocks.  These delays are between input and output ports 
	   on a given block, and are also known as point-to-point delays.
	   
	-  altera_eda_pldm_specifications.pdf, which describes the provided
	   Placer Delay Model (PLDM) interface used to obtain inter-cell delay
	   estimates for Altera devices.  These delays are between two blocks 
	   on a given Altera device as a function of their locations on the
	   device.
       
	-  altera_xml_psdf_delay_file_detailed_Design.pdf, which describes 
	   the file format of Physical Synthesis Data Format (PSDF) XML files
	   that contain physical synthesis related information for a circuit.
	   Some examples of PSDF data include interconnect delays, atom
	   locations, register packing in IOs, LUT input permutations and
	   pin assignments.  The document also describes how to generate this
	   information for a given design.
       
	-  <device_family>_eda_<blockname>_fd.pdf. 
	   These documents list guidelines and suggestions on how to implement
	   CAD tools that respect the hardware constraints of a device family,
	   and for some documents, a specific type of block (e.g. RAM) within
	   that family.
	
	-  <device_family><blockname>_wys.pdf. Each of these files 
           provides details on how a specific type of block (e.g. LE, DSP block,
           RAM blocks, etc) functions on a specific device family, and details
           how to instantiate such a block in a vqm format netlist.

        -  stratix_wysuser.pdf, which provides details about the logic cells
           and IO cells on Stratix devices.
	   

 ii)  Reference data and source files necessary for development of CAD tools for       
      Altera devices.  This section contains architecture and timing data for 
      Altera devices that are necessary to develop valid and effective CAD 
      tools.
      
      The provided files include:
      
	-  Full specifications of Altera device architectures for the Stratix, 
	   Cyclone, Stratix GX, Cyclone II and Stratix II, MAX II, Stratx IIGX,
 	   Stratix III and Cyclone III families.  The specifications are given in
	   XML format and can be found in the data/architectures directory.  For
	   detailed descriptions of how to parse these files, please see
	   altera_xml_architecture_description_file_detailed_design.pdf
           in the documents directory.
           
	-  Intra-cell timing information for the Stratix, Cyclone, Stratix GX,
	   Cyclone II and Stratix II families.  The information is provided in
	   XML format and can be found in the data/intracelldelays directory.  
	   For a detailed description of how to parse these files, please see
           altera_xml_point_to_point_delay_file_detailed_design.pdf,
           in the documents directory.
           
	-  Inter-cell timing information for the Stratix, Cyclone, Stratix GX,
	   Cyclone II and Stratix II families.  The information is provided
	   through a software interface known as the Placer Delay Model (PLDM).
	   This represents a simple to use C software interface that provides
	   all inter-cell timing information.  The source files and reference 
           data are provided in the data/intercelldelays directory.
      
          
iii)  Interactive examples that show how to use some of the key interfaces to
      the Quartus CAD flow.

      The examples provided include:
      
      -  How to specify and alter routing for an Altera design.  The example
         is used in conjunction with the
         constrained_routing_tutorial_and_reference.pdf document and all
         necessary source files can be found in examples/constrained_routing.
           
      -  How to use the PLDM software interface to retrieve inter-cell timing
         information for Altera devices.  This example shows how one would
         interface with the provided software API and the necessary source 
         files are provided in examples/api_demo/demos_quip.tar.gz.  
         Please expand the archive and view the readme file for full 
         instructions on how to use the demo.
           
      -  How to extract architecture and intra-cell timing information from 
         the provided XML files.  This demonstration provides a C++ example 
         of how one would parse through the provided XML files and obtain
         important information.  The demonstration is also provided in the 
         examples/api_demo/demos_quip.tar.gz archive.  Please expand the
         archive and view the readme file for full instructions on how to
         use the demo.

 iv)  Utilities that facilitate development and research with Altera devices.  
      The utilities provided include:

      -  Automatic conversion from academic netlist formats to Altera 
         compatible netlists.  The Net TO VQM utility accepts as input a
         .net netlist compatible with the popular academic Versatile Place and
         Route (VPR) tool and provides as output a Verilog-to-Quartus (VQM)
         netlist that is compatible with the Quartus II design software.  The
         source code for the utility is provided in utils/nettovqm directory.
         For full instructions on how to use Net To VQM, please see the file
         README_nettovqm.txt in the same directory.
	   
      -  For a vqm file parser, contact Prof. Andrew Kennings at the
         University of Waterloo: akenning@cheetah.vlsi.uwaterloo.ca

  v)  The two tutorials described in section II of this file in the tutorials
      directory.
	
      -  The tutorials/quartus_tutorial/quartus_tutorial.pdf file provides a
         good starting point for users new to Quartus II.
        
      -  The tutorials/quip_tutorial/quip_tutorial.pdf file provides a good 
         starting point for users familiar with Quartus II or a next step for 
         those who have worked through the quartus_tutorial.pdf file already.
	  
 vi)  A set of reference benchmarks designs can be found in the benchmarks
      directory. This is a mixed set of Verilog and VHDL based designs. A
      characterization of each circuit can be found in the file
      documents/quip_benchmarks.pdf. This document also provides easy 
      instructions for using the benchmark designs in your own research.
      
      The document documents/quip_benchmarks.pdf describes best practice 
      methods for extracting benchmark performance and density metrics from any 
      set of benchmark circuits.
      

VII. CONTACTING US
--------------------------------------------------------------------------------

You can contact us at via email at quip@altera.com, or by posting a question to
the comp.arch.fpga news group.  

We will answer questions about how to use QUIP, and if you have suggestions 
about extra information that would be useful to you in future versions of QUIP 
we'd be interested in hearing them.  Finally, if you are doing a research 
project that's of interest to us, we may be interested in financially 
supporting the research.


VIII. LEGAL NOTICE
--------------------------------------------------------------------------------

All files in the QUIP download archive are the copyrighted property of Altera 
Corporation, San Jose, California, USA. All rights reserved.  Your use of the 
Quartus II development software is expressly subject to the terms and conditions 
of the Quartus II "Program License Subscription Agreement" 
(https://www.altera.com/support/software/download/license/lic-prog_lic.html) or 
other applicable license agreement.  Please refer to the applicable agreement 
for further details.

The design examples, code examples, documentation and data files contained in 
the QUIP download archive are being provided on an "as-is" basis and as an 
accommodation and therefore all warranties, representations or guarantees of 
any kind (whether express, implied or statutory) including, without limitation, 
warranties of merchantability, non-infringement, or fitness for a particular 
purpose, are specifically disclaimed.  IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE QUIP DOWNLOAD ARCHIVE.

Quartus Version Number
--------------------------------------------------------------------------------
The Quartus version used to build this toolkit was:
Version 9.0 Build 132 02/25/2009 SJ Full Version
