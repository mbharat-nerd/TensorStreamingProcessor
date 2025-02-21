# TensorStreamingProcessor

[UPDATE]:  I am getting busy with work, so I will only revisit this project in Summer (June) 2025.

Folder structure:

`syn/` - has board specific top level, tcl and constraints files

`sim/` - simulation sources

`src/` - Generic (FPGA agnostic) source files

`doc/` - project documentation

# Creating Vivado 2021.1 project for Zedboard

You **must first** install the Digilent zedboard file from: https://github.com/Digilent/vivado-boards.  Follow instructions
on the Digilent github site.  Another option is to comment out the `set_property` in the TCL file, but then understand
that you have to manually configure the ARM subsystem.

Also, this project has only been tested on Vivado 2021.1.  For other versions of Vivado, you have to recreate IPs like the PLL
etc.

# Migrating to other FPGA boards

You need only copy the `ZedTensorStreamingProcessor.tcl` and modify it to suit your needs.  You of course also need to provide
the correct top level file and constraints.  The FPGA agnostic sources should correctly synthesize to BRAMs etc.

# Detailed Documentation

Please see the `doc/` folder.




