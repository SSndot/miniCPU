`timescale 1ns / 1ps


module Top(
    input          clk,  
    input          resetn,  // reset ��ť�Ƿ���
    input  [15:0]  switch,  // �����İ�ť
    input  [ 4:0]  button,  // �������Ҽ�
    
    // ���������
    output [15:0]  led,  // ����led ��
    output [ 2:0]  rgb1,
    output [ 2:0]  rgb2,
    output [ 7:0]  num_csn,  //�����߸��ʻ���С����
    output [ 7:0]  num_an    //�����Ǹ�8��
);
    logic aresetn;
    logic step;

    logic [31:0] address;
//    logic [31:0] data_out;
//    logic [31:0] data_in;

//    logic [31:0] chip_debug_in;
    logic [31:0] chip_debug_out0;
    logic [31:0] chip_debug_out1;
    logic [31:0] chip_debug_out2;
    logic [31:0] chip_debug_out3;

//    assign data_in = {{20'b0}, {switch[11:0]}};  // ���������ڴ��ַ
    Core chip_inst(
        .clk(clk),  // �� Top ����
        .aresetn(aresetn),  // �� IO-Manager ����
        .step(step)    // �� IO-Manager ����
//        .debug_mode(switch[15]),  // �� Top ����
        // .debug_mode(switch[0]),
        // .debug_reg_addr(switch[11:7]),
//        .data_in(data_in),  // ���ڲ��ԣ������ڴ��ַ

        //����Ϊ���
        // .address(address),  // Ҫд�ĵ�ַ
//        .data_out(data_out), // ���ڲ��ԣ�����������Ϊ�ڴ��ֵַ�����

        // ����Ϊ debug ʹ��
      //  .chip_debug_in(chip_debug_in),
        // .chip_debug_out0(chip_debug_out0),
        // .chip_debug_out1(chip_debug_out1),
        // .chip_debug_out2(chip_debug_out2),   //�Ĵ�������
        // .chip_debug_out3(chip_debug_out3)    //gp��x3������
    );

    IO_Manager io_manager_inst(
        .clk(clk), // �� Top ����
        .resetn(resetn), // �� Top ����

        // to chip
        .aresetn(aresetn), // ���
        .step(step),  // ������Ƿ�Ϊ��������״̬
        .address(address), // �� core ���룺Ҫд�ĵ�ַ
//        .data_out(data_out),  // �� core ���룺Ҫд��ֵ
//        .data_in(data_in),   // ����� ???
//        .chip_debug_in(chip_debug_in), // ����� ???
        
        // to gpio
        .switch(switch),  // �� Top ����
        .button(button), // �� Top ����
        .led(led),  // ��������� led ��
        .num_csn(num_csn), // ����������߸��ʻ���С����
        .num_an(num_an), // ����������Ǹ�8��
        .rgb1(rgb1),  // ��������� rgb1
        .rgb2(rgb2), // ��������� rgb2
        
        // debug, ���� switch[14:12] ѡ�� debug �����
        // �� [14:12] ��ʾ����ֵΪ debug λ��
//        .debug0(32'h88888888),   // ����������Ƿ���������
        .debug0(chip_debug_out0),
        .debug1({16'b0, switch[15:0]}),  // ���Կ�����ͨ���
        .debug2({12'b0, 3'b0, button[4], 3'b0, button[3], 3'b0, button[2], 3'b0, button[1], 3'b0, button[0]}), // ���԰�ť�������
        .debug3(32'h12345678),   // ���������·
        .debug4(chip_debug_out0),  // ��� PC ��ֵ
        .debug5(chip_debug_out1),  // ����ô��ַ
        .debug6(chip_debug_out2),  // ����Ĵ������ݣ��� switch[11:7] ����
        .debug7(chip_debug_out3)  // gp ����
    );
endmodule
