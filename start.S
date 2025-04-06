.syntax unified         
.cpu cortex-m4           
.thumb                  

.global vtable           // Вектор переривань
.global __hard_reset__   // Обробник скидання (Reset Handler)

/*
 * Векторна таблиця — перші адреси, які процесор читає після скидання.
 */
.type vtable, %object         // Оголошення vtable як обєкта (дані)
.type __hard_reset__, %function // Оголошення __hard_reset__ як функції

.section .interrupt_vector    // Секція з вектором переривань
vtable:
    .word __stack_start       // Початкова адреса стеку
    .word __hard_reset__+1    // Адреса Reset Handler (+1 для Thumb режиму)
    .size vtable, .-vtable    // Обчислення розміру вектора (кількість байт)

.section .text                // Секція коду (інструкцій)
__hard_reset__:
    
    .data                     // Перехід у секцію даних
    d: .asciz "starting \n"   // C-рядок для виводу: "starting" з новим рядком

    .text                     // Повернення у секцію коду
    ldr r0, =d                // Завантажити адресу рядка d у регістр r0
    bl dbgput_line            // Вивести рядок на консоль (функція друку)

    bl bootload               // Виклик функції завантажувача ядра (bootloader)

    _loop: b _loop       

    .size __hard_reset__, .-__hard_reset__  // Обчислення розміру функції __hard_reset__
