#BrainHack
A RISC CPU whose instruction set is the minimalist programming language Brainfuck. Developed for ICHack19.

##Language
6 possible instructions:
- < > : move head left or right on tape (head ++ or --)
- + - : increment or decrement value under head (tape[head] ++ or --)
- [...] : loop (do {...} while (tape[head] != 0);)
