module instruction_memory
    #(parameter integer INSTR_WIDTH = 32,
      parameter integer INSTR_MEM_ADDR_WIDTH = 10)
   (input logic clk,
    input logic rst,
    output logic [INSTR_WIDTH-1:0] instr_out,
    input logic [INSTR_MEM_ADDR_WIDTH-1:0] address);
    
    logic [31:0] instr_mem [0:1023]; // 1 KiB instr mem
    
    // some simply hardcoded instructions
    // TODO:  replace with dynamic loading, say from DDR via ARM
    initial begin
        instr_mem[0] = 'h00000000; // NOP
    end
    
    always_ff @(posedge clk) begin
        if (rst)
            instr_out <= 'hFFFFFFFF; // invalid instruction
        else
            instr_out <= instr_mem[address];
    end
    
endmodule : instruction_memory