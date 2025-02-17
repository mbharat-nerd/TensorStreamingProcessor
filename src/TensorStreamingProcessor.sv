/*
 Top level tensor streaming processor
 Instantiates ICU (Instruction Control Unit), VXM (Vector Execution Unit),
 memories and SRF (Streaming Register File)
 
 Bharathwaj Muthuswamy
 bharathwaj.muthuswamy@gmail.com
 */
 
module TensorStreamingProcessor (
    input logic clk,
    input logic rst);
    
    timeunit 1ns;
    timeprecision 1ps;
    
    localparam integer INSTRUCTION_WIDTH = 32;
    localparam integer NUM_TILES_PER_SLICE = 20; // We have 20 tiles per vertical slice
    localparam integer MIN_VEC_LENGTH = 16; // The smallest vector length is 16, to a maximum of NUM_TILES_PER_SLICE*MIN_VEC_LENGTH = 320
    localparam integer NUM_ = 5; // We have 2**NUM_BITS_SRF re 
    
    wire [INSTRUCTION_WIDTH-1:0] instruction_in;
    wire instruction_valid, fifo_empty;
    wire [MIN_VEC_LENGTH-1:0] srf_data1 [0:NUM_TILES_PER_SLICE-1];
    wire [MIN_VEC_LENGTH-1:0] srf_data2 [0:NUM_TILES_PER_SLICE-1];
     
    
endmodule : TensorStreamingProcessor