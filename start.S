.syntax unified         
.cpu cortex-m4           
.thumb                  

.global vtable           // ������ ����������
.global __hard_reset__   // �������� �������� (Reset Handler)

/*
 * �������� ������� � ����� ������, �� �������� ���� ���� ��������.
 */
.type vtable, %object         // ���������� vtable �� ����� (����)
.type __hard_reset__, %function // ���������� __hard_reset__ �� �������

.section .interrupt_vector    // ������ � �������� ����������
vtable:
    .word __stack_start       // ��������� ������ �����
    .word __hard_reset__+1    // ������ Reset Handler (+1 ��� Thumb ������)
    .size vtable, .-vtable    // ���������� ������ ������� (������� ����)

.section .text                // ������ ���� (����������)
__hard_reset__:
    
    .data                     // ������� � ������ �����
    d: .asciz "starting \n"   // C-����� ��� ������: "starting" � ����� ������

    .text                     // ���������� � ������ ����
    ldr r0, =d                // ����������� ������ ����� d � ������ r0
    bl dbgput_line            // ������� ����� �� ������� (������� �����)

    bl bootload               // ������ ������� ������������� ���� (bootloader)

    _loop: b _loop       

    .size __hard_reset__, .-__hard_reset__  // ���������� ������ ������� __hard_reset__
