module vector_execution_module
    #(parameter MIN_VEC_LENGTH = 16,
      parameter NUM_TILES_PER_SLICE = 20)
(
    input logic clk,
    input logic rst,
    input logic vxm_enable,  // When asserted, executes the vector operation
    input logic [1:0] operation, // 00 = ADD, 01 = MUL (future expansion)
    input logic [MIN_VEC_LENGTH-1:0] srf_data1 [0:NUM_TILES_PER_SLICE-1], // First operand stream
    input logic [MIN_VEC_LENGTH-1:0] srf_data2 [0:NUM_TILES_PER_SLICE-1], // Second operand stream
    output logic [MIN_VEC_LENGTH-1:0] vxm_result [0:NUM_TILES_PER_SLICE-1] // Output result stream
);

    timeunit 1ns;
    timeprecision 1ps;

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < NUM_TILES_PER_SLICE; i++) begin
                vxm_result[i] <= 0;
            end
        end
        else if (vxm_enable) begin
            case (operation)
                2'b00: begin // **Vector Addition**
                    for (int i = 0; i < NUM_TILES_PER_SLICE; i++) begin
                        vxm_result[i] <= srf_data1[i] + srf_data2[i];
                    end
                end                              

                default: begin
                    for (int i = 0; i < NUM_TILES_PER_SLICE; i++) begin
                        vxm_result[i] <= 0;
                    end
                end
            endcase
        end
    end

endmodule : vector_execution_module
