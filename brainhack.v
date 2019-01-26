`include "inc_dec.v"
`include "register.v"
`include "ram.v"
`include "clock_divider.v"

`default_nettype none

`define instr_width 8
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
  wire ctrl_tape_in, ctrl_ptr_in, ctrl_stack_out, ctrl_sp_in, ctrl_stack_in, ctrl_inc_dec, ctrl_pc_in;
  wire zero;
  assign zero = !(|i_tape_data);

  // IR
  wire [`instr_width - 1 : 0] instr;
  register #(`instr_width) reg_ir (i_clock, fetch && i_clock, i_prgmem_data, instr);
  assign {ctrl_tape_in, ctrl_ptr_in, ctrl_stack_in, ctrl_stack_out, ctrl_inc_dec} = instr [4 : 0];

  // PC
  tri [`prgmem_addr_width - 1 : 0] pc_in;
  wire [`prgmem_addr_width - 1 : 0] pc_inc_res;
  assign pc_in = run ? i_stack_data : pc_inc_res;
  inc #(`prgmem_addr_width) pc_inc (o_prgmem_addr, pc_inc_res);
  register #(`prgmem_addr_width) reg_pc (i_clock, ctrl_pc_in, pc_in, o_prgmem_addr);
  assign ctrl_pc_in = (run && !i_clock && ctrl_stack_out && !zero) || (fetch && !i_clock);

  // STACK
  //wire [`prgmem_addr_width - 1 : 0] pc_dec_res;
  //dec #(`prgmem_addr_width) pc_dec (o_prgmem_addr, pc_dec_res);
  assign o_stack_data = o_prgmem_addr;
  assign o_stack_in = run && i_clock && ctrl_stack_in ;

  // SP
  wire [`stack_addr_width - 1 : 0] sp_in;
  inc_dec #(`stack_addr_width) sp_inc_dec (ctrl_inc_dec, o_stack_addr, sp_in);
  register #(`stack_addr_width) reg_sp (i_clock, ctrl_sp_in, sp_in, o_stack_addr);
  assign ctrl_sp_in = run && (ctrl_stack_in || ctrl_stack_out) && ((!i_clock && ctrl_stack_in) || (i_clock && ctrl_stack_out && zero));


// USER
  // PTR
  wire [`tape_addr_width - 1 : 0] ptr_in;
  inc_dec  #(`tape_addr_width) ptr_inc_dec (ctrl_inc_dec, o_tape_addr, ptr_in);
  register #(`tape_addr_width) reg_ptr (i_clock, run && !i_clock && ctrl_ptr_in, ptr_in, o_tape_addr);

  // TAPE
  inc_dec #(`tape_data_width) tape_inc_dec (ctrl_inc_dec, i_tape_data, o_tape_data);
  assign o_tape_in = run && !i_clock && ctrl_tape_in;
  
endmodule

module testbench;
  reg clock = 0;


  wire [`tape_data_width - 1 : 0]   i_tape_data;
  wire [`instr_width - 1 : 0]        i_prgmem_data;
  wire [`prgmem_addr_width - 1 : 0] i_stack_data;

  wire o_tape_in, o_stack_in;
  wire [`tape_addr_width - 1 : 0]   o_tape_addr;
  wire [`tape_data_width - 1 : 0]   o_tape_data;
  wire [`prgmem_addr_width - 1 : 0] o_prgmem_addr;
  wire [`stack_addr_width - 1 : 0]  o_stack_addr;
  wire [`prgmem_addr_width - 1 : 0] o_stack_data;

  ram #(`tape_addr_width, `tape_data_width) tape (clock, o_tape_in, o_tape_addr, o_tape_data, i_tape_data);
  ram #(`stack_addr_width, `prgmem_addr_width) stack (clock, o_stack_in, o_stack_addr, o_stack_data, i_stack_data);
  rom #(`prgmem_addr_width, `instr_width) prgmem (o_prgmem_addr, i_prgmem_data);

  brainhack bh (clock, i_tape_data, i_prgmem_data, i_stack_data, o_tape_in, o_tape_addr, o_tape_data, o_prgmem_addr, o_stack_in, o_stack_addr, o_stack_data);
 
  initial begin
    tape.ram_content[0] = 0;
    prgmem.rom_content[1] = 0;
    prgmem.rom_content[2] = 8'b00000100; // [
    prgmem.rom_content[3] = 8'b00000100; // [
    prgmem.rom_content[4] = 8'b00010001; // -
    prgmem.rom_content[5] = 8'b00000011; // ]
    prgmem.rom_content[6] = 8'b00000011; // ]

    //prgmem.rom_content[3] = 8'b00001000; // > ptr_in

    $monitor("#%b, IR %b, PC %d (%b), r/f %b, SP %d (%b), TP %d (%b) z%b, SK %d (%b)", clock, bh.reg_ir.stored_data, bh.reg_pc.stored_data,bh.ctrl_pc_in, bh.fetch, bh.reg_sp.stored_data, bh.ctrl_sp_in, i_tape_data, bh.ctrl_tape_in, bh.zero, stack.ram_content[1], o_stack_in);
  end

  always
    #2 clock = !clock;

  always
    #5000 $finish;

endmodule
