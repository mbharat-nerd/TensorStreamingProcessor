/*
 Top level tensor streaming processor
 Instantiates ICU (Instruction Control Unit), VXM (Vector Execution Unit),
 memories and SRF (Streaming Register File)
 
 Bharathwaj Muthuswamy
 bharathwaj.muthuswamy@gmail.com
 */
 
module TensorStreamingProcessor (
    input logic clk,
    input logic rst, // synchronous reset
    output logic [31:0] vxm_result_out);
    
    timeunit 1ns;
    timeprecision 1ps;
    
    localparam integer INSTR_WIDTH = 32;
    localparam integer INSTR_MEM_ADDR_WIDTH = 10; // support 1024 instructions
    localparam integer NUM_TILES_PER_SLICE = 20; // We have 20 tiles per vertical slice
    localparam integer MIN_VEC_LENGTH = 16; // The smallest vector length is 16, to a maximum of NUM_TILES_PER_SLICE*MIN_VEC_LENGTH = 320
    localparam integer NUM_STREAM_ID = 5; // We have 2**NUM_STREAM_ID total SRFs.  So, by default, we have 32 SRFs
    localparam integer DATA_MEM_ADDR_WIDTH = 10;
    localparam integer NUM_VECTORS = 5; // num of elements : 1 - 20    
    
    logic [INSTR_WIDTH-1:0] instr;
    logic [INSTR_MEM_ADDR_WIDTH-1:0] instr_address;
    logic instr_valid;
    
    logic mem_read_enable, mem_write_enable, mem_ready;
    logic [DATA_MEM_ADDR_WIDTH-1:0] data_mem_address;
    logic [NUM_VECTORS-1:0] vector_length;
    logic [MIN_VEC_LENGTH-1:0] write_data [0:NUM_TILES_PER_SLICE-1];
    logic [MIN_VEC_LENGTH-1:0] read_data [0:NUM_TILES_PER_SLICE-1];
    logic [NUM_STREAM_ID-1:0] output_stream_id;
    
    logic srf_read_enable, srf_write_enable;
    logic [NUM_STREAM_ID-1:0] stream_src1, stream_src2, stream_dest;
    logic [MIN_VEC_LENGTH-1:0] srf_data1 [0:NUM_TILES_PER_SLICE-1];
    logic [MIN_VEC_LENGTH-1:0] srf_data2 [0:NUM_TILES_PER_SLICE-1];
    
    logic vxm_enable;
    logic [1:0] vxm_operation;
    logic [MIN_VEC_LENGTH-1:0] operand1 [0:NUM_TILES_PER_SLICE-1];
    logic [MIN_VEC_LENGTH-1:0] operand2 [0:NUM_TILES_PER_SLICE-1];
    logic [MIN_VEC_LENGTH-1:0] vxm_result [0:NUM_TILES_PER_SLICE-1];
    
    
    icu_dispatcher
        #(.INSTR_WIDTH(INSTR_WIDTH),
          .INSTR_MEM_ADDR_WIDTH(INSTR_MEM_ADDR_WIDTH),
          .NUM_VECTORS(NUM_VECTORS),
          .NUM_STREAM_ID(NUM_STREAM_ID),
          .MIN_VEC_LENGTH(MIN_VEC_LENGTH),
          .NUM_TILES_PER_SLICE(NUM_TILES_PER_SLICE))
        icu 
        (.*, // clk, rst and other signals
          // Instruction memory         
          .instr_in(instr),
     
          // Data memory control
         .mem_read_enable(mem_read_enable), // read is unused because of latency
         .mem_write_enable(mem_write_enable),
         .mem_address(data_mem_address),
         .vector_length(vector_length),
          
         .srf_read_enable(srf_read_enable),
         .srf_write_enable(srf_write_enable),
         .stream_src1(stream_src1),
         .stream_src2(stream_src2),
         .stream_dest(stream_dest),
         .write_stream(),
         .srf_data1(srf_data1),
         .srf_data2(srf_data2),
         .write_data(), // Data from SRF to store in memory
                 
          .vxm_enable(vxm_enable),
          .vxm_operation(vxm_operation),
          .operand1(operand1),
          .operand2(operand2),
          .vxm_result(vxm_result));
     
    instruction_memory 
        #(.INSTR_WIDTH(INSTR_WIDTH),
          .INSTR_MEM_ADDR_WIDTH(INSTR_MEM_ADDR_WIDTH))
         instruction_memory_inst
            (.*,// clk, rst
             .instr_out(instr),
             .instr_valid(instr_valid),
             .address(instr_address));
    
    memory_unit 
        #(.MEM_ADDR_WIDTH(DATA_MEM_ADDR_WIDTH),
          .NUM_VECTORS(NUM_VECTORS),
          .MIN_VEC_LENGTH(MIN_VEC_LENGTH),
          .NUM_STREAM_ID(NUM_STREAM_ID),
          .NUM_TILES_PER_SLICE(NUM_TILES_PER_SLICE))
        data_memory_inst 
        (.*, // clk, rst and other signals        
         .address(data_mem_address),
         .vector_length(vector_length), // Number of elements to load (1-20)
         .write_data(write_data),
         .read_data(read_data), // output vector
         .output_stream_id(output_stream_id),
         .mem_ready(mem_ready));         
         
    streaming_register_file
    #(.NUM_STREAM_ID(NUM_STREAM_ID),
      .MIN_VEC_LENGTH(MIN_VEC_LENGTH),
      .NUM_TILES_PER_SLICE(NUM_TILES_PER_SLICE))
      srf_inst (.*,       
                .write_data());               
                
    vxm_slice
    #(.MIN_VEC_LENGTH(MIN_VEC_LENGTH),
      .NUM_TILES_PER_SLICE(NUM_TILES_PER_SLICE))
       vxm_inst (.*,    
                 .operation(vxm_operation),
                 .srf_data1(operand1),
                 .srf_data2(operand2), 
                 .vxm_result(vxm_result));
             
    // We concatenate the Most Significant Word and the Least Significant Word in the result, so
    // the vxm module actually synthesizes             
    assign vxm_result_out = {vxm_result[NUM_TILES_PER_SLICE-1],vxm_result[0]};
    
endmodule : TensorStreamingProcessor