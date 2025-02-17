module memory_unit #
    (parameter MEM_ADDR_WIDTH = 10,
    parameter NUM_STREAM_ID = 5)
    (input logic clk,
    input logic rst,
    input logic mem_read_enable,
    input logic [MEM_ADDR_WIDTH-1:0] address);
    
endmodule : memory_unit
    