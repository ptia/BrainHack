`default_nettype none

module clock_divider (i_clock, o_clock);
  input wire i_clock;
  output reg o_clock = 0;

  always @ (posedge i_clock)
    o_clock = !i_clock;

endmodule
