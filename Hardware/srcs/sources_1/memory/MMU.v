
`timescale 1ns / 1ps

module MMU(
  input rst,
  input clk,
  input[63:0] va,
  input[63:0] satp,
  input[63:0] mem_value,
  output reg stop,
  output reg[63:0] pa
);

wire[3:0] mode = satp[63:60]; // mode of MMU
wire[43:0] root_page_ppn = satp[43:0]; // physical page number of level 1 page table

wire[11:0] offset = va[11:0];
wire[8:0] vpn0 = va[20:12]; // virtual page number of level 0 page table
wire[8:0] vpn1 = va[29:21]; // virtual page number of level 1 page table
wire[8:0] vpn2 = va[38:30]; // virtual page number of level 2 page table

wire[9:0] flags = mem_value[9:0]; // flags of page table entry

reg[1:0] page_level;

always@(posedge clk or posedge rst) begin
  if(rst) begin
    stop = 0;
    page_level = 0;
    pa = 0;
  end
  else begin
    // -----------------------------------------
    // satp == 0
    if(mode == 0) begin
      pa <= va;
      stop <= 0;
    end
    // -----------------------------------------
    // sv39 mode
    if(mode == 8) begin
      if(page_level != 0 && flags[3:1] != 0) begin  // rwx are not all zero, then this page is the last page
        pa = {{mem_value[53:10]}, {offset}};
        page_level = 0;
        stop = 0;
      end
      else begin // the page is not the last page
        case(page_level)
          0: pa = (root_page_ppn << 12) + vpn2;
          1: pa = ((mem_value[53:10]) << 12) + vpn1;
          2: pa = ((mem_value[53:10]) << 12) + vpn0;
        endcase
        stop = 1;
        page_level = page_level + 1;
      end
    end
  end
end

endmodule
