`include "inc_dec.v"
`include "register.v"
`include "ram.v"
`include "clock_divider.v"

`default_nettype none

`define instr_width       3 //4-bit instructions

`define tape_data_width   8 //8-bit tape cells
`define tape_addr_width   8 //tape length: 256
`define prgmem_addr_width 8 //prog length: 256
`define stack_addr_width  4 // max 32 nested []

module brainhack (i_clock, i_tape_data, i_prgmem_data, i_stack_data, 
                  o_tape_in, o_tape_addr, o_tape_data, o_prgmem_addr, o_stack_in, o_stack_addr, o_stack_data);

  input wire i_clock;
  input wire [`tape_data_width - 1 : 0]   i_tape_data;
  input wire [`instr_width - 1 : 0]       i_prgmem_data;
  input wire [`prgmem_addr_width - 1 : 0] i_stack_data;

  output wire o_tape_in, o_stack_in;
  output wire [`tape_addr_width - 1 : 0]   o_tape_addr;
  output wire [`tape_data_width - 1 : 0]   o_tape_data;
  output wire [`prgmem_addr_width - 1 : 0] o_prgmem_addr;
  output wire [`stack_addr_width - 1 : 0]  o_stack_addr;
  output wire [`prgmem_addr_width - 1 : 0] o_stack_data;

// CLOCKS
  wire run, fetch; //0: run, 1: fetch
  clock_divider iclock_divider(i_clock, fetch);
  assign run = !fetch;


// CONTROL
  // ZERO
  wire zero;
  assign zero = !(|i_tape_data);

  // IR
  register #(`instr_width) reg_ir (i_clock, fetch && i_clock, i_prgmem_data, instr);
  wire [`instr_width - 1 : 0] instr;
  wire instr_tape    = instr[2 : 1] == 2'b01; //+-
  wire instr_ptr     = instr[2 : 1] == 2'b10; //><
  wire instr_stack   = instr[2 : 1] == 2'b11; //[]
  wire instr_inc_dec = instr[0];              //+>[ vs -<]

  // PC
  register #(`prgmem_addr_width) reg_pc (i_clock, ctrl_pc_in, pc_in, o_prgmem_addr);
  inc #(`prgmem_addr_width) pc_inc (o_prgmem_addr, pc_inc_res);
  wire [`prgmem_addr_width - 1 : 0] pc_inc_res;
  tri  [`prgmem_addr_width - 1 : 0] pc_in = run ? i_stack_data : pc_inc_res;
  wire ctrl_pc_in =  (run   && !i_clock && instr_stack && instr_inc_dec && !zero) 
                  || (fetch && !i_clock);

  // STACK
  assign o_stack_data = o_prgmem_addr;
  assign o_stack_in = run && i_clock && instr_stack && !instr_inc_dec;

  // SP
  inc_dec #(`stack_addr_width) sp_inc_dec (instr_inc_dec, o_stack_addr, sp_in);
  register #(`stack_addr_width) reg_sp (i_clock, ctrl_sp_in, sp_in, o_stack_addr);
  wire [`stack_addr_width - 1 : 0] sp_in;
  wire ctrl_sp_in = run && instr_stack 
                        && ((!i_clock && !instr_inc_dec) 
                          || (i_clock && instr_inc_dec && zero));


// USER
  // PTR
  inc_dec  #(`tape_addr_width) ptr_inc_dec (instr_inc_dec, o_tape_addr, ptr_in);
  register #(`tape_addr_width) reg_ptr (i_clock, run && !i_clock && instr_ptr, ptr_in, o_tape_addr);
  wire [`tape_addr_width - 1 : 0] ptr_in;

  // TAPE
  inc_dec #(`tape_data_width) tape_inc_dec (instr_inc_dec, i_tape_data, o_tape_data);
  assign o_tape_in = run && !i_clock && instr_tape;
  
endmodule
