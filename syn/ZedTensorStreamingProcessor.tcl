create_project -force ZedTensorStreamingProcessor ./ZedTensorStreamingProcessor -part xc7z020clg484-1
set_property board_part digilentinc.com:zedboard:part0:1.1 [current_project]

# Sources (synthesizable)
add_files -norecurse ./ZedTensorStreamingProcessorTop.sv
update_compile_order -fileset sources_1

# Block diagram for ARM and DDR interface
create_bd_design "design_TSP"
update_compile_order -fileset sources_1
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
endgroup

apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {sys_clock ( System clock ) } Manual_Source {Auto}}  [get_bd_pins clk_wiz_0/clk_in1]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Manual_Source {New External Port (ACTIVE_HIGH)}}  [get_bd_pins clk_wiz_0/reset]

connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]

assign_bd_address
# validate_bd_design # Make sure design is properly validated!
save_bd_design

make_wrapper -files [get_files ./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.srcs/sources_1/bd/design_TSP/design_TSP.bd] -top
add_files -norecurse ./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.gen/sources_1/bd/design_TSP/hdl/design_TSP_wrapper.v

update_compile_order -fileset sources_1



# Simulation files (non-synthesizable)
add_files -fileset sim_1 -norecurse ../sim/ZedTensorStreamingProcessorTestBench.sv

# Add constraints
add_files -fileset constrs_1 -norecurse ./ZedTensorStreamingProcessor.xdc


