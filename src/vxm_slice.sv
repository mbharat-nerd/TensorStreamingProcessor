module vxm_slice
    #(parameter MIN_VEC_LENGTH = 16,
      parameter NUM_TILES_PER_SLICE = 20)
      (input logic clk,
       input logic rst,
       input logic vxm_enable,
       input logic [1:0] operation,
       input logic [MIN_VEC_LENGTH-1:0] srf_data1 [0:NUM_TILES_PER_SLICE-1],
       input logic [MIN_VEC_LENGTH-1:0] srf_data2 [0:NUM_TILES_PER_SLICE-1],
       output logic [MIN_VEC_LENGTH-1:0] vxm_result [0:NUM_TILES_PER_SLICE-1]);


    genvar i;
    generate 
        for(i = 0;i < NUM_TILES_PER_SLICE;i++) begin : vxm_tile
            vector_execution_unit vxm (
                .clk(clk),
                .rst(rst),
                .vxm_enable(vxm_enable),
                .operation(operation),
                .operand1(srf_data1[i]),
                .operand2(srf_data2[i]),
                .vxm_result(vxm_result[i]));   
        end
    endgenerate                
       
endmodule : vxm_slice 