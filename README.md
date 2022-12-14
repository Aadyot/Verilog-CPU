to change the input instruction codes:
1) open cpu_test_bench.v
2) add a line "instruction = 19'bxxx    ;#20;  ",
replacing xxx with the 19 bit instruction code in the initial begin block

to run the code follow these steps:
1) Open command prompt/terminal
2) Navigate to directory containg the cpu.v and cpu_test_bench.v files.
3) Execute "iverilog .\cpu_test_bench.v .\cpu.v".
4) Execute "vvp .\a.out". The code has been run.
5) Execute "gtkwave .\cpu_test_bench.vcd" to see the waveform in gtkwave.