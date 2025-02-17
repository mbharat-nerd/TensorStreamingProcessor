/*
 Top level tensor streaming processor
 Instantiates ICU (Instruction Control Unit), VXM (Vector Execution Unit),
 memories and SRF (Streaming Register File)
 
 Bharathwaj Muthuswamy
 bharathwaj.muthuswamy@gmail.com
 */
 
module TensorStreamingProcessor (
    input logic clk,
    input logic rst,
    output logic [31:0] instruction_out);
    
    timeunit 1ns;
    timeprecision 1ps;
    
    localparam integer INSTR_WIDTH = 32;
    localparam integer INSTR_MEM_ADDR_WIDTH = 10; // support 1024 instructions
    localparam integer NUM_TILES_PER_SLICE = 20; // We have 20 tiles per vertical slice
    localparam integer MIN_VEC_LENGTH = 16; // The smallest vector length is 16, to a maximum of NUM_TILES_PER_SLICE*MIN_VEC_LENGTH = 320
    localparam integer NUM_STREAM_ID = 5; // We have 2**NUM_STREAM_ID total SRFs.  So, by default, we have 32 SRFs
    localparam integer DATA_MEM_ADDR_WITH = 10;
    
    wire [INSTR_WIDTH-1:0] instr_in;
    wire instruction_valid, fifo_empty;
    wire [MIN_VEC_LENGTH-1:0] srf_data1 [0:NUM_TILES_PER_SLICE-1];
    wire [MIN_VEC_LENGTH-1:0] srf_data2 [0:NUM_TILES_PER_SLICE-1];
    
    
    instruction_memory 
        #(.INSTR_WIDTH(INSTR_WIDTH),
         .INSTR_MEM_ADDR_WIDTH(INSTR_MEM_ADDR_WIDTH)
         ) instruction_memory_inst
            (.*,// clk, rst
             .instr_out(instr_in),
             .address('h0));
                            
             
     assign instruction_out = instr_in; // for debugging
    
endmodule : TensorStreamingProcessor