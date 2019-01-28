`default_nettype none

module clock_divider (i_clock, o_clock);
  input wire i_clock;
  output reg o_clock = 0;

  always @ (negedge i_clock)
    o_clock = !o_clock;

endmodule
