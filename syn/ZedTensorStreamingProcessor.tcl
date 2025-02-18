create_project -force ZedTensorStreamingProcessor ./ZedTensorStreamingProcessor -part xc7z020clg484-1
set_property board_part digilentinc.com:zedboard:part0:1.1 [current_project]

# Sources (synthesizable)
add_files -norecurse ./ZedTensorStreamingProcessorTop.sv
add_files -norecurse ../src/TensorStreamingProcessor.sv
add_files -norecurse ../src/icu_dispatcher.sv
add_files -norecurse ../src/streaming_register_file.sv
add_files -norecurse ../src/vector_execution_unit.sv
add_files -norecurse ../src/vxm_slice.sv
add_files -norecurse ../src/memory_unit.sv
add_files -norecurse ../src/instruction_memory.sv

# Clock buffer(s)
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
generate_target {instantiation_template} [get_files ./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]
update_compile_order -fileset sources_1
generate_target all [get_files  ./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]
catch { config_ip_cache -export [get_ips -all clk_wiz_0] }
export_ip_user_files -of_objects [get_files ./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]
export_simulation -of_objects [get_files ./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci] -directory ./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.ip_user_files/sim_scripts -ip_user_files_dir ./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.ip_user_files -ipstatic_source_dir ./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.ip_user_files/ipstatic -lib_map_path [list {modelsim=./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.cache/compile_simlib/modelsim} {questa=./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.cache/compile_simlib/questa} {ies=./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.cache/compile_simlib/ies} {xcelium=./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.cache/compile_simlib/xcelium} {vcs=./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.cache/compile_simlib/vcs} {riviera=./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet


update_compile_order -fileset sources_1

# Block diagram for ARM and DDR interface - commented out till TSP subsystem is functional
# TSP code will be uploaded TSP ICU BRAMs by C code running on ARM
#create_bd_design "design_TSP"
#update_compile_order -fileset sources_1
#startgroup
#create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
#create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
#endgroup

#apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

#apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {sys_clock ( System clock ) } Manual_Source {Auto}}  [get_bd_pins clk_wiz_0/clk_in1]
#apply_bd_automation -rule xilinx.com:bd_rule:board -config { Manual_Source {New External Port (ACTIVE_HIGH)}}  [get_bd_pins clk_wiz_0/reset]

#connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]

#assign_bd_address
# validate_bd_design # Make sure design is properly validated!
#save_bd_design

#make_wrapper -files [get_files ./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.srcs/sources_1/bd/design_TSP/design_TSP.bd] -top
#add_files -norecurse ./ZedTensorStreamingProcessor/ZedTensorStreamingProcessor.gen/sources_1/bd/design_TSP/hdl/design_TSP_wrapper.v

#update_compile_order -fileset sources_1

# Simulation files (non-synthesizable)
add_files -fileset sim_1 -norecurse ../sim/ZedTensorStreamingProcessorTestBench.sv
add_files -fileset sim_1 -norecurse ../sim/ZedTensorStreamingProcessorTestBench_behav.wcfg
set_property xsim.view ../sim/ZedTensorStreamingProcessorTestBench_behav.wcfg [get_filesets sim_1]

# Add constraints
add_files -fileset constrs_1 -norecurse ./ZedTensorStreamingProcessor.xdc


