`timescale 1ns / 1ps



module CSR(
  input clk,
  input rst,
  input csr_write,  // �Ƿ�д CSR �Ĵ���
  input id_ecall,      // �Ƿ��� ecall ָ����������Ҫд PC��
  input wb_ecall,
  input stop,
  input[11:0] csr_read_addr,  // ��ȡ��Ŀ�� CSR �Ĵ�������Ϊ��д��ͬ����
  input[11:0] csr_write_addr, // д���Ŀ�� CSR �Ĵ���
  input[63:0] data_in,
  input[63:0] wb_pc,   // mepc ����Ҫ���� pc ��ֵ
  input[1:0] pc_src,   // �����ж��Ƿ�Ϊ ecall �� mret
  
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
      if(wb_ecall) begin // ��� ecall �򱣴� pc
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

