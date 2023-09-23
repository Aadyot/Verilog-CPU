module CPU (
    input wire[18:0] opcode,
    output wire[7:0] result 
);
    wire [2:0] operation;
    wire [7:0] operand1;
    wire [7:0] operand2;

    CU myCU (opcode, operation, operand1, operand2);    

    //instead of sending decoded output to the ALU, i have used a multiplexer inside the ALU
    ALU myALU (operation, operand1, operand2, result);

endmodule

module CU( 
    input wire[18:0] opcode,
    output wire [2:0] operation,
    output wire [7:0] operand1,
    output wire [7:0] operand2
);
    //breaks the opcode into 3 parts: operation, operand1, operand2
    assign operation = opcode[18:16];
    assign operand1 = opcode[15:8];
    assign operand2 = opcode[7:0];
endmodule


module ALU (
    input wire[2:0] operation,
    input wire[7:0] op1,
    input wire[7:0] op2,
    output wire[7:0] result

);
    wire[7:0] answers[0:7]; //7 * (8bit buses) for the 7 processes + 0'th bus is empty
    
    wire zero;
    assign zero = 1'b0;    

    //performing all 8 operations
    assign answers[0] = 8'b0;
    _8_bit_adder       ALU_add(op1, op2, zero, answers[1]);
    _8_bit_subtractor  ALU_subtr(op1, op2, answers[2]);
    _8_bit_incre       ALU_incre(op1, answers[3]);
    _8_bit_decre       ALU_decre(op1, answers[4]);
    _8_bit_and         ALU_and(op1, op2, answers[5]);
    _8_bit_or          ALU_or(op1, op2, answers[6]);
    _8_bit_not         ALU_not(op1, answers[7]);


    //selecting 1 operation as result using a multiplexer
    _8_input_bus_multiplexer ALU_multiplexer (operation, answers[0],answers[1],answers[2],answers[3],
                                            answers[4],answers[5],answers[6],answers[7], result);


endmodule

//multiplexer modules
module _8_input_bus_multiplexer(
    input wire[0:2] select,
    input wire[7:0] in0, in1, in2, in3, in4, in5, in6, in7,
    output wire[7:0] out
);

    wire[7:0] mid[0:1];

    //implementing an 8 bit multiplexer using 2 (4 bit) multiplexers and 1 (2 bit) multiplexer
    _4_input_bus_multiplexer m1(select[1:2], in0, in1, in2, in3, mid[0]);
    _4_input_bus_multiplexer m2(select[1:2], in4, in5, in6, in7, mid[1]);

    _2_input_bus_multiplexer m3(select[0], mid[0], mid[1], out);

endmodule

module _4_input_bus_multiplexer(
    input wire[0:1] select, 
    input wire[7:0] in0, in1, in2, in3, 
    output wire[7:0] out
);
    wire[7:0] mid[0:1];

    //implementing an 4 bit multiplexer using 3 (2 bit) multiplexers
    _2_input_bus_multiplexer m1 (select[1], in0, in1, mid[0]);
    _2_input_bus_multiplexer m2 (select[1], in2, in3, mid[1]);

    _2_input_bus_multiplexer m3 (select[0], mid[0], mid[1], out);
endmodule

module _2_input_bus_multiplexer(
    input wire select, 
    input wire[7:0] in0, in1,  
    output wire[7:0] out
);
    wire notselect;
    not select_not(notselect, select);

    wire[7:0] s1, nots2;

    and and1 [7:0] (s1, select, in1);
    and and2 [7:0] (nots2, notselect, in0);

    or or1 [7:0] (out, s1, nots2);
endmodule

//ALU operation modules

module _8_bit_adder(
    input wire[7:0] op1, 
    input wire[7:0] op2, 
    input wire cin,
    output wire[7:0] sum
);
    wire [8:0] carrys;
    assign carrys[0] = cin;
    //ripple carry addition
    full_adder _8_adders [7:0] (op1, op2, carrys[7:0], sum, carrys[8:1]);

endmodule

module _8_bit_subtractor(
    input wire[7:0] op1, 
    input wire[7:0] op2, 
    output wire[7:0] diff
);
    //subtraction using 2's complement
    wire[7:0] op2_comp;    //complement of op2
    _8_bit_not subtr_not(op2, op2_comp);   

    wire one;
    assign one = 1'b1;
    _8_bit_adder subtract_by_adding(op1, op2_comp, one, diff);   
    //adding op1, complement of op2, 1 using adder module
endmodule


module _8_bit_incre(
    input wire[7:0] op, 
    output wire[7:0] ans
);
    wire [8:0] carrys;
    assign carrys[0] =1'b1;   
    //we can treat incrementing as adding 1 to a number.
    //but it can also be thought of as adding 0 to a number with a carry to the LSB
    //at every step, we need to add only 2 bits: the number and the previous carry. 
    //hence full adders arent required.
    half_adder incrementer[7:0] (.sum(ans), .carry(carrys[8:1]), .in1(op), .in2(carrys[7:0]));

endmodule

module _8_bit_decre(
    input wire[7:0] op, 
    output wire[7:0] ans
);
    wire [8:0] borrows;
    assign borrows[0]= 1'b1;

    //in the same way incrementer is implemented using half adders, 
    //a decrementer can be made using half subtractors
    half_subtractor decrementer[7:0] (.diff(ans), .borrow(borrows[8:1]) , .in1(op), .in2(borrows[7:0]));
endmodule

module _8_bit_and(
    input wire[7:0] op1, 
    input wire[7:0] op2, 
    output wire[7:0] ans
);
    and _8_and[7:0] (ans, op1, op2);
endmodule

module _8_bit_or(
    input wire[7:0] op1, 
    input wire[7:0] op2, 
    output wire[7:0] ans
);
    or _8_or[7:0] (ans, op1, op2);
endmodule


module _8_bit_not(
    input wire[7:0] op1, 
    output wire[7:0] ans
);
    not _8_not[7:0] (ans, op1);
endmodule

//modules with single bits as inputs
module full_adder(
    input wire in1, 
    input wire in2, 
    input wire cin, 
    output wire sum, 
    output wire cout
);
    wire mid_sum , mid_carry1, mid_carry2;

    //a full adder using 2 half adders
    half_adder ha1(in1, in2,     mid_sum, mid_carry1);
    half_adder ha2(cin, mid_sum, sum,     mid_carry2);

    or carry_or(cout, mid_carry1, mid_carry2);
endmodule


module half_adder(
    input wire in1, 
    input wire in2, 
    output wire sum, 
    output wire carry
);
    xor half_adder_xor(sum, in1, in2);
    and half_adder_and(carry, in1, in2);
endmodule

module half_subtractor(
    input wire in1, 
    input wire in2, 
    output wire diff, 
    output wire borrow
);
    xor half_subtr_xor(diff, in1, in2);
    wire not_in1;
    not(in1_not, in1);
    and borrow_and(borrow, in1_not, in2);
endmodule