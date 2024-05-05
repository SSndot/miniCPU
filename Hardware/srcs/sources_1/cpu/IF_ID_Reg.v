`timescale 1ns / 1ps


module IF_ID_Reg(
  input clk,
  input rst,

  // input: inst & pc
  input[63:0] pc_in,
  input[31:0] inst_in,
  input predict_in, // predict whether to take branch

  input stop,

  // output: inst & pc
  output[31:0] inst_out,
  output[63:0] pc_out,
  output predict_out,
  
  // output: target register
  output[4:0] rs_out,
  output[4:0] rt_out
);

reg[63:0] pc;
reg[31:0] inst;
reg predict;

assign pc_out = pc;
assign inst_out = inst;
assign rs_out = inst[19:15];
assign rt_out = inst[24:20];
assign predict_out = predict;


always @(posedge clk or posedge rst) begin
  if(rst) begin
    pc <= 0;
    inst <= 0;
    predict <= 0;
  end else if(stop) begin
  end else begin
    pc   <= pc_in;
    inst <= inst_in;
    predict <= predict_in;
  end
end


endmodule