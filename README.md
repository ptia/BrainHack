# BrainHack
A RISC CPU whose instruction set is the minimalist programming language Brainfuck. 
Developed in one night for ICHack19. Implemented in Verilog.

## Language
6 possible instructions:
- < > : move head left or right on tape (head ++ or --)
- + - : increment or decrement value under head (tape[head] ++ or --)
- [...] : loop (do {...} while (tape[head] != 0);)

## Implementation
- Harvard architecture
- RISC structure, 4 clock transitions per instruction (2 run + 2 fetch)
- programs: ROM of 3-bit instructions
- tape: RAM + head address register
- [] call stack: RAM + tos address register
