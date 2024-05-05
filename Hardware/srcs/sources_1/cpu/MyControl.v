`timescale 1ns / 1ps


module MyControl(
  input[6:0] op_code,
  input[2:0] funct3,
  input funct7_5,
  input[11:0] funct12,  // inst �� 31~20 λ�������ж� ecall �� mret��
  input stall,
  
  output reg[1:0] pc_src,
  output reg reg_write,
  output reg[1:0] alu_src_b,
  output reg[3:0] alu_op,
  output reg[2:0] mem_to_reg,
  output reg mem_write,
  output reg branch,
  output reg[2:0] b_type,
  
  // ��Ȩ�Ĵ��������ź�
  output reg csr_write,
  output reg ecall
    );

  `include "AluOp.vh"

  always @(*) begin
    pc_src = 0;    
    reg_write = 0;
    alu_src_b = 1;  //Ĭ������������
    alu_op = {funct7_5, funct3};
    mem_to_reg = 0;
    mem_write = 0;
    branch = 0;
    b_type = 0;
    csr_write = 1'b0;
    ecall = 1'b0;
    
    // ����˵��
    // reg_write��                0��ʾ��д�Ĵ�����1��ʾд�Ĵ���
    // alu_src_b��                00��ʾ��������reg[rs2], 01��ʾ����������������10��ʾ���� CSR
    // mem_write��                0��ʾ���ڴ棬1��ʾд�ڴ�
    // branch��                   0��ʾ���Ƿ�ָ֧�1��ʾ�Ƿ�ָ֧��
    // b_type��                   000��ʾbne��001��ʾbeq, 010��ʾblt, 011��ʾbge, 100��ʾbltu, 101��ʾbgeu
    // pc_src��                   00��ʾpc+4��01��ʾjalr��10��ʾjal��branch��11��ʾ����mtvec��mepc��ȡ�����Ƿ�Ϊ ecall��
    //                            
    // mem_to_reg���Ĵ���������Դ��000��ʾ��������ALU��001��ʾ������������010��ʾ����pc+4��011��ʾ�����ڴ棬100��ʾ����CSR
    //                             101��ʾ���� auipc
    // alu_op�� aluִ�еĲ���
    //--------------
    // ��Ȩָ������ź�
    // csr_write       �Ƿ�д CSR �Ĵ���
    // ecall           �Ƿ�Ϊ�ж�
    if(stall) begin
          pc_src <= 0;    
          reg_write <= 0;
          alu_src_b <= 0;  
          alu_op <= {funct7_5, funct3};
          mem_to_reg <= 0;
          mem_write <= 0;
          branch <= 0;
          b_type <= 0;
    end
    else begin
    case (op_code)
      //===============================================
      // lui
      7'b0110111: begin reg_write = 1'b1; mem_to_reg = 3'b001; end
      // auipc
      7'b0010111: begin reg_write = 1'b1; mem_to_reg = 3'b101;   end
      //===============================================
      // addi, slti, srai, srli, slli, xori, ori, andi
      7'b0010011:begin
        reg_write = 1;
        alu_src_b = 1;
        // addi
        if(funct3 == 3'b000) begin alu_op = ADD;  end
        // slli
        if(funct3 == 3'b001) begin alu_op <= SLL; end
        // slti
        if(funct3 == 3'b010) begin alu_op = SLT;  end
        // xori
        if(funct3 == 3'b100) begin
          alu_op <= XOR;
        end
        // ori
        if(funct3 == 3'b110)begin
          alu_op <= OR;
        end
        // andi
        if(funct3 == 3'b111)begin
          alu_op <= AND;
        end
        if(funct3 == 3'b101)begin
          // srli
          if(funct7_5 == 1'b0) begin
            alu_op <= SRL;
          end
          // srai
          if(funct7_5 == 1'b1) begin
            alu_op <= SRA;
          end
        end
      end
      //===============================================
      // lbu, lw, ld
      7'b0000011:begin
        reg_write = 1'b1;
        mem_to_reg = 3'b011;
        alu_op = 0;
      end
      //===============================================
      // sw, sb, sd
      7'b0100011:begin
        mem_write = 1'b1;
        alu_op = 0;
      end
      //===============================================
      // bne & beq
      7'b1100011:begin
        alu_src_b = 2'b0;
        branch = 1'b1;
        pc_src <= 2'b10;
        case(funct3)
          // bne
          3'b001: begin b_type = 0;alu_op = SUB; end
          // beq
          3'b000: begin b_type = 1; alu_op = SUB; end
          // blt
          3'b100: begin b_type = 2; alu_op = SLT;end
          // bge
          3'b101: begin b_type = 3; alu_op = SLT;end
          // bltu
          3'b110: begin b_type = 4; alu_op = SLTU;end
          // bgeu
          3'b111: begin b_type = 5; alu_op = SLTU;end
        endcase
      end
      //===============================================
      // jal
      7'b1101111:begin
        reg_write <= 1;
        pc_src <= 2'b10;
        mem_to_reg <= 3'b010;
        alu_op <= 0; //�ӷ�
      end
      //===============================================
      // jalr
      7'b1100111:begin
        reg_write <= 1;
        pc_src <= 2'b01;
        mem_to_reg <= 3'b010;
        alu_op <= 0; //�ӷ�
      end
      //===============================================
      // addw
      7'b0111011: begin
        reg_write = 1;
        alu_op = ADDW;
      end
      //===============================================
      // addiw, slliw
      7'b0011011: begin
        reg_write = 1;
        alu_src_b = 1;
        if(funct3 == 3'b000) // addiw
          alu_op = ADDW;
        if(funct3 == 3'b001) // slliw
          alu_op = SLLW;
      end
      //===============================================
      // add ,slt, sub, sra, xor, sll
      7'b0110011:begin
        reg_write = 1;
        alu_src_b = 0;

        // case: funct3 = 3'b000
        if(funct3 == 3'b000) begin
          // sub
          if(funct7_5 == 1'b1) begin
            alu_op <= SUB;
          end
          // add
          if(funct7_5 == 1'b0) begin
            alu_op <= ADD;
          end
        end

        // case: funct3 = 3'b001
        if(funct3 == 3'b001) begin
          // sll
          if(funct7_5 == 1'b0) begin
            alu_op <= SLL;
          end
        end

        // case: funct3 = 3'b010
        if(funct3 == 3'b010) begin
          // slt
           alu_op = SLT; 
        end

        // case: funct3 = 3'b100
        if(funct3 == 3'b100) begin
          // xor
          if(funct7_5 == 1'b0) begin
            alu_op <= XOR;
          end
        end

        // case: funct3 = 3'b101
        if(funct3 == 3'b101) begin
          // sra
          if(funct7_5 == 1'b1) begin
            alu_op = SRA;
          end
        end

        // or
        if(funct3 == 3'b110) begin
          alu_op <= OR;
        end

        // and
        if(funct3 == 3'b111) begin
          alu_op <= AND;
        end
      end
      
      //===============================================
      // CSR ops
      7'b1110011:begin
        case(funct3)
          //--------------------------
          // ecall & mret & sret
          3'b000:begin
            if(funct12 == 0) begin  // ecall
              // pc ������ mtvec
              pc_src <= 2'b11;
              ecall <= 1;
              //csr_write <= 1;  ��ȻҪ�� pc +4 д�� mepc���� CSR �ڲ��Ѿ�д�ˣ�����Ҫ WB �׶���д
            end
            // if(funct12 == 12'h302) begin  // mret
            //   // pc ������ mepc
            //   pc_src <= 2'b11;
            //   //csr_write <= 1;
            // end
            if(funct12 == 12'h102) begin // sret
              pc_src <= 2'b11;
            end
          end
          //--------------------------
          // CSRRW
          3'b001: begin
            csr_write <= 1;
            alu_src_b <= 1;  // ������������ע���� ImmGen �ж� csrrw ���������� 0
            alu_op <= ADD;
            reg_write <= 1;
            mem_to_reg <= 3'b100;
          end
          // CSRRS
          3'b010: begin
            reg_write <= 1;  // д�Ĵ���
            alu_op <= OR;   // ������
            alu_src_b <= 2; // ���� CSR �Ĵ���
            csr_write <= 1;
            mem_to_reg <= 3'b100;
          end
        endcase
        
      end
      
      
      //===============================================
      default: alu_op = 0;
    endcase
    end
  end




endmodule
