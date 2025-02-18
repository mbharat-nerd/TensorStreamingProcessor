module streaming_register_file
    #(parameter NUM_STREAM_ID = 5,
      parameter MIN_VEC_LENGTH = 16,
      parameter NUM_TILES_PER_SLICE = 20)
      (input logic clk,
       input logic rst,
       input logic srf_write_enable,
       input logic [NUM_STREAM_ID-1:0] stream_id, // stream to write into
       input logic [MIN_VEC_LENGTH-1:0] write_data [0:NUM_TILES_PER_SLICE-1],
       output logic [MIN_VEC_LENGTH-1:0] srf_data [0:NUM_TILES_PER_SLICE-1]);
       
    timeunit 1ns;
    timeprecision 1ps;

    localparam integer NUM_STREAM_REGISTERS = 32;
    logic [MIN_VEC_LENGTH-1:0] stream_registers[0:NUM_STREAM_REGISTERS-1][0:NUM_TILES_PER_SLICE-1]; // 32 streams, 20 tiles each
    
    always_ff @(posedge clk) begin
        if (rst) begin
            for(int i = 0;i < NUM_STREAM_REGISTERS-1;i++) begin
                for(int j = 0;j < NUM_TILES_PER_SLICE;j++) begin
                    stream_registers[i][j] <= '0;
                end
            end
        end
        else begin
            if (srf_write_enable) begin
                for(int i = 0;i < NUM_TILES_PER_SLICE;i++) begin
                    stream_registers[stream_id][i] = write_data[i];
                end
            end
        end                                            
    end    
    
    always_ff @(posedge clk) begin        
        for(int i = 0;i < NUM_TILES_PER_SLICE;i++) begin
                srf_data[i] <= stream_registers[stream_id][i];        
        end
    end

endmodule : streaming_register_file