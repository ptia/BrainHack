`default_nettype none

module inc_dec (i_inc_dec, i_arg, o_res);
  parameter c_arg_width = 8;
  input  wire i_inc_dec;
  input  wire [c_arg_width - 1 : 0] i_arg;
  output wire [c_arg_width - 1 : 0] o_res;

  assign o_res = i_arg + {{(c_arg_width - 1){i_inc_dec}}, 1'b1};
endmodule
