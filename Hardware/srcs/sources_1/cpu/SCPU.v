`timescale 1ns / 1ps


module SCPU(
    input         clk,
    input         rst,
    input  [31:0] inst,  //32λָ��
    input  [63:0] data_in,  // �ڴ��������
    input stop,  // ��ͣ��ˮ��

    //��������
    // input wire[4:0] debug_reg_addr,
    // output wire[63:0] debug_reg_out,

    output [63:0] addr_out, //  Ҫд/���������ڴ��ַ  
    output [63:0] data_out, // Ҫд������
    output [63:0] pc_out,   // ���ĺ�� pc ֵ
    output        mem_write // 0 ���ڴ棬1 д�ڴ�
  );

    //====================================================
    // definitions
    // pc
    reg[63:0] pc;
    assign pc_out = pc;  
    // =================================================
    // IF definition
    wire[63:0] if_pc;
    wire[31:0] if_inst;
    assign if_pc = pc;
    assign if_inst = inst;
    // =================================================
    // ID definition
    wire[4:0] id_rs1;
    wire[4:0] id_rs2;
    wire[63:0] id_pc;
    wire[31:0] id_inst;
    // register
   // wire[31:0] write_data_to_reg; // Ҫд��Ĵ���������
    wire[63:0] id_data1;  // �ӼĴ����ж���������
    wire[63:0] id_data2;
    // �����ź�
    wire [3:0] id_alu_op;
    wire [1:0] id_pc_src ;
    wire[2:0] id_mem_to_reg;
    wire id_reg_write,  id_branch, id_mem_write;
    wire[2:0] id_b_type;
    wire[1:0] id_alu_src;
    // csr �����ź�
    wire id_csr_write, id_ecall;
    wire[63:0] id_csr_data_out;
    wire[11:0] id_csr_addr;
    assign id_csr_addr = id_inst[31:20];
    
    //���� ImmGen
    wire[63:0] id_imm;
    // =================================================
    // EX definitions
    wire[63:0] ex_data1;
    wire[63:0] ex_data2;
    wire[31:0] ex_inst;
    wire[63:0] ex_pc;
    wire[63:0] ex_imm;
    wire[4:0] ex_rd = ex_inst[11:7];
    wire[4:0] ex_rs1 = ex_inst[19:15];
    wire[4:0] ex_rs2 = ex_inst[24:20];
    
    // load use hazard
    wire mem_read = (id_mem_to_reg == 3'b011) && (id_reg_write == 1'b1);

    // control signals
    wire[1:0] ex_pc_src;
    wire ex_reg_write;
    wire[1:0] ex_alu_src;
    wire ex_branch;
    wire[2:0] ex_b_type;
    wire[3:0] ex_alu_op;
    wire[2:0] ex_mem_to_reg;
    wire ex_mem_write;

    // ALU zero
    wire ex_zero;
    wire[63:0] alu_data2;
    wire[63:0] ex_alu_result;
    wire zero;
    
    // CSR 
    wire ex_csr_write, ex_ecall;
    wire[63:0] ex_csr_data_out;
    wire[11:0] ex_csr_addr;
    assign ex_csr_addr = ex_inst[31:20];
    // =================================================
    // MEM definition
    wire[31:0] mem_inst;
    wire[63:0] mem_pc;
    wire[63:0] mem_imm;

    // control signals
    wire[1:0] mem_pc_src;
    wire mem_reg_write;
    wire[1:0] mem_alu_src;
    wire mem_branch;
    wire[2:0] mem_b_type;
    wire[3:0] mem_alu_op;
    wire[2:0] mem_mem_to_reg;
    wire mem_mem_write;

    // ALU
    wire[63:0] mem_alu_result;
    wire mem_zero;

    wire[63:0] mem_data2;
    wire[63:0] mem_memory_data;
    
    // csr
    wire mem_csr_write, mem_ecall;
    wire[63:0] mem_csr_data_out;
    wire[11:0] mem_csr_addr;
    assign mem_csr_addr = mem_inst[31:20];
    // =================================================
    // WB definitions
    wire[31:0] wb_inst;
    wire[63:0] wb_pc;
    wire[2:0] wb_funct3 = wb_inst[14:12];
    wire[4:0] wb_rd = wb_inst[11:7];
    wire[63:0] wb_alu_result;

    // control signals
    wire[1:0] wb_pc_src;
    wire[1:0] wb_alu_src;
    wire wb_branch;
    wire[2:0] wb_b_type;
    wire[3:0] wb_alu_op;
    wire[2:0] wb_mem_to_reg;
    wire wb_mem_write;
    // imm
    wire[63:0] wb_imm;
    // memory
    wire[63:0] wb_memory_data;
    // csr �����ź�
    wire wb_csr_write, wb_ecall;
    wire[11:0] wb_csr_addr;
    assign wb_csr_addr = wb_inst[31:20];
    wire[63:0] wb_csr_data_out;
    
    
    wire wb_reg_write;
    wire save_forward;
    wire[63:0] wb_write_data_to_reg;
    
    // =================================================
    // stall �����ź�
    reg stall;
    reg stall_before;
    always@(posedge clk) begin
      if(stop) begin
      end
      else stall_before <= stall;
    end
    // �ж��Ƿ�Ϊ load ָ��
    wire is_load;
    reg is_load_before;
    always@(posedge clk) begin
      if(stop) begin
      end
      else is_load_before <= is_load;
    end
    
    // forward unit
    wire[1:0] forward_a;
    wire[1:0] forward_b;
    wire[4:0] mem_rd = mem_inst[11:7];
    
    // Ϊ MEM ǰ����׼��
    // ѡ��д�ؼĴ���������
    wire[63:0] mem_write_data_to_reg;
    MUX8T1_32 mem_write_register_mux(
      .I0(mem_alu_result),
      .I1(mem_imm),
      .I2(mem_pc+4),
      .I3(mem_memory_data),
      .I4(mem_csr_data_out),
      .I5(mem_imm+mem_pc),
      .s(mem_mem_to_reg),
      .o(mem_write_data_to_reg)
    );
    
    // wb �׶��ж��Ƿ�Ϊ ld ָ��
    wire wb_is_load;
    load_judger wb_load_judger(
      .op_code(wb_inst[6:0]),
      .is_load(wb_is_load)
    );
    
    Forward_Unit forward_unit(
      .ex_mem_reg_write(mem_reg_write),
      .mem_wb_reg_write(wb_reg_write),
      .ex_mem_rd(mem_rd),
      .mem_wb_rd(wb_rd),
      .id_ex_rs1(ex_rs1),
      .id_ex_rs2(ex_rs2),
      // ����Ҫ��֤ rs2 ����Ч��
      .id_ex_alu_b(ex_alu_src),
      .wb_is_load(wb_is_load),

      .forward_a(forward_a),
      .forward_b(forward_b)
    );
    

    // =================================================
    // ��֧Ԥ�� definition
    // bht
    wire bht_predict; // bht Ԥ��Ľ��
    wire id_predict;
    wire ex_predict;
    wire mem_predict;
    wire[63:0] bht_write_pc; // д�� bht �� pc
    reg bht_write;   // �Ƿ�д bht ��
    reg bht_write_predict;  // 1 for taken, 0 for not taken

    // btb
    wire btb_read_found;
    wire[63:0] btb_read_predict_pc;
    reg[63:0] btb_write_predict_pc;
    reg btb_write;

    
    
    // =================================================
    // IF Part
    IF_ID_Reg if_id_reg(
          // input
          .clk(clk),
          .rst(rst),
          .pc_in(if_pc),
          .inst_in(if_inst),
          .predict_in(bht_predict),
          .predict_out(id_predict),
          .stop(stop),
    
          // output
          .rs_out(id_rs1),
          .rt_out(id_rs2),
          .inst_out(id_inst),
          .pc_out(id_pc)
    );

    // BHT table
    BHT bht(
      .clk(clk),
      .rst(rst),
      .stop(stop),
      .read_pc(if_pc),
      .read_predict(bht_predict),
      .write_pc(mem_pc),
      .write_predict(bht_write_predict),
      .write(bht_write)
    );

    BTB btb(
      .clk(clk),
      .rst(rst),
      .stop(stop),
      .read_pc(if_pc),
      .read_predict_pc(btb_read_predict_pc),
      .read_found(btb_read_found),
      .write_pc(mem_pc),
      .write_predict_pc(btb_write_predict_pc),
      .write(btb_write)
    );
    
    
    // =================================================
    // ID Part
    Regs register(
      // ����
      .clk(clk),
      .rst(rst),
      .stop(stop),
      .we(wb_reg_write),
      .read_addr_1(id_rs1),
      .read_addr_2(id_rs2),
      .write_addr(wb_rd),
      .write_data(wb_write_data_to_reg),

      //���Բ���
//      .debug_reg_addr(debug_reg_addr),
//      .debug_reg_out(debug_reg_out),

      .read_data_1(id_data1),
      .read_data_2(id_data2)
    );

    MyControl control ( 
        // ����
        .op_code(id_inst[6:0]),
        .funct3(id_inst[14:12]),
        .funct7_5(id_inst[30]),
        .funct12(id_inst[31:20]),
        .stall(stall_before),  // ǰ��һ��ʱ���Ƿ�Ϊ stall����Ϊ IF �׶ε�ָ���޷�ֱ�ӳ�ϴ��ֻ��ͨ������ǰ���״̬

        // ���
        .pc_src(id_pc_src),         // 2'b00 ��ʾpc����������pc+4, 2'b01 ��ʾ��������JALR��ת��ַ, 2'b10��ʾ��������JAL��ת��ַ(����branch). branch ��ת������������
        .reg_write(id_reg_write),   // 1'b1 ��ʾд�Ĵ���(���ڴ棡��)
        .alu_src_b(id_alu_src),   // 1'b1 ��ʾALU B�ڵ�����Դ����imm, 1'b0��ʾ��������Reg[rs2]
        .alu_op(id_alu_op),         // ��������ALU�����������뿴AluOp.vh�жԸ��������ı���
        .mem_to_reg(id_mem_to_reg), // 2'b00 ��ʾд��rd����������ALU, 2'b01��ʾ��������imm, 2'b10��ʾ��������pc+4, 2'b11 ��ʾ��������data memory
        .mem_write(id_mem_write),   // 1'b1 ��ʾдdata memory, 1'b0��ʾ��data memory
        .branch(id_branch),         // 1'b1 ��ʾ��branch���͵�ָ
        .b_type(id_b_type),          // 1'b1 ��ʾbeq, 1'b0 ��ʾbne
        .csr_write(id_csr_write),
        .ecall(id_ecall)
    );


    ImmGen immgen(
      .inst(id_inst),
      .op_code(id_inst[6:0]),
      .imm_out(id_imm)
    );
    
    // �ж��Ƿ�Ϊ ld ָ��
    load_judger id_load_judger(
      .op_code(id_inst[6:0]),
      .stall(stall_before),  // ��������������jump �� ld ��ס��J ���� wb �׶Σ�ld ���� id �׶Σ���ʱ pc �ᱻ��סһ�Σ�
      .is_load_before(is_load_before),  // ������������������ ld �����������ס
      .is_load(is_load)
    );

    // CSR �Ĵ���
    
    CSR csr(
      .clk(clk),
      .rst(rst),
      .stop(stop),
      .csr_write(wb_csr_write),
      .id_ecall(id_ecall),
      .wb_ecall(wb_ecall),
      .data_in(wb_alu_result),
      .csr_read_addr(id_csr_addr),    // ����������� id �׶ζ�  
      .csr_write_addr(wb_csr_addr),   // ���д������ wb �׶�д
      
      .wb_pc(wb_pc),
      .pc_src(id_pc_src),
      .data_out(id_csr_data_out)
    );


    // =================================================
    // ID - EX reg
    ID_EX_Reg id_ex_reg(
          .clk(clk),
          .rst(rst),
    
          .data1_in(id_data1),
          .data2_in(id_data2),
    
          .pc_in(id_pc),
          .inst_in(id_inst),
    
          .pc_src_in(id_pc_src),
          .reg_write_in(id_reg_write),
          .alu_src_b_in(id_alu_src),
          .branch_in(id_branch),
          .b_type_in(id_b_type),
          .alu_op_in(id_alu_op),
          .mem_to_reg_in(id_mem_to_reg),
          .mem_write_in(id_mem_write),
          .predict_in(id_predict),
    
          .imm_in(id_imm),
          .csr_write_in(id_csr_write),
          .csr_ecall_in(id_ecall),
          .csr_data_out_in(id_csr_data_out),
          
          .stall(stall),
          .is_load(is_load_before),
          .stop(stop),
    
          .data1_out(ex_data1),
          .data2_out(ex_data2),
    
          .inst_out(ex_inst),
          .pc_out(ex_pc),
          .predict_out(ex_predict),
    
          .pc_src_out(ex_pc_src),
          .reg_write_out(ex_reg_write),
          .alu_src_b_out(ex_alu_src),
          .branch_out(ex_branch),
          .b_type_out(ex_b_type),
          .alu_op_out(ex_alu_op),
          .mem_to_reg_out(ex_mem_to_reg),
          .mem_write_out(ex_mem_write),

          .csr_write_out(ex_csr_write),
          .csr_ecall_out(ex_ecall),
          .csr_data_out_out(ex_csr_data_out),
    
          .imm_out(ex_imm)
      );
    
    // =================================================
    // EX Part
    
    // ���� ALU ǰ�� MUX
    // 0 ���ԼĴ����� 1 ����������, 2 ���� CSR
    wire[63:0] imm_reg_mux;
    MUX4T1_32 alu_src_mux(
      .I0(ex_data2),
      .I1(ex_imm),
      .I2(ex_csr_data_out),
      .I3(),
      .s(ex_alu_src),
      .o(imm_reg_mux)
    );
    
    // �ж� rs1 �Ƿ�����ǰ��ָ��� ALU ���
     wire[63:0] alu_data1;
     MUX4T1_32 alu_data1_mux(
       .I0(ex_data1),
       // 01 ��ʾ���� wb�� 10 ��ʾ���� mem����ʦ�μ��ϵ���ơ�����
       .I1(wb_write_data_to_reg),
       .I2(mem_write_data_to_reg),
       .I3(wb_memory_data),
       .s(forward_a),
       .o(alu_data1)
     );
 
     // �ж� rs2 �Ƿ�����ǰ��ָ��� ALU ���
     MUX4T1_32 alu_data2_mux(
       .I0(imm_reg_mux),
       .I1(wb_write_data_to_reg),
       .I2(mem_write_data_to_reg),
       .I3(wb_memory_data),
       .s(forward_b),
       .o(alu_data2)
     );
     
    ALU alu(
      .a(alu_data1),
      .b(alu_data2),
      .alu_op(ex_alu_op),
      .zero(ex_zero),
      .res(ex_alu_result)
    );
    

    // =================================================
    // MEM Part
    EX_MEM_Reg ex_mem_reg(
      .clk(clk),
      .rst(rst),

      .alu_result_in(ex_alu_result),

      .pc_in(ex_pc),
      .inst_in(ex_inst),

      .pc_src_in(ex_pc_src),
      .reg_write_in(ex_reg_write),
      .alu_src_b_in(ex_alu_src),
      .branch_in(ex_branch),
      .b_type_in(ex_b_type),
      .alu_op_in(ex_alu_op),
      .mem_to_reg_in(ex_mem_to_reg),
      .mem_write_in(ex_mem_write),
      .predict_in(ex_predict),

      .zero_in(ex_zero),
      .imm_in(ex_imm),
      .data2_in(ex_data2),

      .csr_write_in(ex_csr_write),
      .csr_ecall_in(ex_ecall),
      .csr_data_out_in(ex_csr_data_out),
      
      .stall(stall),
      .stop(stop),

      .inst_out(mem_inst),
      .pc_out(mem_pc),
      .predict_out(mem_predict),

      .alu_result_out(mem_alu_result),

      .pc_src_out(mem_pc_src),
      .reg_write_out(mem_reg_write),
      .alu_src_b_out(mem_alu_src),
      .branch_out(mem_branch),
      .b_type_out(mem_b_type),
      .alu_op_out(mem_alu_op),
      .mem_to_reg_out(mem_mem_to_reg),
      .mem_write_out(mem_mem_write),

      .csr_write_out(mem_csr_write),
      .csr_ecall_out(mem_ecall),
      .csr_data_out_out(mem_csr_data_out),

      .zero_out(mem_zero),
      .imm_out(mem_imm),
      .data2_out(mem_data2)
    );

    // deal with data memory
    // sw rs2, imm(rs1)������ rs2 �� ID �׶�ȡ�� rs2�� ������ 3 ����Ҫǰ�ݵ����
    save_forward save_forward_judger(
      .mem_op_code(mem_inst[6:0]),
      .mem_rs2(mem_inst[24:20]),
      .mem_funct3(mem_inst[14:12]),
      .wb_reg_write(wb_reg_write),
      .wb_rd(wb_inst[11:7]),
    //  .save_forward(save_forward)
      
      // ����
      .clk(clk),
      .mem_data2(mem_data2),
      .wb_alu_result(wb_write_data_to_reg),
      .data_out(data_out)
    );
    
    assign addr_out = mem_alu_result;
//    assign data_out = save_forward? wb_alu_result : mem_data2;
    assign mem_write = mem_mem_write;
    assign mem_memory_data = data_in;
    
    // deal with PC
    always@(posedge clk or posedge rst)begin
      if(rst) begin
        pc <= 64'h8020_0000; // begin at 0x8000_0000
      end
      else if(stop) begin
      end
      else begin
        // =========================================
        //begin mem_pc_src == 0
        if(mem_pc_src == 0) begin  // pc + 4
          if(is_load) pc <= pc;
          else if(mem_csr_write)begin
            pc <= pc - 8;   // �ָ� ex �׶ε�ָ��
          end
          else if(bht_predict && btb_read_found) begin
            pc <= btb_read_predict_pc;
          end
          else pc <= pc + 4;
        end
        // end mem_pc_src == 0
        // =========================================
        // begin mem_pc_src == 1
        else if(mem_pc_src == 1&& !mem_predict) begin // jalr
          pc <= mem_alu_result;  // jalr ���ڼĴ���+������ֵ(��alu���)
        end
        // end mem_pc_src == 1
        // =========================================
        // begin mem_pc_src == 2
        else if(mem_pc_src == 2) begin //jal ���� branch
          if (mem_branch == 1) begin // branch ����
            // =========================================
            // begin bne
            if(mem_b_type == 0) begin // bne
              if(mem_zero == 0&& !mem_predict) begin //�����
                pc <= mem_pc + mem_imm;  // immgen ��������
              end else begin
                if(is_load) pc <= pc;
                else if(bht_predict && btb_read_found)
                  pc <= btb_read_predict_pc;
                else pc <= pc + 4;
              end
            end 
            // end bne
            // =========================================
            // begin beq
            else if(mem_b_type == 1) begin // beq
              if(mem_zero == 1&& !mem_predict) begin //���
                pc <= mem_pc + mem_imm;   //immgen ��������
              end else begin
                if(is_load) pc <= pc;
                else if(bht_predict && btb_read_found)
                  pc <= btb_read_predict_pc;
                else pc <= pc + 4;
              end
            end
            // end beq
            // =========================================
            // begin blt
            else if(mem_b_type == 2) begin // blt
              if(mem_alu_result == 1 || mem_zero == 1&& !mem_predict) begin // a <= b
                pc <= mem_pc + mem_imm;   //immgen ��������
              end else begin
                if(is_load) pc <= pc;
                else if(bht_predict && btb_read_found)
                  pc <= btb_read_predict_pc;
                else pc <= pc + 4;
              end
            end
            // end blt
            // =========================================
            // begin bge
            else if(mem_b_type == 3) begin // bge
              if(mem_alu_result == 0 && !mem_predict) begin // a >= b
                pc <= mem_pc + mem_imm;   //immgen ��������
              end else begin
                if(is_load) pc <= pc;
                else if(bht_predict && btb_read_found)
                  pc <= btb_read_predict_pc;
                else pc <= pc + 4;
              end
            end
            // end bge
            // =========================================
            // begin bltu
            else if(mem_b_type == 4) begin // blt
              if(mem_alu_result == 1 || mem_zero == 1&& !mem_predict) begin // a <= b
                pc <= mem_pc + mem_imm;   //immgen ��������
              end else begin
                if(is_load) pc <= pc;
                else if(bht_predict && btb_read_found)
                  pc <= btb_read_predict_pc;
                else pc <= pc + 4;
              end
            end
            // end bltu
            // =========================================
            // begin bgeu
            else if(mem_b_type == 5) begin
              if(mem_alu_result == 0&& !mem_predict) begin // a >= b
                pc <= mem_pc + mem_imm;   //immgen ��������
              end else begin
                if(is_load) pc <= pc;
                else if(bht_predict && btb_read_found)
                  pc <= btb_read_predict_pc;
                else pc <= pc + 4;
              end
            end
            // =========================================
          end
          // end branch
          // =========================================
          // begin jal
          else begin
            if(!mem_predict) begin
              pc <= mem_pc + mem_imm;  // imm_gen ���Ѿ����ƺ���
            end
          end
          // end jal
        end
        // end mem_pc_src == 2
        // =========================================
        // begin mem_pc_src == 3
        else if(mem_pc_src == 3) begin // ecall and mret
           pc <= mem_csr_data_out;
        end
        // end mem_pc_src == 3
        
      end
    end
    
    // ��ǰ�ж��Ƿ���Ҫ stall��stall �൱�ڰ� if, id, ex �׶εĿ����ź�ȫ����Ϊ 0�����µ� pc ��ʼ��ȡֵ��
    always@(posedge clk or posedge rst) begin
          if(rst) begin
            stall <= 0;
          end
          else if(stop) begin
          end
          else if(stall) begin
            stall <= 0;
            bht_write <= 0;
            btb_write <= 0;
          end
          else begin
            if(ex_pc_src == 0) begin
              stall <= 0;
              bht_write <= 0;
              btb_write <= 0;
               // �������Ҫд csr �Ĵ����ģ�ͨ�� stall ��������ð��
             if(ex_csr_write) begin
                 stall <= 1;
             end
            end
            else if(ex_pc_src == 1 && !ex_predict) begin
              stall <= 1;
              bht_write <= 1;
              bht_write_predict <= 1;
              btb_write_predict_pc <= ex_alu_result;
              btb_write <= 1;
            end
            else if(ex_pc_src == 2) begin //jal ���� branch
              if (ex_branch == 1) begin // branch ����
                // =========================================
                // begin bne
                if(ex_b_type == 0) begin // bne
                  if(ex_zero == 0&& !ex_predict) begin //�����
                    stall <= 1;
                    bht_write <= 1;
                    bht_write_predict <= 1;
                    btb_write_predict_pc <= ex_pc + ex_imm;
                    btb_write <= 1;
                  end else begin
                    stall <= 0;
                    bht_write <= 1;
                    bht_write_predict <= 0;
                    btb_write <= 0;
                  end
                // end bne
                // =========================================
                // begin beq
                end else if(ex_b_type == 1) begin // beq
                  if(ex_zero == 1&& !ex_predict) begin //���
                    stall <= 1;
                    bht_write <= 1;
                    bht_write_predict <= 1;
                    btb_write_predict_pc <= ex_pc + ex_imm;
                    btb_write <= 1;
                  end else begin
                    bht_write <= 1;
                    bht_write_predict <= 0;
                    btb_write <= 0;
                    stall <= 0;
                  end
                end
                // end beq
                // begin bgeu
                else if(ex_b_type == 5) begin
                  if(ex_alu_result == 0&& !ex_predict) begin // a >= b
                    stall <= 1;
                    bht_write <= 1;
                    bht_write_predict <= 1;
                    btb_write_predict_pc <= ex_pc + ex_imm;
                    btb_write <= 1;
                  end else begin
                    bht_write <= 1;
                    bht_write_predict <= 0;
                    btb_write <= 0;
                    stall <= 0;
                  end
                end
                // =========================================
              end
              // end branch
              // =========================================
              // begin jal
              else begin
                if(!ex_predict) begin
                  stall <= 1;
                  bht_write <= 1;
                  bht_write_predict <= 1;
                  btb_write_predict_pc <= ex_pc + ex_imm;
                  btb_write <= 1;
                end
              end
              // end jal
              // =========================================
            end
            else if(ex_pc_src == 3)begin  // ecall and mret
              stall <= 1;
            end
           
          end
          // =========================================
          
    end
    



    // =================================================
    // WB Part
    MEM_WB_Reg mem_wb_reg(
      .clk(clk),
      .rst(rst),

      .alu_result_in(mem_alu_result),

      .pc_in(mem_pc),
      .inst_in(mem_inst),

      .pc_src_in(mem_pc_src),
      .reg_write_in(mem_reg_write),
      .alu_src_b_in(mem_alu_src),
      .branch_in(mem_branch),
      .b_type_in(mem_b_type),
      .alu_op_in(mem_alu_op),
      .mem_to_reg_in(mem_mem_to_reg),
      .mem_write_in(mem_mem_write),

      .imm_in(mem_imm),
      .memory_data_in(mem_memory_data),
      .csr_write_in(mem_csr_write),
      .csr_ecall_in(mem_ecall),
      .csr_data_out_in(mem_csr_data_out),
      
      .stall(0),
      .stop(stop),

      .inst_out(wb_inst),
      .pc_out(wb_pc),

      .alu_result_out(wb_alu_result),

      .pc_src_out(wb_pc_src),
      .reg_write_out(wb_reg_write),
      .alu_src_b_out(wb_alu_src),
      .branch_out(wb_branch),
      .b_type_out(wb_b_type),
      .alu_op_out(wb_alu_op),
      .mem_to_reg_out(wb_mem_to_reg),
      .mem_write_out(wb_mem_write),
      .imm_out(wb_imm),
      .csr_write_out(wb_csr_write),
      .csr_ecall_out(wb_ecall),
      .csr_data_out_out(wb_csr_data_out),
      .memory_data_out(wb_memory_data)
    );
    
    // 000�� ALU
    // 001�� imm
    // 010�� pc + 4
    // 011�� memory
    // 100�� csr
    // 101�� pc + imm 
    wire[63:0] wb_memory_write_data; // ����Ҫд�ؼĴ���������
    wire wb_is_ld = wb_funct3 == 011;
    wire wb_is_lw = wb_funct3 == 010;
    wire wb_is_lbu = wb_funct3 == 100;
    assign wb_memory_write_data = (wb_is_ld) ? wb_memory_data : 
                                   (wb_is_lw) ? {{32'b0},{wb_memory_data[31:0]}} :
                                   (wb_is_lbu) ? {56'b0,wb_memory_data[7:0]} :
                                   64'b0;
    MUX8T1_32 write_register_mux(
      .I0(wb_alu_result),
      .I1(wb_imm),
      .I2(wb_pc+4),
      .I3(wb_memory_write_data),
      .I4(wb_csr_data_out),
      .I5(wb_pc + wb_imm),
      .s(wb_mem_to_reg),
      .o(wb_write_data_to_reg)
    );
    
    

    
    

    

    
    

        
        

          
endmodule

