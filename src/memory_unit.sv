module memory_unit 
    #(parameter MEM_ADDR_WIDTH = 10,
    parameter NUM_VECTORS = 5,
    parameter MIN_VEC_LENGTH = 16,
    parameter NUM_STREAM_ID = 5,
    parameter NUM_TILES_PER_SLICE = 20)
    (input logic clk,
    input logic rst,
    input logic mem_read_enable,
    input logic mem_write_enable,
    input logic [MEM_ADDR_WIDTH-1:0] address,
    input logic [NUM_VECTORS-1:0] vector_length, // Number of elements to load (1-20)
    input logic [MIN_VEC_LENGTH-1:0] write_data [0:NUM_TILES_PER_SLICE-1],
    output logic [MIN_VEC_LENGTH-1:0] read_data [0:NUM_TILES_PER_SLICE-1], // output vector
    output logic [NUM_STREAM_ID-1:0] output_stream_id,
    output logic mem_ready);
    
    timeunit 1ns;
    timeprecision 1ps;
    
    logic [MIN_VEC_LENGTH-1:0] data_memory [0:1023];
    logic [NUM_TILES_PER_SLICE-1:0] read_index;
    logic [NUM_TILES_PER_SLICE-1:0] write_index;
    
    // Vector initialization
    // TODO:  For now, hardcode values.  Future, load say from DDR via ARM
    initial begin
        data_memory[0]  = 16'h0001;
        data_memory[1]  = 16'h0002;
        data_memory[2]  = 16'h0003;
        data_memory[3]  = 16'h0004;
        data_memory[4]  = 16'h0005;
        data_memory[5]  = 16'h0006;
        data_memory[6]  = 16'h0007;
        data_memory[7]  = 16'h0008;
        data_memory[8]  = 16'h0009;
        data_memory[9]  = 16'h000A;
        data_memory[10] = 16'h000B;
        data_memory[11] = 16'h000C;
        data_memory[12] = 16'h000D;
        data_memory[13] = 16'h000E;
        data_memory[14] = 16'h000F;
        data_memory[15] = 16'h0010;        
    end
        
    always_ff @(posedge clk) begin
        if (rst) begin
            mem_ready <= 1'b0;
            read_index <= '0;
            write_index <= '0;
        end
        else begin
            if (mem_read_enable) begin
                read_data[read_index] <= data_memory[address + (read_index*2)]; // load vector elements                       
                read_index <= read_index + 1'b1;
                
                if (read_index == vector_length-1) begin
                    mem_ready <= 1'b1;
                end                                    
            end
            else if (mem_write_enable) begin
                data_memory[address + (write_index*2)] <= write_data[write_index];                                            
                write_index <= write_index + 1'b1;
                
                if (write_index == vector_length-1) begin
                    mem_ready <= 1'b1;
                end                    
            end                        
            else begin
                mem_ready <= 1'b0;
            end
        end
     end   
                             
endmodule : memory_unit
    