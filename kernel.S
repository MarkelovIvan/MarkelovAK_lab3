.syntax unified         
.cpu cortex-m4          
.thumb                  

#define a #5             
#define b #4             
#define c #3             

.global vtable_kernel   
.global __kernel_reset__

.type vtable_kernel, %object     // ��������� vtable_kernel �� ���� (����)
.type __kernel_reset__, %function // ��������� __kernel_reset__ �� �������

.section .interrupt_vector       // ������ � ��������� �������� ����������
vtable_kernel:                   
    .word __stack_start          // ��������� �������� ����� (stack pointer)
    .word __kernel_reset__+1     // ������ Reset Handler (+1 � ��� �������� � Thumb �����)
    .size vtable_kernel, .-vtable_kernel // �������� ����� ����� vtable_kernel

.section .rodata                 // ������ ��� �������� (����� �������)
    data:  .asciz "kernel started!\n"      // ������ ����������� ��� ����� ����
    final: .asciz "Value in register #3: "// ������� ��� ������ ����������

.section .text                   // ������ � ����� (��������)
__kernel_reset__:
    ldr r0, =data                // ����������� ������ ������ "kernel started!\n" � r0
    bl dbgput_line               // ������� ������ �� �������

    // ���������� ������ (a - b) * 3 + 2^c
    mov r3, a                   // r3 := a (5)
    mov r1, b                   // r1 := b (4)
    mov r2, c                   // r2 := c (3)

    // r3 = a - b
    sub r3, r1                 // r3 := r3 - r1 = 5 - 4 = 1

    // r3 = (a - b) * 3
    mov r1, #3                 // r1 := 3
    mul r3, r1                 // r3 := r3 * r1 = 1 * 3 = 3

    // r4 = 2^c, �������� �� �������� ���� ����
    mov r4, #2                 // r4 := 2 (��������� �������� ��� ��������� � ������)
pow:
    cmp r2, #1                 // ���� c == 1, ���������� �� ���������
    beq sum
    lsl r4, r4, #1             // r4 <<= 1 (��������� �� 2, ���. ���� ����)
    sub r2, #1                 // �������� �������� �������
    bne pow                    // ���� �� �� ����, ��������� ����

sum:
    // r3 = (a - b)*3 + 2^c
    add r3, r4                 // r3 := r3 + r4, ��������� ���������

    ldr r0, =final             // ����������� ������ ������ "Value in register #3: "
    bl dbgput                  // ������� �� ��� �������� �����

    mov r0, r3                 // ��������� ��������� � r0
    bl dbgput_num              // ������� �������� r3 �� �����

end:
    b end                 
