.section .text
.balign 0x800

.global vector_table_el3
vector_table_el3:
	/* The exception vector table for each EL is divided
	   into 4 sections. Each section incorporating 4 types 
	   of exception entries. Each entry is of 128 bytes, which
	   are 32 instructions.  */

	/* Current EL with SP0  */
        /* Synchronous  */
        .balign 0x80
         b .
	/* IRQ  */
        .balign 0x80
         b .
	/* FIQ  */
        .balign 0x80
         b .
	/* SError  */
	.balign 0x80
	 b .
	
	/* Current EL with SPx  */
        /* Synchronous  */
        .balign 0x80
         b .
        /* IRQ  */
        .balign 0x80
         b .
        /* FIQ  */
        .balign 0x80
         b .
        /* SError  */
        .balign 0x80
         b .

	/* Lower EL using AArch64  */
        /* Synchronous  */
        .balign 0x80
         b .
        /* IRQ  */
        .balign 0x80
         b .
        /* FIQ  */
        .balign 0x80
         b .
        /* SError  */
        .balign 0x80
         b .

        /* Lower EL using AArch32  */
        /* Synchronous  */
        .balign 0x80
         b .
        /* IRQ  */
        .balign 0x80
         b .
        /* FIQ  */
        .balign 0x80
         b .
        /* SError  */
        .balign 0x80
         b .
