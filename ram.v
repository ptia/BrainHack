`default_nettype none

module ram (i_clock, i_enable_in, i_addr, i_data, o_data);
  parameter c_addr_width = 8;
  parameter c_data_width = 8;
  input wire i_clock, i_enable_in;
  input wire [c_addr_width - 1 : 0] i_addr;
  input wire [c_data_width - 1 : 0] i_data;
  output wire [c_data_width - 1 : 0] o_data;

  reg [c_data_width - 1 : 0] ram_content [0 : 2**c_addr_width-1];
  
  assign o_data = ram_content[i_addr];

  always @ (posedge i_clock or negedge i_clock)
    if (i_enable_in)
      ram_content[i_addr] <= i_data;

endmodule

module rom (i_addr, o_data);
  parameter c_addr_width = 8;
  parameter c_data_width = 8;
  input wire [c_addr_width - 1 : 0] i_addr;
  output wire [c_data_width - 1 : 0] o_data;

  reg [c_data_width - 1 : 0] rom_content [0 : 2**c_addr_width-1];

  assign o_data = rom_content[i_addr];

endmodule
