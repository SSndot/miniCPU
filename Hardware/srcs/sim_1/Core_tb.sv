`timescale 1ns / 1ps



module Core_tb
    #(parameter T = 40)();
    // input
    logic        clk;
    logic        aresetn;
    logic        step;
    logic        debug_mode;
    logic [4:0]  debug_reg_addr; // register address
    logic [63:0] data_in;
    logic [63:0] chip_debug_in;
    // output
    logic [63:0] address;
    logic [63:0] data_out;
    logic [63:0] chip_debug_out0;
    logic [63:0] chip_debug_out1;
    logic [63:0] chip_debug_out2;
    logic [63:0] chip_debug_out3;

    // local
    logic [63:0]pc_out, addr_out;
    logic [31:0] inst;




    Core uut(
        .clk(clk),
        .aresetn(aresetn),
        .step(step),
        .debug_mode(debug_mode),
        .debug_reg_addr(debug_reg_addr), // register address
        .address(address),
        .data_out(data_out),
        .data_in(data_in),
        
        .chip_debug_in(chip_debug_in),
        .chip_debug_out0(chip_debug_out0),
        .chip_debug_out1(chip_debug_out1),
        .chip_debug_out2(chip_debug_out2),
        .chip_debug_out3(chip_debug_out3)
    );

    assign pc_out = chip_debug_out0;    
    assign addr_out = chip_debug_out1;
    assign inst = chip_debug_out3;
    assign debug_reg_addr = 1;

    integer i;
    initial begin
        aresetn = 0;
        clk = 1;
        step = 0;
        debug_mode = 1;
        #100;
        
        fork
            forever #(T/2) clk <= ~clk;
            #(2*T) aresetn = 1;
        join
    end
endmodule