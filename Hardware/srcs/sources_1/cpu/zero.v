`timescale 1ns / 1ps



module zero(
  input[31:0] a,
  input[31:0] b,
  output reg zero
);

always@(*) begin
  if(a == b) zero <= 1;
  else zero <= 0; 
end

endmodule
