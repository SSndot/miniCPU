`timescale 1ns / 1ps


module save_forward(
  input clk,
  input[6:0] mem_op_code,
  input[2:0] mem_funct3,
  input[4:0] mem_rs2,
  input[63:0] mem_data2,
  
  input wb_reg_write,
  input[4:0] wb_rd,
  input[63:0] wb_alu_result,
//  output reg save_forward
  output reg[63:0] data_out
);

reg before_reg_write1;
reg[4:0] before_rd1;
reg[63:0] before_alu_result1;

reg before_reg_write2;
reg[4:0] before_rd2;
reg[63:0] before_alu_result2;

reg[63:0] save_mask; // ����ָ�� save ָ��� mask������ sw Ϊ 0xffffffff��sd Ϊ 0xffffffffffffffff

always@(*) begin
  // save_forward 
  // 0 ��ʾδ���� save hazard
  // rs1 ����Ҫǰ�ݣ���Ϊ ALU ��ǰ���Ѿ�������ˣ�
  // 1 ��ʾ rs2 ��Ҫǰ��
  

  // �ж� save ָ������
  if(mem_funct3 == 3'b000) begin // sb
    save_mask = 64'h0000_0000_0000_ffff;
  end
  else if(mem_funct3 == 3'b010) begin // sw
    save_mask = 64'h0000_0000_ffff_ffff;
  end
  else if(mem_funct3 == 3'b011) begin // sd
    save_mask = 64'hffff_ffff_ffff_ffff;
  end

  // ѡ�� data_out
  if(mem_op_code == 7'b0100011 && wb_reg_write == 1)begin
    if(mem_rs2 == wb_rd) data_out = wb_alu_result & save_mask;
    else data_out = mem_data2 & save_mask;
  end 
  else if(mem_op_code == 7'b0100011 && before_reg_write1 == 1)begin
    if(mem_rs2 == before_rd1) data_out = before_alu_result1 & save_mask;
    else data_out = mem_data2 & save_mask;
  end
  else if(mem_op_code == 7'b0100011 && before_reg_write2 == 1)begin
    if(mem_rs2 == before_rd2) data_out = before_alu_result2 & save_mask;
    else data_out = mem_data2 & save_mask;
  end
  else data_out = mem_data2 & save_mask;

end

always @(posedge clk) begin
  before_reg_write2 = before_reg_write1;
  before_rd2 = before_rd1;
  before_alu_result2 = before_alu_result1;
  
  before_reg_write1 = wb_reg_write;
  before_rd1 = wb_rd;
  before_alu_result1 = wb_alu_result;

end


endmodule
