`timescale 1ns / 1ps


module myRam(
    input clk,
    input we,
    input [31:0] write_data,
    input [10:0] address,
    output [31:0] read_data
    );
    reg [31:0] ram [0:2047];
    integer i;

    always @(posedge clk) begin
        if (we == 1) ram[address] <= write_data;
    end

    assign read_data = ram[address];


    localparam FILE_PATH = "../../../../lab2_ram.sim";
    initial begin
        $readmemh(FILE_PATH, ram);
    end
endmodule
