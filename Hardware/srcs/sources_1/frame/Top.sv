`timescale 1ns / 1ps


module Top(
    input          clk,  
    input          resetn,  // reset 按钮是否按下
    input  [15:0]  switch,  // 拨拨的按钮
    input  [ 4:0]  button,  // 上下左右键
    
    // 输出至板子
    output [15:0]  led,  // 控制led 灯
    output [ 2:0]  rgb1,
    output [ 2:0]  rgb2,
    output [ 7:0]  num_csn,  //控制七个笔画与小数点
    output [ 7:0]  num_an    //控制那个8亮
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

//    assign data_in = {{20'b0}, {switch[11:0]}};  // 用于输入内存地址
    Core chip_inst(
        .clk(clk),  // 从 Top 输入
        .aresetn(aresetn),  // 从 IO-Manager 输入
        .step(step)    // 从 IO-Manager 输入
//        .debug_mode(switch[15]),  // 从 Top 输入
        // .debug_mode(switch[0]),
        // .debug_reg_addr(switch[11:7]),
//        .data_in(data_in),  // 用于测试：输入内存地址

        //以下为输出
        // .address(address),  // 要写的地址
//        .data_out(data_out), // 用于测试：这里用于作为内存地址值的输出

        // 以下为 debug 使用
      //  .chip_debug_in(chip_debug_in),
        // .chip_debug_out0(chip_debug_out0),
        // .chip_debug_out1(chip_debug_out1),
        // .chip_debug_out2(chip_debug_out2),   //寄存器内容
        // .chip_debug_out3(chip_debug_out3)    //gp（x3）内容
    );

    IO_Manager io_manager_inst(
        .clk(clk), // 从 Top 输入
        .resetn(resetn), // 从 Top 输入

        // to chip
        .aresetn(aresetn), // 输出
        .step(step),  // 输出：是否为单步调试状态
        .address(address), // 从 core 输入：要写的地址
//        .data_out(data_out),  // 从 core 输入：要写的值
//        .data_in(data_in),   // 输出： ???
//        .chip_debug_in(chip_debug_in), // 输出： ???
        
        // to gpio
        .switch(switch),  // 从 Top 输入
        .button(button), // 从 Top 输入
        .led(led),  // 输出：控制 led 灯
        .num_csn(num_csn), // 输出：控制七个笔画与小数点
        .num_an(num_an), // 输出：控制那个8亮
        .rgb1(rgb1),  // 输出：控制 rgb1
        .rgb2(rgb2), // 输出：控制 rgb2
        
        // debug, 根据 switch[14:12] 选择 debug 的输出
        // 即 [14:12] 表示的数值为 debug 位置
//        .debug0(32'h88888888),   // 测试数码管是否正常点亮
        .debug0(chip_debug_out0),
        .debug1({16'b0, switch[15:0]}),  // 测试开关连通情况
        .debug2({12'b0, 3'b0, button[4], 3'b0, button[3], 3'b0, button[2], 3'b0, button[1], 3'b0, button[0]}), // 测试按钮连接情况
        .debug3(32'h12345678),   // 测试译码电路
        .debug4(chip_debug_out0),  // 输出 PC 的值
        .debug5(chip_debug_out1),  // 输出访存地址
        .debug6(chip_debug_out2),  // 输出寄存器内容，由 switch[11:7] 控制
        .debug7(chip_debug_out3)  // gp 内容
    );
endmodule
