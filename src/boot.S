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

   /*------------------------------------------------------------
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
    4. Defining Memory Attribute Indirection Register
    ------------------------------------------------------------ */
steup_mair:
      /*------------------------------------------------------------
       Attribute/ Slot 0: 0x00 =  Device-nGnRnE(no-gather, no-reorder, no-early-ack
       Attribute/ Slot 1: 0xFF =  Normal memory, inner/outer write-back non-transient
       ------------------------------------------------------------ */ 
	mov x0, #0xFF00
	msr MAIR_EL3, x0
	isb

   /*------------------------------------------------------------
    5. Creating cache map
	1. Get the address of our reserved table space
	2. Prepare the Descriptor value
	3. Store the descriptor in the first slot of the table
    ------------------------------------------------------------ */
	/* Setting up level 1 table  */
	ldr x0, =page_table_l1
	ldr x1, =page_table_l2

	orr x2, x1, #0x3
	
	str x2, [x0, #0]
	str x2, [x0, #8]

	/* Rule for UART at slot 72  */
	ldr x2, =0x9000401
	/* Store in L2 at Index 72  */
	str x2, [x2, #72 * 8]

	/* RAM at slot 512  */
        ldr x2, =0x40000705
        /* Store in L2 at Index 0 */
        str x2, [x1, #0]


setup_tcr:
	mov x0, #0x19
	orr x0, x0, #(0x3 << 8)
	orr x0, x0 #(0x3 << 12)
	msr TCR_EL3, x0
	isb

enable_mmu:
	/* Point to page_table_l2  */
	ldr x0, =page_table_l1
	msr TTBR0_EL3, x0
	isb
	
	mrs x0, SCTLR_EL3
	orr x0, x0, #0x1
	orr x0, x0, #0x4
	orr x0, x0, #0x1000
	msr SCTLR_EL3, x0
	isb

   /*------------------------------------------------------------
    x. Jump to main
    ------------------------------------------------------------ */
    bl main
1:  b 1b

/* Safety Loop  */
hang:
	wfe
	b hang

.section .bss
.align 12
page_table_l2:
	.space 4096
page_table_l2:
	.space 4096

