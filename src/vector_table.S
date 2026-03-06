.section .text
.balign 0x800

.global vector_table_el3
vector_table_el3:
    /* The exception vector table for EL3.
       Each of the 4 groups has 4 exception types.
       Each entry is 0x80 (128) bytes = up to 32 instructions.  */

    /* --- Group 1: Current EL with SP0 --- */
    /* Synchronous */
    .balign 0x80
    b .
    /* IRQ */
    .balign 0x80
    b .
    /* FIQ */
    .balign 0x80
    b .
    /* SError */
    .balign 0x80
    b .

    /* --- Group 2: Current EL with SPx --- */
    /* Synchronous */
    .balign 0x80
    b .
    /* IRQ */
    .balign 0x80
    b .
    /* FIQ */
    .balign 0x80
    b .
    /* SError */
    .balign 0x80
    b .

    /* --- Group 3: Lower EL using AArch64 --- */
    /* Synchronous */
    .balign 0x80
    b .
    /* IRQ */
    .balign 0x80
    b .
    /* FIQ */
    .balign 0x80
    b .
    /* SError */
    .balign 0x80
    b .

    /* --- Group 4: Lower EL using AArch32 --- */
    /* Synchronous */
    .balign 0x80
    b .
    /* IRQ */
    .balign 0x80
    b .
    /* FIQ */
    .balign 0x80
    b .
    /* SError */
    .balign 0x80
    b .
