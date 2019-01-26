`default_nettype none

module inc (i_arg, o_res);
  parameter c_arg_width = 8;
  input  wire [c_arg_width - 1 : 0] i_arg;
  output wire [c_arg_width - 1 : 0] o_res;

  assign o_res = i_arg + 1;
endmodule

module dec (i_arg, o_res);
  parameter c_arg_width = 8;
  input  wire [c_arg_width - 1 : 0] i_arg;
  output wire [c_arg_width - 1 : 0] o_res;

  assign o_res = i_arg - 1;
endmodule

module inc_dec (i_inc_dec, i_arg, o_res);
  parameter c_arg_width = 8;
  input  wire i_inc_dec;
  input  wire [c_arg_width - 1 : 0] i_arg;
  output wire [c_arg_width - 1 : 0] o_res;

  wire [c_arg_width - 1 : 0] inc_res, dec_res;
  inc #(c_arg_width) inc (i_arg, inc_res);
  dec #(c_arg_width) dec (i_arg, dec_res);

  assign o_res = i_inc_dec ? dec_res : inc_res; //0:inc 1:dec
endmodule
