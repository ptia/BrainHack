# BrainHack
A **RISC CPU** whose instruction set is the minimalist programming language **Brainfuck**.

Developed in one night for *ICHack19*.
Later optimised for memory requirements and **parallelism**: each instruction takes only 1 clock cycle.

Implemented in **Verilog**, fully synthesisable.
Comes with **python assembler**.


## Language
6 instructions:
- < > : move head left or right on tape (head ++ or --)
- \+ \- : increment or decrement value under head (tape[head] ++ or --)
- [...] : loop (while (tape[head] != 0) { ... })

## Implementation
- Harvard, RISC architecture
- 1 clock transition per instruction
- programs: ROM of 3-bit instructions
- tape: RAM + head address register
- [] call stack: RAM + tos address register
