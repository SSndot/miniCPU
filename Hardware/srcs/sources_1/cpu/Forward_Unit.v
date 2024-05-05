`timescale 1ns / 1ps

module Forward_Unit(
  input ex_mem_reg_write,
  input mem_wb_reg_write,
  input[4:0] ex_mem_rd,
  input[4:0] mem_wb_rd,
  input[4:0] id_ex_rs1,
  input[4:0] id_ex_rs2,
  input[1:0] id_ex_alu_b,
  input wb_is_load,

  output[1:0] forward_a,
  output[1:0] forward_b
);

reg[1:0] forward_a_reg;
reg[1:0] forward_b_reg;
assign forward_a = forward_a_reg;
assign forward_b = forward_b_reg;


always @(*) begin
  forward_a_reg <= 2'b00;
  forward_b_reg <= 2'b00;
  // 优先 ex hazard ，再 mem hazard
  // 10 表示 ex hazard, 01 表示 mem hazard, 11 表示 load hazard 
  // 下面的判断顺序经过精心调整，千万不能乱动！！！
  if(ex_mem_reg_write == 1'b1 && ex_mem_rd == id_ex_rs1) begin
    forward_a_reg <= 2'b10;
  end
  else if(mem_wb_reg_write == 1'b1 && wb_is_load == 1'b1 && mem_wb_rd == id_ex_rs1) begin
    forward_a_reg <= 2'b11;
  end
  else if(mem_wb_reg_write == 1'b1 && mem_wb_rd == id_ex_rs1 ) begin
    forward_a_reg <= 2'b01;
  end

  if(ex_mem_reg_write == 1'b1 && ex_mem_rd == id_ex_rs2 && id_ex_alu_b == 0) begin
    forward_b_reg <= 2'b10;
  end
  else if(mem_wb_reg_write == 1'b1 && wb_is_load == 1'b1 && mem_wb_rd == id_ex_rs2 && id_ex_alu_b == 0) begin
    forward_b_reg <= 2'b11;
  end
  else if(mem_wb_reg_write == 1'b1 && mem_wb_rd == id_ex_rs2 && id_ex_alu_b == 0) begin
    forward_b_reg <= 2'b01;
  end 


end  



endmodule
