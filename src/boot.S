.section .text
.global _start

_start:
    /*------------------------------------------------------------
    1. Initializing Exceptions
    ------------------------------------------------------------ */
    ldr x0, =_vector_table_el3
    mov sp, x0

   /*------------------------------------------------------------
    2. Initializing Stack Pointer for EL3
    ------------------------------------------------------------ */
    ldr x0, =_stack_top
    mov sp, x0

 /* ------------------------------------------------------------
    2. Initializing General Purpose  Registers
    ------------------------------------------------------------ */
    mov x0,  xzr
    mov x1,  xzr
    mov x2,  xzr
    mov x3,  xzr
    mov x4,  xzr
    mov x5,  xzr
    mov x6,  xzr
    mov x7,  xzr
    mov x8,  xzr
    mov x9,  xzr
    mov x10, xzr
    mov x11, xzr
    mov x12, xzr
    mov x13, xzr
    mov x14, xzr
    mov x15, xzr
    mov x16, xzr
    mov x17, xzr
    mov x18, xzr
    mov x19, xzr
    mov x20, xzr
    mov x21, xzr
    mov x22, xzr
    mov x23, xzr
    mov x24, xzr
    mov x25, xzr
    mov x26, xzr
    mov x27, xzr
    mov x28, xzr
    mov x29, xzr
    mov x30, xzr

   /*------------------------------------------------------------
    4. Jump to main
    ------------------------------------------------------------ */
    bl main
1:  b 1b
