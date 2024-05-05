`timescale 1ns / 1ps



module CSR(
  input clk,
  input rst,
  input csr_write,  // 是否写 CSR 寄存器
  input id_ecall,      // 是否是 ecall 指令（如果是则需要写 PC）
  input wb_ecall,
  input stop,
  input[11:0] csr_read_addr,  // 读取的目标 CSR 寄存器（因为读写不同步）
  input[11:0] csr_write_addr, // 写入的目标 CSR 寄存器
  input[63:0] data_in,
  input[63:0] wb_pc,   // mepc 可能要保存 pc 的值
  input[1:0] pc_src,   // 用于判断是否为 ecall 和 mret
  
  output reg[63:0] data_out
);

reg[63:0] sstatus; // 0x100
reg[63:0] stvec;   // 0x105
reg[63:0] sepc;    // 0x141
reg[63:0] scause;  // 0x142
reg[63:0] satp;    // 0x180



always @(negedge clk or negedge rst) begin
   if(rst) begin
      sstatus <= 0;
      stvec <= 0;
      sepc <= 0;
      scause <= 0;
      satp <= 0;
    end
    else if(stop) begin
    end
    else begin
      if(csr_write)begin
        case(csr_write_addr) 
          12'h100: sstatus <= data_in;
          12'h105: stvec <= data_in;
          12'h141: sepc <= data_in;
          12'h142: scause <= data_in;
          12'h180: satp <= data_in;
        endcase
      end
      if(wb_ecall) begin // 如果 ecall 则保存 pc
        sepc <= wb_pc;
      end
    if(id_ecall)begin
      data_out <= stvec;
    end
    else if(pc_src == 3) begin // sret
      data_out <= sepc;
    end
    else begin
      case(csr_read_addr)
        12'h100: data_out <= sstatus;
        12'h105: data_out <= stvec;
        12'h141: data_out <= sepc ;
        12'h142: data_out <= scause ;
        12'h180: data_out <= satp;
        default: data_out <= 0;
      endcase
    end
  end
end




endmodule

