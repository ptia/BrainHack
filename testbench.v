`include "brainhack.v"

module testbench;
  reg clock = 1;

  wire [`tape_data_width - 1 : 0]   i_tape_data;
  wire [`instr_width - 1 : 0]       i_prgmem_data;
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

  wire prgend = ^i_prgmem_data === 1'bX;
 
  initial begin
    $readmemh("tape.mem", tape.ram_content);
    $readmemb("prgrom.mem", prgmem.rom_content);

    $monitor("#%b IR %b, ", clock, i_prgmem_data, 
      "PC %d (%b), ", bh.reg_pc.stored_data, bh.ctrl_pc_in_select,
      "TP @%d %d (%b) z%b, ", bh.reg_ptr.stored_data, i_tape_data, bh.instr_tape, bh.zero,
      "SP %d (%b), ", bh.reg_sp.stored_data, bh.ctrl_sp_in,
      "SK %d (%b)", i_stack_data, o_stack_in);
  end

  always
    #2 clock = !clock;

  always @ (posedge bh.ctrl_skip_loop)
    $display("ctrl_skip_loop start, reg_skip_loop_sp = %d", o_stack_addr);

  always @ (negedge bh.ctrl_skip_loop)
    $display("ctrl_skip_loop end");

  always @ (posedge prgend)
    $finish;
endmodule
