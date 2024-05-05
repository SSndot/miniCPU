`timescale 1ns / 1ps


module ImmGen(
    input[31:0] inst,
    input[6:0] op_code,
    output reg[63:0] imm_out
    );

  always@(*) begin
    case(op_code)
      // addi, 
      7'b0010011: imm_out[63:0] <= {{ 52{inst[31]}}, inst[31:20] };
      // addiw
      7'b0011011: imm_out[63:0] <= {{ 52{inst[31]}}, inst[31:20] };
      // lw, ld, lbu
      7'b0000011: imm_out[63:0] <= {{ 52{inst[31]}}, inst[31:20] };
      // sw
      7'b0100011: imm_out[63:0] <= { {52{inst[31]}}, inst[31:25], inst[11:7] };
      // bne, beq
      7'b1100011: imm_out[63:0] <= ({ {53{inst[31]}} ,inst[7], inst[30:25], inst[11:8] } << 1);
      // lui
      7'b0110111: imm_out[63:0] <= {{32{inst[31]}},{inst[31:12]}, {12'b0}};
      // auipc
      7'b0010111: imm_out[63:0] <= {{32{inst[31]}},{inst[31:12]}, {12'b0}};
      // jal
      7'b1101111: imm_out[63:0] <= {{44{inst[31]} }, {inst[19:12]}, {inst[20]}, {inst[30:21]}, {1'b0}};
      // jalr
      7'b1100111: imm_out[63:0] <= {{52{inst[31]}}, inst[31:20] };
      // slti
      7'b0010011: imm_out[63:0] <= {{52{inst[31]}}, inst[31:20] };
      // CSR 指令
      7'b1110011: imm_out[63:0] <= 64'b0; // 立即数为 0
    endcase
  end




endmodule
