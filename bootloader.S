.syntax unified
.cpu cortex-m4     
.thumb            

.global bootload        

.section .rodata        
image:           .incbin "kernel.bin"         // вміст бінарного файлу kernel.bin
end_of_image:                                     // Мітка для позначення кінця образу ядра
str_boot_start:  .asciz "bootloader started"     
str_boot_end:    .asciz "bootload ended"         
str_boot_indicate: .asciz "#"                  

.section .text            
bootload:                 // Мітка початку функції завантажувача

    // вивести "bootloader started"
    ldr r0, =str_boot_start     // Завантажити адресу строки "bootloader started" у r0
    bl dbgput_line              

    // Загрузити адреса кінця та початку образу ядра
    ldr r1, =end_of_image    
    ldr r3, =image              // r3 вказує на початок бінарного образу (нижня межа)
    ldr r2, =_ram_start         // r2 — адреса початку області RAM, куди потрібно копіювати ядро
    ldr r4, =12                 // Розмір блоку копіювання — 12 байт (3 регістри по 4 байти)

    // Зміщуємо r2 до кінця області призначення (оскільки LDM/STM не працюють у зворотному напрямку)
    add r2, r2, r1              // r2 = _ram_start + (end_of_image - image)
    sub r2, r2, r3              // Обрахунок точного кінцевого адреса копіювання в RAM

copy_loop:                      // Мітка початку циклу копіювання
    sub r1, r1, r4              
    sub r2, r2, r4              

    ldm r1, {r5, r6, r7}        // Завантажуємо з Flash 12 байт (три слова) у r5, r6, r7
    stm r2, {r5, r6, r7}        // Записуємо ці 12 байт у RAM

    cmp r1, r3                  // Порівнюємо чи дійшли до початку образу
    bhi copy_loop               // Якщо r1 > r3 (ще не дійшли), повторити цикл

    bl newline                  

    // вивести "bootload ended"
    ldr r0, =str_boot_end       // Завантажуємо адресу строки "bootload ended"
    bl dbgput_line              // Виводимо її на консоль

    // Переход до виконання ядра
    ldr r2, =_ram_start         // Завантажуємо адресу початку образу ядра в RAM
    ldr r0, [r2, #4]            // Читаємо адресу Reset_Handler з вектора (друге слово)
    bx r0                       // Безумовний перехід до цієї адреси (виконання ядра). Якщо в Thumb, адреса має бути з виставленим бітом 0.
bootload_end:                  
    b bootload_end
