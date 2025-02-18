module memory_unit 
    #(parameter MEM_ADDR_WIDTH = 10,
    parameter NUM_VECTORS = 5,
    parameter MIN_VEC_LENGTH = 16,
    parameter NUM_TILES_PER_SLICE = 20)
    (input logic clk,
    input logic rst,
    input logic mem_read_enable,
    input logic mem_write_enable,
    input logic [MEM_ADDR_WIDTH-1:0] address,
    input logic [NUM_VECTORS-1:0] vector_length, // Number of elements to load (1-20)
    input logic [MIN_VEC_LENGTH-1:0] write_data [0:NUM_TILES_PER_SLICE-1],
    output logic [MIN_VEC_LENGTH-1:0] read_data [0:NUM_TILES_PER_SLICE-1], // output vector
    output logic [NUM_STREAD_ID-1:0] output_stream_id,
    output logic mem_ready);
    
    timeunit 1ns;
    timeprecision 1ps;
    
    logic [MIN_VEC_LENGTH-1:0] data_memory [0:1023];
    
    // Vector initialization
    // TODO:  For now, load from file
    initial begin
        $readmemh("vector_data.hex", data_memory);
    end
        
    always_ff @(posedge clk) begin
        if (rst) begin
            mem_ready <= 1'b0;
        end
        else begin
            if (mem_read_enable) begin
                for(int i = 0;i < NUM_TILES_PER_SLICE; i++) begin
                    read_data[i] <= (i < vector_length) ? data_memory[address + (i*2)] : '0; // load vector elements                    
                end    
                mem_ready <= 1'b1;
            end
            else if (mem_write_enable) begin
                for(int i = 0;i < NUM_TILES_PER_SLICE; i++) begin
                        if (i < vector_length)
                            data_memory[address + (i*2)] <= write_data[i];                                            
                end
                mem_ready <= 1'b1;
            end                        
            else begin
                mem_ready <= 1'b0;
            end
        end
     end   
                             
endmodule : memory_unit
    