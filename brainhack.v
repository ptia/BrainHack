`include "inc_dec.v"
`include "register.v"
`include "memory.v"

`default_nettype none

`define instr_width       3 //3-bit instructions

`define tape_data_width   8 //8-bit tape cells
`define tape_addr_width   8 //tape length: 256
`define prgmem_addr_width 8 //prog length: 256
`define stack_addr_width  4 //max 32 nested []

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

// CONTROL
  // IR
  wire [`instr_width - 1 : 0] instr = i_prgmem_data;
  wire instr_tape    = i_prgmem_data[2 : 1] == 2'b01; //+-
  wire instr_ptr     = i_prgmem_data[2 : 1] == 2'b10; //><
  wire instr_stack   = i_prgmem_data[2 : 1] == 2'b11; //[]
  wire instr_dec     = i_prgmem_data[0];              //+>[ vs -<]
  wire instr_inc     = !instr_dec;

  wire zero = !(|i_tape_data);

  // SKIP LOOPS
  reg ctrl_skip_loop = 0;
  reg [`stack_addr_width - 1 : 0] reg_skip_loop_sp;
  always @ (negedge i_clock) begin
    if (ctrl_skip_loop) begin
      if (instr_stack && instr_dec && sp_data == reg_skip_loop_sp)
        ctrl_skip_loop <= 0;
    end 
    else if (instr_stack && instr_inc && zero) begin
      reg_skip_loop_sp <= sp_inc_dec_res;
      ctrl_skip_loop <= 1;
    end
  end

  // PC
  register #(`prgmem_addr_width) reg_pc (i_clock, 1'b1, pc_in, o_prgmem_addr);
  inc_dec #(`prgmem_addr_width) pc_inc (1'b0, o_prgmem_addr, pc_inc_res);
  wire [`prgmem_addr_width - 1 : 0] pc_inc_res;
  wire [`prgmem_addr_width - 1 : 0] pc_in = ctrl_pc_in_select ? i_stack_data : pc_inc_res;
  wire ctrl_pc_in_select = !ctrl_skip_loop && instr_stack && instr_dec && !zero;

  // SP
  inc_dec #(`stack_addr_width) sp_inc_dec (instr_dec, sp_data, sp_inc_dec_res);
  register #(`stack_addr_width) reg_sp (i_clock, ctrl_sp_in, sp_inc_dec_res, sp_data);
  wire [`stack_addr_width - 1 : 0] sp_data;
  wire [`stack_addr_width - 1 : 0] sp_inc_dec_res;
  wire ctrl_sp_in = instr_stack && (instr_inc || instr_dec && zero);

  // STACK
  assign o_stack_data = pc_inc_res;
  assign o_stack_in = instr_stack && instr_inc;
  assign o_stack_addr = instr_inc ? sp_inc_dec_res : sp_data;


// USER
  // PTR
  inc_dec  #(`tape_addr_width) ptr_inc_dec (instr_dec, o_tape_addr, ptr_in);
  register #(`tape_addr_width) reg_ptr (i_clock, ctrl_ptr_in, ptr_in, o_tape_addr);
  wire [`tape_addr_width - 1 : 0] ptr_in;
  wire ctrl_ptr_in = !ctrl_skip_loop && instr_ptr;

  // TAPE
  inc_dec #(`tape_data_width) tape_inc_dec (instr_dec, i_tape_data, o_tape_data);
  assign o_tape_in = !ctrl_skip_loop && instr_tape;
  
endmodule
