`default_nettype none

module register (i_clock, i_enable_in, i_data, o_data);
  parameter c_width = 8;
  input wire i_clock, i_enable_in;
  input wire [c_width - 1 : 0] i_data;
  output wire [c_width - 1 : 0] o_data;

  reg [c_width - 1 : 0] stored_data;
  assign o_data = stored_data;

  always @ (posedge i_clock or negedge i_clock)
    if (i_enable_in)
      stored_data <= i_data;
endmodule
