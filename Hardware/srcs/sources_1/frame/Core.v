`timescale 1ns / 1ps

module Core(
    input  wire        clk,
    input  wire        aresetn,  // reset 是否按下
    input  wire        step,  // 是否为 step 模式
    input  wire        debug_mode,  // 是否是debug模式

    // 测试部分1
     input  wire [63:0] data_in,   //仅用于测试，这里用于指定内存地址
     output wire [63:0] address,   // 仅用于测试
     output wire [63:0] data_out,  // 仅用于测试，这里用于测试内存地址内容

    // 测试部分2
     input  wire [4:0]  debug_reg_addr, // register address
    
     input  wire [63:0] chip_debug_in,
     output wire [63:0] chip_debug_out0,   // pc 的值
     output wire [63:0] chip_debug_out1,   // 读写的地址
     output wire [63:0] chip_debug_out2,   //寄存器内容
     output wire [63:0] chip_debug_out3    // gp 的值
);


    // rst = ~aresetn ： 未知
    // mem_write ： 是否写入数据内存
    // mem_clk： 内存周期，不需要我们管
    // cpu_clk：CPU周期，不需要我们管
    wire rst, mem_write, mem_clk, cpu_clk;
    // inst：读取出的指令
    // core_data_in ：从数据内存读取的数据
    // addr_out ： 要写的数据内存地址
    wire [31:0] inst;
    wire [63:0] core_data_in, addr_out, core_data_out, pc_out;
    reg  [63:0] clk_div;  // 时钟记录器，记录经过了多少个时钟周期
    
    assign rst = ~aresetn;
     wire [63:0] debug_reg_out;
    SCPU cpu(
        .clk(cpu_clk),
        .rst(rst),
        .inst(inst),
        .data_in(core_data_in),      //从数据内存读取的数据，load指令需要用
        .stop(0),

        //测试部分
        // .debug_reg_addr(debug_reg_addr),
        // .debug_reg_out(debug_reg_out),
        
        // 以下为输出
        .addr_out(addr_out),         // 要写的数据内存地址
        .data_out(core_data_out),    // 要写入数据内存的值
        .pc_out(pc_out),             // 更改后的 pc 值
        .mem_write(mem_write)        // 是否写入数据内存
    );
    
    always @(posedge clk) begin
        if(rst) clk_div <= 0;
        else clk_div <= clk_div + 1;
    end
    assign mem_clk = ~clk_div[0]; // 50mhz
    assign cpu_clk = debug_mode ? clk_div[0] : step;  // debug mode 为1(sw15拨上时)时自动运行。。。否则按step运行

    localparam start_addr = 64'h8020_0000;
    
     Rom rom_unit (
        .clka(mem_clk), 
        .wea(0),
        .addra((pc_out - start_addr)/4),  // 地址输入
        .dina(0),
        .douta(inst) // 从目标地址读取出指令
     );

//    myRom rom_unit(
//        .address(pc_out/4),
//        .out(inst)
//    );
    
    // 添加debug_mode
    wire mem_write_debug = step ? 0: mem_write;
    wire[63:0] addr_out_debug = step ? data_in: addr_out;

     Ram ram_unit (
         .clka(mem_clk),  // 时钟
         .wea(mem_write_debug),   // 1 写内存，0读内存
         .addra((addr_out - start_addr)/4), // 输入：读or写内存的地址
         .dina(core_data_out),  // 输入：要写的数据
         .douta(core_data_in)  // 输出：读取的数据
     );

//    myRam ram_unit(
//        .clk(mem_clk),
//        .we(mem_write),
//        .address(addr_out/4),  // 注意地址是除以 4 的！！！！！！！！！！
//        .write_data(core_data_out),
//        .read_data(core_data_in)
//    );
    
    
    

     assign chip_debug_out0 = pc_out;  // pc 的值
     assign chip_debug_out1 = addr_out;   // 读或写的地址
     assign chip_debug_out2 = inst;
     assign chip_debug_out2 = debug_reg_out;  // 寄存器内容
     assign chip_debug_out3 = inst; //指令的值


endmodule
