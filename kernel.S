.syntax unified         
.cpu cortex-m4          
.thumb                  

#define a #5             
#define b #4             
#define c #3             

.global vtable_kernel   
.global __kernel_reset__

.type vtable_kernel, %object     // Позначити vtable_kernel як обєкт (дані)
.type __kernel_reset__, %function // Позначити __kernel_reset__ як функцію

.section .interrupt_vector       // Секція з векторною таблицею переривань
vtable_kernel:                   
    .word __stack_start          // Початкове значення стеку (stack pointer)
    .word __kernel_reset__+1     // Адреса Reset Handler (+1 — для переходу в Thumb режим)
    .size vtable_kernel, .-vtable_kernel // Обчислює розмір обєкта vtable_kernel

.section .rodata                 // Секція для констант (тільки читання)
    data:  .asciz "kernel started!\n"      // Строка повідомлення про старт ядра
    final: .asciz "Value in register #3: "// Префікс для виводу результату

.section .text                   // Секція з кодом (текстова)
__kernel_reset__:
    ldr r0, =data                // Завантажити адресу строки "kernel started!\n" у r0
    bl dbgput_line               // Вивести строку на консоль

    // Обчислення виразу (a - b) * 3 + 2^c
    mov r3, a                   // r3 := a (5)
    mov r1, b                   // r1 := b (4)
    mov r2, c                   // r2 := c (3)

    // r3 = a - b
    sub r3, r1                 // r3 := r3 - r1 = 5 - 4 = 1

    // r3 = (a - b) * 3
    mov r1, #3                 // r1 := 3
    mul r3, r1                 // r3 := r3 * r1 = 1 * 3 = 3

    // r4 = 2^c, реалізуємо як побітовий зсув вліво
    mov r4, #2                 // r4 := 2 (початкове значення для піднесення в степінь)
pow:
    cmp r2, #1                 // якщо c == 1, переходимо до сумування
    beq sum
    lsl r4, r4, #1             // r4 <<= 1 (помножити на 2, екв. зсув вліво)
    sub r2, #1                 // зменшити лічильник степеня
    bne pow                    // якщо ще не нуль, повторити цикл

sum:
    // r3 = (a - b)*3 + 2^c
    add r3, r4                 // r3 := r3 + r4, фінальний результат

    ldr r0, =final             // Завантажити адресу строки "Value in register #3: "
    bl dbgput                  // Вивести її без переносу рядка

    mov r0, r3                 // Перенести результат у r0
    bl dbgput_num              // Вивести значення r3 як число

end:
    b end                 
