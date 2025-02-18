module vector_execution_unit
    #(parameter MIN_VEC_LENGTH = 16)
(
    input logic clk,
    input logic rst,
    input logic vxm_enable,  // When asserted, executes math operation
    input logic [1:0] operation, // 00 = ADD, 01 = MUL (future expansion)
    input logic [MIN_VEC_LENGTH-1:0] operand1,
    input logic [MIN_VEC_LENGTH-1:0] operand2,
    output logic [MIN_VEC_LENGTH-1:0] vxm_result
);

    timeunit 1ns;
    timeprecision 1ps;

    always_ff @(posedge clk) begin
        if (rst) begin           
            vxm_result <= '0;            
        end
        else if (vxm_enable) begin
            case (operation)
                2'b00: vxm_result <= operand1 + operand2;
                2'b01: vxm_result <= operand1 - operand2;                   
                2'b10: vxm_result <= operand1 * operand2; // vector dot product
                default: vxm_result <= '0;
            endcase
        end
    end

endmodule : vector_execution_unit
