# BrainHack
A RISC CPU whose instruction set is the minimalist programming language Brainfuck.

Implemented in Verilog, fully synthesisable.
Comes with python assembler.

Developed in one night for ICHack19.
Later optimised for memory requirements and parallelism (run & fetch at the same time).



## Language
6 instructions:
- < > : move head left or right on tape (head ++ or --)
- + - : increment or decrement value under head (tape[head] ++ or --)
- [...] : loop (while (tape[head] != 0) { ... })

## Implementation
- Harvard, RISCH architecture
- 2 clock transitions per instruction (run & fetch happen in parallell(!))
- programs: ROM of 3-bit instructions
- tape: RAM + head address register
- [] call stack: RAM + tos address register
