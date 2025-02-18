module instruction_memory
    #(parameter INSTR_WIDTH = 32,
      parameter INSTR_MEM_ADDR_WIDTH = 10)
   (input logic clk,
    input logic rst,
    output logic [INSTR_WIDTH-1:0] instr_out,
    output logic instr_valid,
    input logic [INSTR_MEM_ADDR_WIDTH-1:0] address);
    
    logic [31:0] instr_mem [0:1023]; // 1 KiB instr mem
    
    // some simply hardcoded instructions
    // TODO:  replace with dynamic loading, say from DDR via ARM
    initial begin
        instr_mem[0] = 32'h03002080; // ADD S_0, S_4, S_8                
        //instr_mem[1] = 32'h04000810; // Write S_8, addr 0x0010
        instr_mem[1] = 32'h00000000; // NOP (End program)
    end
    
    always_ff @(posedge clk) begin
        if (rst) begin
            instr_out <= 'hFFFFFFFF; // invalid instruction
            instr_valid <= 1'b0;
        end            
        else begin
            instr_out <= instr_mem[address];                     
            // TODO:  For now, we will mark end of a program with a NOP
            instr_valid <= (instr_mem[address] != 32'h00000000) ? 1'b1 : 1'b0; 
        end            
    end
    
endmodule : instruction_memory