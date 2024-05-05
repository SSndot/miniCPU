`timescale 1ns / 1ps


module myRom(
    input [10:0] address,
    output [31:0] out
);
    reg [31:0] rom [0:2047];


    localparam FILE_PATH = "../../../../lab2_rom.sim";
    initial begin
        $readmemh(FILE_PATH, rom);
    end


    assign out = rom[address];
endmodule
