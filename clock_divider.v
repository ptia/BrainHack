`default_nettype none

module clock_divider (i_clock, o_clock);
  input wire i_clock;
  output reg o_clock = 1; //TODO this is a hack

  always @ (negedge i_clock)
    o_clock = !o_clock;

endmodule

/*
module testbench;
  reg clk = 0;
  wire res;

  clock_divider cd (clk, res);

  always
    #5 clk = !clk;

  initial begin
    $monitor("%b%b", clk, res);
    #50 $finish;
  end
endmodule
*/
