`include "inc_dec.v"
`include "register.v"
`include "ram.v"
`include "clock_divider.v"

`default_nettype none

`define instr_width 8
module brainhack (i_clock, i_tape_data, i_prgmem_data, i_stack_data, 
                  o_tape_in, o_tape_addr, o_tape_data, o_prgmem_addr, o_stack_in, o_stack_addr, o_stack_data);
  // TODO move this to a define stmt
  parameter c_tape_data_width   = 8; //8-bit tape cells
  parameter c_tape_addr_width   = 8; //tape length: 256
  parameter c_prgmem_addr_width = 8; //prog length: 256
  parameter c_stack_addr_width  = 4; // max 32 nested []

  input wire i_clock;
  input wire [c_tape_data_width - 1 : 0]   i_tape_data;
  input wire [`instr_width - 1 : 0]        i_prgmem_data;
  input wire [c_prgmem_addr_width - 1 : 0] i_stack_data;

  output wire o_tape_in, o_stack_in;
  output wire [c_tape_addr_width - 1 : 0]   o_tape_addr;
  output wire [c_tape_data_width - 1 : 0]   o_tape_data;
  output wire [c_prgmem_addr_width - 1 : 0] o_prgmem_addr;
  output wire [c_stack_addr_width - 1 : 0]  o_stack_addr;
  output wire [c_prgmem_addr_width - 1 : 0] o_stack_data;

// CLOCKS
  wire run, fetch; //0: run, 1: fetch
  clock_divider ic_clock_divider(i_clock, fetch);
  assign run = !fetch;


// CONTROL
  wire ctrl_tape_in, ctrl_ptr_in, ctrl_stack_out, ctrl_sp_in, ctrl_stack_in, ctrl_inc_dec, ctrl_pc_in;
  wire zero; //TODO nand
  assign zero = !(&i_tape_data);

  // IR
  wire [`instr_width - 1 : 0] instr;
  register #(`instr_width) reg_ir (i_clock, fetch && i_clock, i_prgmem_data, instr);

  // PC
  tri [c_prgmem_addr_width - 1 : 0] pc_in;
  wire [c_prgmem_addr_width - 1 : 0] pc_inc_res;
  assign pc_in = run ? i_stack_data : pc_inc_res;
  inc #(c_prgmem_addr_width) pc_inc (o_prgmem_addr, pc_inc_res);
  register #(c_prgmem_addr_width) reg_pc (i_clock, ctrl_pc_in, pc_in, o_prgmem_addr);
  assign ctrl_pc_in = (run && i_clock && ctrl_stack_out) || (fetch && !i_clock);

  // STACK
  wire [c_prgmem_addr_width - 1 : 0] pc_dec_res;
  dec #(c_prgmem_addr_width) pc_dec (o_prgmem_addr, pc_dec_res);
  assign o_stack_data = pc_dec_res;

  // SP
  wire [c_stack_addr_width - 1 : 0] sp_in;
  inc_dec #(c_stack_addr_width) sp_inc_dec (ctrl_inc_dec, o_stack_addr, sp_in);
  register #(c_stack_addr_width) reg_sp (i_clock, ctrl_sp_in, sp_in, o_stack_addr);
  assign sp_in = run && ((!i_clock && ctrl_inc_dec) || (i_clock && !ctrl_inc_dec));


// USER
  // PTR
  wire [c_tape_addr_width - 1 : 0] ptr_in;
  inc_dec  #(c_tape_addr_width) ptr_inc_dec (ctrl_inc_dec, o_tape_addr, ptr_in);
  register #(c_tape_addr_width) ptr (i_clock, run && !i_clock && ptr_in, ptr_in, o_tape_addr);

  // TAPE
  inc_dec #(c_tape_data_width) tape_inc_dec (ctrl_inc_dec, i_tape_data, o_tape_data);
  assign o_tape_in = run && ctrl_tape_in;
  
endmodule
