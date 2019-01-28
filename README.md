# BrainHack
A RISC CPU whose instruction set is the minimalist programming language Brainfuck. 

Implemented in Verilog, fully synthesisable.
Comes with python assembler.

Developed in one night for ICHack19. 



## Language
6 instructions:
- < > : move head left or right on tape (head ++ or --)
- + - : increment or decrement value under head (tape[head] ++ or --)
- [...] : loop (do {...} while (tape[head] != 0);)

## Implementation
- Harvard architecture
- RISC structure, 4 clock transitions per instruction (2 run + 2 fetch)
- programs: ROM of 3-bit instructions
- tape: RAM + head address register
- [] call stack: RAM + tos address register