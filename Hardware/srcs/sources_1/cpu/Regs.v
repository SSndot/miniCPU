`timescale 1ns / 1ps

module Regs(
  input clk,
  input rst,   //��λ�źţ����Ϊ1�������мĴ�������
  input we,    // д�źţ����Ϊ1��������д�Ĵ���
  input stop,
  input[4:0] read_addr_1,  // ��ȡ�ļĴ������
  input[4:0] read_addr_2,
  input[4:0] write_addr,   // д��ļĴ������
  input[63:0] write_data,


  //��������
  input wire[4:0] debug_reg_addr,
  output wire[63:0] debug_reg_out,
  
  output[63:0] read_data_1,
  output[63:0] read_data_2
    );


  integer i;
  reg[63:0] register[1:31]; // 31���Ĵ���������x0Ϊ0

  assign read_data_1 = (read_addr_1 == 0) ? 0 : register[read_addr_1];
  assign read_data_2 = (read_addr_2 == 0) ? 0 : register[read_addr_2];

  //���Բ���

    assign debug_reg_out =(debug_reg_addr == 0)? 0:register[debug_reg_addr];


  always @(negedge clk or negedge rst) begin
    if (rst) begin
      for (i = 0; i <= 31; i = i + 1) begin
        register[i] <= 0;
      end
    end 
    else if(stop) begin
    end
    else begin
      if (we == 1 && write_addr != 0) begin
        register[write_addr] <= write_data;
      end
    end
  end




endmodule
