`timescale 1ns / 1ps


module ALU(
  input[63:0] a,
  input[63:0] b,
  input[3:0] alu_op,
  output reg[63:0] res,
  output reg zero
  );

`include "AluOp.vh"

wire[63:0] sum = a + b;
wire[63:0] sll = a << b[5:0];

always @(*) begin
  case(alu_op)
    ADD: res = a + b;
    SUB: res = a - b;
    SLL: res = a << b[5:0];
    SLT: res = ($signed(a) < $signed(b)) ? 1'b1 : 1'b0;
    SLTU: res = (a < b) ? 1'b1 : 1'b0;
    XOR: res = a ^ b;
    SRL: res = a >> b[5:0];
    SRA: res = a >>> b[5:0];
    OR: res = a | b;
    AND: res = a & b;
    ADDW: res = {{32{sum[31]}},{sum[31:0]}};
    SLLW: res = {{32{sll[31]}},{sll[31:0]}};
  endcase
  zero <= (res == 0);
end

  
  
endmodule
