`timescale 1ns / 1ns

module cpu_testbench;
    reg [18:0] instruction;
    wire [7:0] result;

    CPU my_CPU(.opcode(instruction), .result(result));

    initial begin
        $dumpfile ("cpu_test_bench.vcd");
        $dumpvars (0, cpu_testbench);


        //instruction = 19'b1010000111111001100; #20; 

        instruction = 19'b0010000000011111111    ;#20;  //0, FF
        instruction = 19'b0100000000011111111    ;#20;
        instruction = 19'b0110000000011111111    ;#20;
        instruction = 19'b1000000000011111111    ;#20;
        instruction = 19'b1010000000011111111    ;#20;
        instruction = 19'b1100000000011111111    ;#20;
        instruction = 19'b1110000000011111111    ;#20;

        instruction = 19'b0010010001100010100    ;#20;     //35, 20
        instruction = 19'b0100010001100010100    ;#20;
        instruction = 19'b0110010001100010100    ;#20;
        instruction = 19'b1000010001100010100    ;#20;
        instruction = 19'b1010010001100010100    ;#20;
        instruction = 19'b1100010001100010100    ;#20;
        instruction = 19'b1110010001100010100    ;#20;

        $display ("Testing Completed");

        $finish;

    end;
endmodule