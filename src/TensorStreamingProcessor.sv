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
    output logic [31:0] instruction_out);
    
    timeunit 1ns;
    timeprecision 1ps;
    
    localparam integer INSTR_WIDTH = 32;
    localparam integer INSTR_MEM_ADDR_WIDTH = 10; // support 1024 instructions
    localparam integer NUM_TILES_PER_SLICE = 20; // We have 20 tiles per vertical slice
    localparam integer MIN_VEC_LENGTH = 16; // The smallest vector length is 16, to a maximum of NUM_TILES_PER_SLICE*MIN_VEC_LENGTH = 320
    localparam integer NUM_STREAM_ID = 5; // We have 2**NUM_STREAM_ID total SRFs.  So, by default, we have 32 SRFs
    localparam integer DATA_MEM_ADDR_WITH = 10;
    localparam integer NUM_VECTORS = 5; // num of elements : 1 - 20    
    
    logic [INSTR_WIDTH-1:0] instr;
    logic [INSTR_MEM_ADDR_WIDTH-1:0] instr_address;
    logic instr_valid;
    
    
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
         .mem_read_enable(),
         .mem_write_enable(),
         .mem_address(),
         .vector_length(),
     
          // SRF control
          .srf_read_enable(),
          .srf_write_enable(),
          .stream_src1(),
          .stream_src2(),
          .stream_dest(),
          .write_stream(),
          .srf_data1(),
          .srf_data2(),
          .write_data(), // Data from SRF to store in memory
     
            // VXM control
            .vxm_enable(),
            .operand1(),
            .operand2(),
            .vxm_result());
     
    instruction_memory 
        #(.INSTR_WIDTH(INSTR_WIDTH),
         .INSTR_MEM_ADDR_WIDTH(INSTR_MEM_ADDR_WIDTH)
         ) instruction_memory_inst
            (.*,// clk, rst
             .instr_out(instr),
             .instr_valid(instr_valid),
             .address(instr_address));
                            
             
     assign instruction_out = instr; // for debugging
    
endmodule : TensorStreamingProcessor