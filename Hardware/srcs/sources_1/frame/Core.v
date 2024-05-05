`timescale 1ns / 1ps

module Core(
    input  wire        clk,
    input  wire        aresetn,  // reset �Ƿ���
    input  wire        step,  // �Ƿ�Ϊ step ģʽ
    input  wire        debug_mode,  // �Ƿ���debugģʽ

    // ���Բ���1
     input  wire [63:0] data_in,   //�����ڲ��ԣ���������ָ���ڴ��ַ
     output wire [63:0] address,   // �����ڲ���
     output wire [63:0] data_out,  // �����ڲ��ԣ��������ڲ����ڴ��ַ����

    // ���Բ���2
     input  wire [4:0]  debug_reg_addr, // register address
    
     input  wire [63:0] chip_debug_in,
     output wire [63:0] chip_debug_out0,   // pc ��ֵ
     output wire [63:0] chip_debug_out1,   // ��д�ĵ�ַ
     output wire [63:0] chip_debug_out2,   //�Ĵ�������
     output wire [63:0] chip_debug_out3    // gp ��ֵ
);


    // rst = ~aresetn �� δ֪
    // mem_write �� �Ƿ�д�������ڴ�
    // mem_clk�� �ڴ����ڣ�����Ҫ���ǹ�
    // cpu_clk��CPU���ڣ�����Ҫ���ǹ�
    wire rst, mem_write, mem_clk, cpu_clk;
    // inst����ȡ����ָ��
    // core_data_in ���������ڴ��ȡ������
    // addr_out �� Ҫд�������ڴ��ַ
    wire [31:0] inst;
    wire [63:0] core_data_in, addr_out, core_data_out, pc_out;
    reg  [63:0] clk_div;  // ʱ�Ӽ�¼������¼�����˶��ٸ�ʱ������
    
    assign rst = ~aresetn;
     wire [63:0] debug_reg_out;
    SCPU cpu(
        .clk(cpu_clk),
        .rst(rst),
        .inst(inst),
        .data_in(core_data_in),      //�������ڴ��ȡ�����ݣ�loadָ����Ҫ��
        .stop(0),

        //���Բ���
        // .debug_reg_addr(debug_reg_addr),
        // .debug_reg_out(debug_reg_out),
        
        // ����Ϊ���
        .addr_out(addr_out),         // Ҫд�������ڴ��ַ
        .data_out(core_data_out),    // Ҫд�������ڴ��ֵ
        .pc_out(pc_out),             // ���ĺ�� pc ֵ
        .mem_write(mem_write)        // �Ƿ�д�������ڴ�
    );
    
    always @(posedge clk) begin
        if(rst) clk_div <= 0;
        else clk_div <= clk_div + 1;
    end
    assign mem_clk = ~clk_div[0]; // 50mhz
    assign cpu_clk = debug_mode ? clk_div[0] : step;  // debug mode Ϊ1(sw15����ʱ)ʱ�Զ����С���������step����

    localparam start_addr = 64'h8020_0000;
    
     Rom rom_unit (
        .clka(mem_clk), 
        .wea(0),
        .addra((pc_out - start_addr)/4),  // ��ַ����
        .dina(0),
        .douta(inst) // ��Ŀ���ַ��ȡ��ָ��
     );

//    myRom rom_unit(
//        .address(pc_out/4),
//        .out(inst)
//    );
    
    // ���debug_mode
    wire mem_write_debug = step ? 0: mem_write;
    wire[63:0] addr_out_debug = step ? data_in: addr_out;

     Ram ram_unit (
         .clka(mem_clk),  // ʱ��
         .wea(mem_write_debug),   // 1 д�ڴ棬0���ڴ�
         .addra((addr_out - start_addr)/4), // ���룺��orд�ڴ�ĵ�ַ
         .dina(core_data_out),  // ���룺Ҫд������
         .douta(core_data_in)  // �������ȡ������
     );

//    myRam ram_unit(
//        .clk(mem_clk),
//        .we(mem_write),
//        .address(addr_out/4),  // ע���ַ�ǳ��� 4 �ģ�������������������
//        .write_data(core_data_out),
//        .read_data(core_data_in)
//    );
    
    
    

     assign chip_debug_out0 = pc_out;  // pc ��ֵ
     assign chip_debug_out1 = addr_out;   // ����д�ĵ�ַ
     assign chip_debug_out2 = inst;
     assign chip_debug_out2 = debug_reg_out;  // �Ĵ�������
     assign chip_debug_out3 = inst; //ָ���ֵ


endmodule
