module streaming_register_file
    #(parameter NUM_STREAM_ID = 5,
      parameter MIN_VEC_LENGTH = 16,
      parameter NUM_TILES_PER_SLICE = 20)
      (input logic clk,
       input logic rst,
       input logic srf_read_enable,
       input logic srf_write_enable,
       input logic [NUM_STREAM_ID-1:0] stream_src1,  // First source stream
       input logic [NUM_STREAM_ID-1:0] stream_src2,  // Second source stream
       output logic [MIN_VEC_LENGTH-1:0] srf_data1 [0:NUM_TILES_PER_SLICE-1],
       output logic [MIN_VEC_LENGTH-1:0] srf_data2 [0:NUM_TILES_PER_SLICE-1],
       input logic [NUM_STREAM_ID-1:0] stream_dest,
       input logic [MIN_VEC_LENGTH-1:0] write_data [0:NUM_TILES_PER_SLICE-1]);
       
    timeunit 1ns;
    timeprecision 1ps;
       
    localparam integer NUM_STREAM_REGISTERS = 32;
    logic [MIN_VEC_LENGTH-1:0] stream_registers[0:NUM_STREAM_REGISTERS-1][0:NUM_TILES_PER_SLICE-1]; // 32 streams, 20 tiles each
    
    initial begin
        for(int i = 0; i < NUM_STREAM_REGISTERS; i++) begin
            for(int j = 0; j < NUM_TILES_PER_SLICE; j++) begin
                stream_registers[i][j] = '0;  // Default zero
            end
        end
    end

    // ✅ **Write to SRF only when srf_write_enable is asserted**
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int j = 0; j < NUM_TILES_PER_SLICE; j++) begin
                srf_data1[j] <= 16'h0000;
                srf_data2[j] <= 16'h0000;
            end
            // ✅ **Example: Hardcoding vector values**
            // Stream S_0 (Vector A)
            stream_registers[0][0] = 16'h0001;
            stream_registers[0][1] = 16'h0002;
            stream_registers[0][2] = 16'h0003;
            stream_registers[0][3] = 16'h0004;
            stream_registers[0][4] = 16'h0005;
            stream_registers[0][5] = 16'h0006;
            stream_registers[0][6] = 16'h0007;
            stream_registers[0][7] = 16'h0008;
            stream_registers[0][8] = 16'h0009;
            stream_registers[0][9] = 16'h000A;
            stream_registers[0][10] = 16'h000B;
            stream_registers[0][11] = 16'h000C;
            stream_registers[0][12] = 16'h000D;
            stream_registers[0][13] = 16'h000E;
            stream_registers[0][14] = 16'h000F;
            stream_registers[0][15] = 16'h0010;

            // Stream S_4 (Vector B)
            stream_registers[4][0] = 16'h000A;
            stream_registers[4][1] = 16'h000B;
            stream_registers[4][2] = 16'h000C;
            stream_registers[4][3] = 16'h000D;  
            stream_registers[4][4] = 16'h000E;
            stream_registers[4][5] = 16'h000F;
            stream_registers[4][6] = 16'h0010;
            stream_registers[4][7] = 16'h0011;
            stream_registers[4][8] = 16'h0012;
            stream_registers[4][9] = 16'h0013;
            stream_registers[4][10] = 16'h0014;
            stream_registers[4][11] = 16'h0015;
            stream_registers[4][12] = 16'h0016;
            stream_registers[4][13] = 16'h0017;
            stream_registers[4][14] = 16'h0018;
            stream_registers[4][15] = 16'h0019;
        end
        else             
            if (srf_write_enable) begin 
                // "Unrolled" version to make sure we execute writes in parallel (stream_dest is unknown at synthesis time)            
                stream_registers[stream_dest][0] <= write_data[0];
                stream_registers[stream_dest][1] <= write_data[1];
                stream_registers[stream_dest][2] <= write_data[2];
                stream_registers[stream_dest][3] <= write_data[3];
                stream_registers[stream_dest][4] <= write_data[4];
                stream_registers[stream_dest][5] <= write_data[5];
                stream_registers[stream_dest][6] <= write_data[6];
                stream_registers[stream_dest][7] <= write_data[7];
                stream_registers[stream_dest][8] <= write_data[8];
                stream_registers[stream_dest][9] <= write_data[9];
                stream_registers[stream_dest][10] <= write_data[10];
                stream_registers[stream_dest][11] <= write_data[11];
                stream_registers[stream_dest][12] <= write_data[12];
                stream_registers[stream_dest][13] <= write_data[13];
                stream_registers[stream_dest][14] <= write_data[14];
                stream_registers[stream_dest][15] <= write_data[15];
                stream_registers[stream_dest][16] <= write_data[16];
                stream_registers[stream_dest][17] <= write_data[17];
                stream_registers[stream_dest][18] <= write_data[18];
                stream_registers[stream_dest][19] <= write_data[19];
            end

            if (srf_read_enable) begin 
                srf_data1[0] <= stream_registers[stream_src1][0];                
                srf_data1[1] <= stream_registers[stream_src1][1];
                srf_data1[2] <= stream_registers[stream_src1][2];
                srf_data1[3] <= stream_registers[stream_src1][3];
                srf_data1[4] <= stream_registers[stream_src1][4];
                srf_data1[5] <= stream_registers[stream_src1][5];
                srf_data1[6] <= stream_registers[stream_src1][6];
                srf_data1[7] <= stream_registers[stream_src1][7];
                srf_data1[8] <= stream_registers[stream_src1][8];
                srf_data1[9] <= stream_registers[stream_src1][9];
                srf_data1[10] <= stream_registers[stream_src1][10];
                srf_data1[11] <= stream_registers[stream_src1][11];
                srf_data1[12] <= stream_registers[stream_src1][12];
                srf_data1[13] <= stream_registers[stream_src1][13];
                srf_data1[14] <= stream_registers[stream_src1][14];
                srf_data1[15] <= stream_registers[stream_src1][15];

                srf_data2[0] <= stream_registers[stream_src2][0];                
                srf_data2[1] <= stream_registers[stream_src2][1];   
                srf_data2[2] <= stream_registers[stream_src2][2];
                srf_data2[3] <= stream_registers[stream_src2][3];
                srf_data2[4] <= stream_registers[stream_src2][4];
                srf_data2[5] <= stream_registers[stream_src2][5];
                srf_data2[6] <= stream_registers[stream_src2][6];
                srf_data2[7] <= stream_registers[stream_src2][7];
                srf_data2[8] <= stream_registers[stream_src2][8];
                srf_data2[9] <= stream_registers[stream_src2][9];
                srf_data2[10] <= stream_registers[stream_src2][10];
                srf_data2[11] <= stream_registers[stream_src2][11];
                srf_data2[12] <= stream_registers[stream_src2][12];
                srf_data2[13] <= stream_registers[stream_src2][13];
                srf_data2[14] <= stream_registers[stream_src2][14];
                srf_data2[15] <= stream_registers[stream_src2][15];                    
            end
        end
    
endmodule : streaming_register_file
