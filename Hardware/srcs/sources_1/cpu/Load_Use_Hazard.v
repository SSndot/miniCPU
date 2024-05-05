`timescale 1ns / 1ps


module Load_Use_Hazard(
  input id_ex_mem_read,
  input[4:0] id_ex_rd,
  input[4:0] if_id_rs1,
  input[4:0] if_id_rs2,
  
  output load_use_hazard
);

reg load_use_hazard_reg;
assign load_use_hazard = load_use_hazard_reg;

always@(*) begin
  load_use_hazard_reg <= 1'b0;
  if(id_ex_mem_read == 1'b1 && id_ex_rd == if_id_rs1) begin
    load_use_hazard_reg <= 1'b1;
  end
  else if(id_ex_mem_read == 1'b1 && id_ex_rd == if_id_rs2) begin
    load_use_hazard_reg <= 1'b1;
  end
end


endmodule
