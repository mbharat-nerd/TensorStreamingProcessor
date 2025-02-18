module icu_dispatcher 
    #(parameter INSTR_WIDTH = 32,
      parameter INSTR_MEM_ADDR_WIDTH = 10,
      parameter NUM_VECTORS = 5,
      parameter NUM_STREAM_ID = 5,
      parameter MIN_VEC_LENGTH = 16,
      parameter NUM_TILES_PER_SLICE = 20)
    (input logic clk,
     input logic rst,
     
     // Instruction memory
     input logic instr_valid,
     output logic [INSTR_MEM_ADDR_WIDTH-1:0] instr_address,
     input logic [INSTR_WIDTH-1:0] instr_in,
     
     // Data memory control
     output logic mem_read_enable,
     output logic mem_write_enable,
     output logic [INSTR_MEM_ADDR_WIDTH-1:0] mem_address,
     output logic [NUM_VECTORS-1:0] vector_length,
     
     // SRF control
     output logic srf_read_enable,
     output logic srf_write_enable,
     output logic [NUM_STREAM_ID-1:0] stream_src1,
     output logic [NUM_STREAM_ID-1:0] stream_src2,
     output logic [NUM_STREAM_ID-1:0] stream_dest,
     output logic [NUM_STREAM_ID-1:0] write_stream,
     input logic [MIN_VEC_LENGTH-1:0] srf_data1 [0:NUM_TILES_PER_SLICE-1],
     input logic [MIN_VEC_LENGTH-1:0] srf_data2 [0:NUM_TILES_PER_SLICE-1],
     output logic [MIN_VEC_LENGTH-1:0] write_data [0:NUM_TILES_PER_SLICE-1], // Data from SRF to store in memory
     
     // VXM control
     output logic vxm_enable,
     output logic [1:0] vxm_operation,
     output logic [MIN_VEC_LENGTH-1:0] operand1 [0:NUM_TILES_PER_SLICE-1],
     output logic [MIN_VEC_LENGTH-1:0] operand2 [0:NUM_TILES_PER_SLICE-1],
     input logic [MIN_VEC_LENGTH-1:0] vxm_result [0:NUM_TILES_PER_SLICE-1]);
     
     timeunit 1ns;
     timeprecision 1ps;          
     
     logic srf_read_enable_pipeline;
     logic vxm_enable_pipeline_stage1, vxm_enable_pipeline_stage2;
     logic [1:0] vxm_operation_pipeline_stage1, vxm_operation_pipeline_stage2; 
     
     always_ff @(posedge clk) begin
        if (rst) begin
            instr_address <= '0;
            mem_read_enable <= '0;
            mem_write_enable <= '0;
            srf_read_enable <= '0;
            srf_write_enable <= '0;                                  
        end            
        else begin       
            // Default Deassertions
            mem_read_enable  <= '0;
            mem_write_enable <= '0;
            srf_read_enable  <= '0;
            srf_write_enable <= '0;        
            if (instr_valid) begin
                case(instr_in[31:24])
                    8'h01: begin // Read a,s (UNUSED)
                        mem_read_enable <= 1'b1;
                        srf_write_enable <= 1'b1;
                        mem_address <= instr_in[23:14];
                        stream_dest <= instr_in[13:9];
                        vector_length <= instr_in[8:4];
                    end
                    
                    8'h03: begin // Add stream_src1, stream_src2, stream_dest
                        srf_read_enable <= 1'b1;
                        stream_src1 <= instr_in[4:0];
                        stream_src2 <= instr_in[9:5];
                        stream_dest <= instr_in[14:10];                                                                                                
                    end     
                    
                    8'h04: begin // Write s, a
                        srf_read_enable <= 1'b1;
                        mem_write_enable <= 1'b1;
                        mem_address <= instr_in[23:14];
                        write_stream <= instr_in[13:9];
                        vector_length <= instr_in[8:4];
                        
                        // Read data from the SRF stream that needs to be written
                        for (int i = 0; i < NUM_TILES_PER_SLICE; i++) begin
                            write_data[i] <= srf_data1[i];  
                        end
                    end                                      
                endcase                                                         
            end                  
            instr_address <= instr_address + 1'b1;
         end
     end               
          
          
     always_ff @(posedge clk) begin
            if (rst) begin
                srf_read_enable_pipeline <= 1'b0;
                vxm_enable_pipeline_stage1 <= 1'b0;
                vxm_enable_pipeline_stage2 <= 1'b0;
                vxm_operation_pipeline_stage1 <= 2'b11;
                vxm_operation_pipeline_stage2 <= 2'b11;

                for (int i = 0; i < NUM_TILES_PER_SLICE; i++) begin      
                    operand1[i] <= 0;
                    operand2[i] <= 0;
                end
            end
            else begin
                // ✅ Delay read enable so operands are captured AFTER `srf_data1` is valid
                srf_read_enable_pipeline <= srf_read_enable;
                
                // ✅ First Stage: Capture operands correctly, delay enable
                if (srf_read_enable) begin
                    vxm_enable_pipeline_stage1 <= 1'b1;
                    vxm_operation_pipeline_stage1 <= 2'b00; // ADD operation                            
                end 
                else begin
                    vxm_enable_pipeline_stage1 <= 1'b0;
                    vxm_operation_pipeline_stage1 <= 2'b11;                            
                end
                
                // ✅ Final stage: Pipeline control signals and assign operands for execution
                vxm_enable_pipeline_stage2 <= vxm_enable_pipeline_stage1;
                vxm_operation_pipeline_stage2 <= vxm_operation_pipeline_stage1; 
                
                if (srf_read_enable_pipeline) begin
                    for (int i = 0; i < NUM_TILES_PER_SLICE; i++) begin
                        operand1[i] <= srf_data1[i];
                        operand2[i] <= srf_data2[i];
                    end
                end                                                                                              
            end
    end

    // ✅ Now vxm signals will be properly aligned    
    assign vxm_enable = vxm_enable_pipeline_stage2;
    assign vxm_operation = vxm_operation_pipeline_stage2;


     
endmodule : icu_dispatcher     