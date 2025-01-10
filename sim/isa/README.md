# rv32 isa 指令测试设计文档

## const

### rv32_lui.txt

1<<12=4096

lui x3 1;

### rv32_auipc.txt

1<<12 + 4=4100

addi x1 x0 1;（没用）

auipc x3 4096;

## jump

### rv32_jal.txt

 rd=8 jump=44（2C） flush信号

addi x1 x0 1;（没用）

jal x3 20;

### rv32_jalr.txt

 rd=8 jump=20（14） flush信号

addi x1 x0 1;（最低位的1被消掉了）

jal x3 x1 20;

## br

### rv32_beq.txt

成立 jump=48（30） flush信号

addi x1 x0 3;

addi x2 x0 3;

beq x1 x2 20;

不成立  pc=14

addi x1 x0 1;

addi x2 x0 3;

beq x1 x2 20;

### rv32_bne.txt

成立 jump=48（30） flush信号

addi x1 x0 1;

addi x2 x0 3;

beq x1 x2 20;

不成立  pc=14

addi x1 x0 3;

addi x2 x0 3;

beq x1 x2 20;

## rv32_blt.txt

成立 jump=48（30） flush信号

addi x1 x0 全1;

addi x2 x0 1;

beq x1 x2 20;

不成立  pc=14

addi x1 x0 1;

addi x2 x0 全1;

beq x1 x2 20;

### rv32_bge.txt

成立 jump=48（30） flush信号

addi x1 x0 1;

addi x2 x0 全1;

beq x1 x2 20;

不成立  pc=14

addi x1 x0 全1;

addi x2 x0 1;

beq x1 x2 20;

### rv32_bltu.txt

成立 jump=48（30） flush信号

addi x1 x0 1;

addi x2 x0 全1;

beq x1 x2 20;

不成立  pc=14

addi x1 x0 全1;

addi x2 x0 1;

beq x1 x2 20;

### rv32_bgeu.txt

成立 jump=48（30） flush信号

addi x1 x0 全1;

addi x2 x0 1;

beq x1 x2 20;

不成立  pc=14

addi x1 x0 1;

addi x2 x0 全1;

beq x1 x2 20;

## load

### rv32_lb.txt

mem(4)=全1[7:0]   x3=全1

addi x1 x0 1;

addi x2 x0 全1;

sw x2 3(x1);

lb x3 x1 3

### rv32_lh.txt

mem(4)=全1[15:0]   x3=全1

addi x1 x0 1;

addi x2 x0 全1;

sw x2 3(x1);

lh x3 x1 3

### （已完成）rv32_lw.txt

4属于mem(1)   x3=全1

addi x1 x0 1;

addi x2 x0 全1;

sw x2 3(x1);

lw x3 3(x1);

### rv32_lbu.txt

mem(4)=全1[7:0]   x3=全1[7:0]

addi x1 x0 1;

addi x2 x0 全1;

sw x2 3(x1);

lbu x3 3(x1);

### rv32_lhu.txt

mem(4)=全1[7:0]   x3=全1[15:0]

addi x1 x0 1;

addi x2 x0 全1;

sw x2 3(x1);

lhu x3 3(x1)

## store

### rv32_sb.txt

mem(4)=全1[7:0]

addi x1 x0 1;

addi x2 x0 全1;

sb x2 3(x1);

### rv32_sh.txt

mem(4)=全1[15:0]

addi x1 x0 1;

addi x2 x0 全1;

sh x2 3(x1);

### （已完成）rv32_sw.txt

4属于mem（1）

mem(1)=全1

addi x1 x0 1;

addi x2 x0 全1;

sw x2 3(x1);

## op_i

### （已完成）rv32_addi.txt

1+3=4

1. addi x1 x0 1;
2. addi x3 x1 3;

### （已完成）rv32_slti.txt

全1<1=1

1. addi x1 x0 全1;
2. slti x3 x1 1;

### （已完成）rv32_sltiu.txt

全1<1=0

1. addi x1 x0 全1;

2. sltiu x3 x1 1;

### （已完成）rv32_xori.txt

b11^b01=b10

1. addi x1 x0 b11;

2. xori   x3 x1 b01;

### （已完成）rv32_ori.txt

b11^b01=b11

addi x1 x0 b11;

ori   x3 x1 b01;

### （已完成）rv32_andi.txt

b11^b01=b01

addi x1 x0 b11;

andi x3 x1 b01;

### （已完成）rv32_slli.txt

1<<2=4

addi x1 x0 1;

slli x3 x1 2;

### （已完成）rv32_srli.txt

全1>>1=01111……

addi x1 x0 全1;

srli x3 x1 1;

### （已完成）rv32_srai.txt

全1>>1=全1

addi x1 x0 全1;

srai   x3 x1 1;

## op

### （已完成）rv32_add.txt

1+3=4

addi x1 x0 1;

addi x2 x0 3;

add  x3 x1 x2;

### （已完成）rv32_sub.txt

4-1=3

addi x1 x0 4;

addi x2 x0 1;

sub  x3 x1 x2;

### （已完成）rv32_sll.txt

1<<2=4

addi x1 x0 1;

addi x2 x0 2;

sll     x3 x1 x2;

### （已完成）rv32_slt.txt

全1<1=1

addi x1 x0 全1;

addi x2 x0 1;

slt    x3 x1 x2;

### （已完成）rv32_sltu.txt

全1<1=0

addi x1 x0 全1;

addi x2 x0 1;

sltu   x3 x1 x2;

### （已完成）rv32_xor.txt

b11^b01=b10

addi x1 x0 b11;

addi x2 x0 b01;

sltu   x3 x1 x2;

### （已完成）rv32_srl.txt

全1>>1=01111……

addi x1 x0 全1;

addi x2 x0 1;

sltu   x3 x1 x2;

### （已完成）rv32_sra.txt

全1>>1=全1

addi x1 x0 全1;

addi x2 x0 1;

sltu   x3 x1 x2;

### （已完成）rv32_or.txt

b11^b01=b11

addi x1 x0 b11;

addi x2 x0 b01;

sltu   x3 x1 x2;

### （已完成）rv32_and.txt

b11^b01=b01

addi x1 x0 b11;

addi x2 x0 b01;

sltu   x3 x1 x2;

## mul

### （已完成）rv32_mul.txt

32'b1x32'b1-->-1x-1=1(00……01) 输出1

addi x1 x0 11111;

addi x2 x1 11111;

mul x3 x1 x2

### （已完成）rv32_mulh.txt

32'b1x32'b1-->-1x-1=1(00……01) 输出0

addi x1 x0 11111;

addi x2 x1 11111;

mulh x3 x1 x2

### （已完成）rv32_mulhsu.txt

32'b1x32'b1-->-1x(2^32-1)=(11111_00001) 输出11111_

addi x1 x0 11111;

addi x2 x1 11111;

mulhsu x3 x1 x2

### （已完成）rv32_mulhu.txt

32'b1x32'b1-->(2^32^-1)x(2^32^-1)=(11110_11111) 输出11110_

addi x1 x0 11111;

addi x2 x1 11111;

mulhu x3 x1 x2
