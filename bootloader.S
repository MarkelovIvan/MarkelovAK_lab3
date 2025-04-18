.syntax unified
.cpu cortex-m4     
.thumb            

.global bootload        

.section .rodata        
image:           .incbin "kernel.bin"         // ���� �������� ����� kernel.bin
end_of_image:                                     // ̳��� ��� ���������� ���� ������ ����
str_boot_start:  .asciz "bootloader started"     
str_boot_end:    .asciz "bootload ended"         
str_boot_indicate: .asciz "#"                  

.section .text            
bootload:                 // ̳��� ������� ������� �������������

    // ������� "bootloader started"
    ldr r0, =str_boot_start     // ����������� ������ ������ "bootloader started" � r0
    bl dbgput_line              

    // ��������� ������ ���� �� ������� ������ ����
    ldr r1, =end_of_image    
    ldr r3, =image              // r3 ����� �� ������� �������� ������ (����� ����)
    ldr r2, =_ram_start         // r2 � ������ ������� ������ RAM, ���� ������� �������� ����
    ldr r4, =12                 // ����� ����� ��������� � 12 ���� (3 ������� �� 4 �����)

    // ������ r2 �� ���� ������ ����������� (������� LDM/STM �� �������� � ���������� ��������)
    add r2, r2, r1              // r2 = _ram_start + (end_of_image - image)
    sub r2, r2, r3              // ��������� ������� �������� ������ ��������� � RAM

copy_loop:                      // ̳��� ������� ����� ���������
    sub r1, r1, r4              
    sub r2, r2, r4              

    ldm r1, {r5, r6, r7}        // ����������� � Flash 12 ���� (��� �����) � r5, r6, r7
    stm r2, {r5, r6, r7}        // �������� �� 12 ���� � RAM

    cmp r1, r3                  // ��������� �� ����� �� ������� ������
    bhi copy_loop               // ���� r1 > r3 (�� �� �����), ��������� ����

    bl newline                  

    // ������� "bootload ended"
    ldr r0, =str_boot_end       // ����������� ������ ������ "bootload ended"
    bl dbgput_line              // �������� �� �� �������

    // ������� �� ��������� ����
    ldr r2, =_ram_start         // ����������� ������ ������� ������ ���� � RAM
    ldr r0, [r2, #4]            // ������ ������ Reset_Handler � ������� (����� �����)
    bx r0                       // ���������� ������� �� ���� ������ (��������� ����). ���� � Thumb, ������ �� ���� � ����������� ���� 0.
bootload_end:                  
    b bootload_end
