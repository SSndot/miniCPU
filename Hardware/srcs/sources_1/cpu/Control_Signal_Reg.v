`timescale 1ns / 1ps


module Control_Signal_Reg(
  input clk,
  input rst,

  input[1:0] pc_src_in,
  input reg_write_in,
  input[1:0] alu_src_b_in,
  input branch_in,
  input[2:0] b_type_in,
  input[3:0] alu_op_in,
  input mem_write_in,
  input[2:0] mem_to_reg_in,
  input csr_write_in,
  input csr_ecall_in,
  input[63:0] csr_data_out_in, // ¶ÁÈ¡µÄ csr ¼Ä´æÆ÷
  
  input stall,
  input is_load,
  input stop,

  output[1:0] pc_src_out,
  output reg_write_out,
  output[1:0] alu_src_b_out,
  output branch_out,
  output[2:0] b_type_out,
  output[3:0] alu_op_out,
  output mem_write_out,
  output[2:0] mem_to_reg_out,
  output csr_write_out,
  output csr_ecall_out,
  output[63:0] csr_data_out_out // ¶ÁÈ¡µÄ csr ¼Ä´æÆ÷
);

reg[1:0] pc_src;   
reg reg_write;
reg[1:0] alu_src_b;
reg branch;       
reg[2:0] b_type;   
reg mem_write;
reg[3:0] alu_op;
reg[2:0] mem_to_reg;
reg csr_write;
reg csr_ecall;
reg[63:0] csr_data_out;

assign pc_src_out = pc_src;
assign reg_write_out = reg_write;
assign alu_src_b_out = alu_src_b;
assign branch_out = branch;
assign b_type_out = b_type;
assign alu_op_out = alu_op;
assign mem_to_reg_out = mem_to_reg;
assign mem_write_out = mem_write;
assign csr_write_out = csr_write;
assign csr_ecall_out = csr_ecall;
assign csr_data_out_out = csr_data_out;

always @(posedge clk) begin
  if(rst || stall || is_load) begin
    pc_src <= 0;
    reg_write <= 0;
    alu_src_b <= 0;
    branch <= 0;
    b_type <= 0;
    alu_op <= 0;
    mem_to_reg <= 0;
    mem_write <= 0;
    csr_write <= 0;
    csr_ecall <= 0;
    csr_data_out <= 0;
  end
  else if(stop) begin
  end
  else begin
    pc_src <= pc_src_in;
    reg_write <= reg_write_in;
    alu_src_b <= alu_src_b_in;
    branch <= branch_in;
    b_type <= b_type_in;
    alu_op <= alu_op_in;
    mem_to_reg <= mem_to_reg_in;
    mem_write <= mem_write_in;
    csr_write <= csr_write_in;
    csr_ecall <= csr_ecall_in;
    csr_data_out <= csr_data_out_in;
  end
end











endmodule
