`timescale 1ns / 1ps


module load_judger(
  input[6:0] op_code,
  input stall,
  input is_load_before,
  output reg is_load
);

always@(*) begin
  if(stall) begin
    is_load <= 0;
  end
  else if(is_load_before) begin
    is_load <= 0;
  end
  else begin
    if(op_code == 7'b0000011) begin
        is_load <= 1;
      end
      else begin
        is_load <= 0;
      end
    end
  end
  
endmodule
