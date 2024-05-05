`timescale 1ns / 1ps

module BTB(
  input clk,
  input rst,
  input[63:0] read_pc,
  input stop,
  output reg[63:0] read_predict_pc,
  output reg read_found,  // 1: found, 0: not found
  input[63:0] write_pc,
  input[63:0] write_predict_pc,
  input write
);

integer i;
integer j;
reg[127:0] predict_table[0:255];
reg[7:0] write_pos;

always @(negedge clk) begin
  if (rst) begin
    for (i = 0; i <= 255; i = i + 1) begin
      predict_table[i] <= 0;
      write_pos <= 0;
      read_found <= 0;
    end
  end 
  else if(stop) begin
  end
  else begin
    // read pc
    read_found = 0;
    for(j = 0; j <= 255; j = j + 1) begin
      if (predict_table[j][127:64] == read_pc) begin
        read_predict_pc = predict_table[j][63:0];
        read_found = 1;
      end
    end
    // write pc
    if (write == 1) begin
      predict_table[write_pos][127:64] <= write_pc;
      predict_table[write_pos][63:0] <= write_predict_pc;
      write_pos = write_pos + 1;
    end
  end
end






endmodule
