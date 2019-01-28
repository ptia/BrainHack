#! /usr/bin/python
import sys
bins = {'+': "010",
        '-': "011",
        '>': "100",
        '<': "101",
        '[': "110",
        ']': "111" }

f_in = open(sys.argv[1])
f_out_name = "prgrom.mem"
if len(sys.argv) > 2:
    f_out_name = sys.argv[2];
f_out = open(f_out_name, 'w+')

f_out.write("000\n"); #0th instruction is never executed
while True:
    c = f_in.read(1)
    if not c:
        break
    if c in bins:
        f_out.write(bins[c] + ' ')
    if c == '\n':
        f_out.write('\n')

f_in.close()
f_out.close()
