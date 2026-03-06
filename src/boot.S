.section .text.boot
.global _start

_start:
    /*------------------------------------------------------------
     * 0. SAFETY: Only let CPU 0 proceed. Park all other CPUs.
     *    MPIDR_EL1[7:0] holds the CPU number on the virt machine.
     *------------------------------------------------------------*/
    mrs x0, mpidr_el1
    and x0, x0, #0xFF
    cbnz x0, .park

    /*------------------------------------------------------------
     * 1. Set up the Vector Table for EL3
     *------------------------------------------------------------*/
    ldr x0, =vector_table_el3
    msr VBAR_EL3, x0
    isb

    /*------------------------------------------------------------
     * 2. Initialize General Purpose Register
     *------------------------------------------------------------*/
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
     * 3. Initialize FP/NEON registers
     *    Disable trapping first so FMOV doesn't fault.
     *------------------------------------------------------------*/
    msr CPTR_EL3, xzr
    isb
    fmov d0,  xzr
    fmov d1,  xzr
    fmov d2,  xzr
    fmov d3,  xzr
    fmov d4,  xzr
    fmov d5,  xzr
    fmov d6,  xzr
    fmov d7,  xzr
    fmov d8,  xzr
    fmov d9,  xzr
    fmov d10, xzr
    fmov d11, xzr
    fmov d12, xzr
    fmov d13, xzr
    fmov d14, xzr
    fmov d15, xzr
    fmov d16, xzr
    fmov d17, xzr
    fmov d18, xzr
    fmov d19, xzr
    fmov d20, xzr
    fmov d21, xzr
    fmov d22, xzr
    fmov d23, xzr
    fmov d24, xzr
    fmov d25, xzr
    fmov d26, xzr
    fmov d27, xzr
    fmov d28, xzr
    fmov d29, xzr
    fmov d30, xzr
    fmov d31, xzr

    /*------------------------------------------------------------
     * 4. Initialize Stack Pointer for EL3
     *    Stack grows DOWN from _stack_top.
     *------------------------------------------------------------*/
    ldr x0, =_stack_top
    mov sp, x0

    /*------------------------------------------------------------
     * 5. Set up MAIR_EL3 (Memory Attribute Indirection Register)
     *
     *    Attr0 = 0x00 -> Device-nGnRnE  (for UART and peripherals)
     *    Attr1 = 0xFF -> Normal, Inner/Outer Write-Back Cacheable
     *
     *    The value is built as:
     *    bits [7:0]   = Attr0 = 0x00
     *    bits [15:8]  = Attr1 = 0xFF
     *    all others   = 0x00
     *    => 0x000000000000FF00
     *------------------------------------------------------------*/
setup_mair:
    ldr x0, =0x000000000000FF00
    msr MAIR_EL3, x0
    isb

    /*------------------------------------------------------------
     * 6. Build the Translation Tables
     *
     *    Layout (with 4KB granule, 4GB space -> 2-level walk):
     *
     *    page_table_l1  (Level 1, 4KB, 4 entries x 8B = 32B used)
     *      Entry 0: -> page_table_l2      (0x00000000 - 0x3FFFFFFF, table)
     *      Entry 1: 1GB block 0x40000000  (Device, AttrIdx=0)
     *      Entry 2: 1GB block 0x80000000  (Device, AttrIdx=0)
     *      Entry 3: 1GB block 0xC0000000  (Device, AttrIdx=0)
     *
     *    page_table_l2  (Level 2, 4KB, 512 entries x 8B = 4KB)
     *      Entries 0..255:   2MB blocks starting at 0x00000000
     *                        (Normal cacheable, AttrIdx=1)
     *      Entry 72 (special): 0x09000000 area -> Device (UART)
     *                        (Device-nGnRnE, AttrIdx=0)
     *
     *    Block descriptor bits used:
     *      [0]    = 1      -> Valid
     *      [1]    = 0      -> Block (not table) for L1; 1=block for L2
     *      [11:8] = AttrIdx (index into MAIR)
     *      [9]    = 1      -> AF (Access Flag, avoids access flag fault)
     *      [7:6]  = 00     -> AP: EL3 R/W, no EL0 access
     *      [10]   = 1      -> Inner Shareable
     *      [1]    = 1      -> Block entry at L2 level
     *
     *    For a Level-2 BLOCK descriptor (2MB):
     *      AttrIdx=0 (Device):  bits[4:2]=000, AF=1 -> 0x00000000_00000405
     *                           + ISH[11:10]=10     -> 0x00000000_00000605 ... 
     *------------------------------------------------------------*/
setup_page_tables:
    /* Zero out both tables first for safety */
    ldr x0, =page_table_l1
    mov x1, #0
    mov x2, #512         /* 512 entries for l1 (overkill, safe) */
1:  str xzr, [x0], #8
    subs x2, x2, #1
    bne 1b

    ldr x0, =page_table_l2
    mov x2, #512
2:  str xzr, [x0], #8
    subs x2, x2, #1
    bne 2b

    /* --- Level 1 Table --- */
    ldr x0, =page_table_l1

    /* Entry 0: Table pointer -> page_table_l2
     *   Bits[1:0] = 0b11 = table descriptor
     */
    ldr x1, =page_table_l2
    orr x1, x1, #0x3           /* table descriptor */
    str x1, [x0, #0]            /* L1[0] covers 0x00000000-0x3FFFFFFF */

    /* Entry 1: 1GB block at 0x40000000, Device-nGnRnE (AttrIdx=0)
     *   [0]=1 block, [1]=0, AF[10]=1, SH[9:8]=10(outer), AP[7:6]=00, AttrIdx[4:2]=000
     *   0x40000000 | 0b01_0000_0100_0001 = 0x40000000 | 0x441
     *   Use 0x40000401: OA=0x40000000, AF=1, AttrIdx=0, valid block
     */
    ldr x1, =0x40000401
    str x1, [x0, #8]            /* L1[1] covers 0x40000000-0x7FFFFFFF */

    /* Entry 2: 1GB block at 0x80000000, Device-nGnRnE */
    ldr x1, =0x80000401
    str x1, [x0, #16]           /* L1[2] covers 0x80000000-0xBFFFFFFF */

    /* Entry 3: 1GB block at 0xC0000000, Device-nGnRnE */
    ldr x1, =0xC0000401
    str x1, [x0, #24]           /* L1[3] covers 0xC0000000-0xFFFFFFFF */

    /* --- Level 2 Table (covers 0x00000000 - 0x3FFFFFFF in 2MB blocks) --- */
    ldr x0, =page_table_l2

    /* Fill all 512 entries as Normal Cacheable (AttrIdx=1) first.
     * 2MB block descriptor: [0]=1, [1]=0 (block), AF[10]=1, SH[9:8]=10(outer-shareable)
     * AttrIdx[4:2]=001 (index 1 in MAIR = Normal cacheable)
     * Descriptor template for address 0x0:
     *   AttrIdx=1 -> bits[4:2]=0b001=0x4, AF=bit10=0x400, SH=bits[9:8]=0b10=0x200
     *   valid=0x1 => base = 0x605
     * Each 2MB block: output_address | 0x605
     * output_address for entry N = N * 0x200000
     */
    ldr x1, =0x00000605         /* template: address=0, AttrIdx=1, AF, ISH, block */
    ldr x5, =0x00200000         //*2MB step */
    mov x2, #512
    mov x3, x0
3:  str x1, [x3], #8
    add x1, x1, x5
    subs x2, x2, #1
    bne 3b

    /* Override entry 72 for 0x09000000 (UART) as Device-nGnRnE (AttrIdx=0)
     * Entry index = 0x09000000 / 0x200000 = 72
     * Device descriptor: address | 0x401  (AttrIdx=0, AF, valid block, no SH for device)
     */
    ldr x1, =0x09000401
    str x1, [x0, #72*8]

    /*------------------------------------------------------------
     * 7. Configure TCR_EL3 (Translation Control Register)
     *
     *    We want:
     *      T0SZ = 32  (bits[5:0])  -> 32-bit input address (4GB space)
     *      IRGN0 = 0b01 (bits[9:8]) -> Normal, Inner Write-Back cacheable
     *      ORGN0 = 0b01 (bits[11:10]) -> Normal, Outer Write-Back cacheable
     *      SH0   = 0b11 (bits[13:12]) -> Inner Shareable
     *      TG0   = 0b00 (bits[15:14]) -> 4KB granule
     *      PS    = 0b010 (bits[18:16]) -> 40-bit PA (matches virt machine)
     *
     *    0x20 | (0b01<<8) | (0b01<<10) | (0b11<<12) | (0b00<<14) | (0b010<<16)
     *    = 0x20 | 0x100 | 0x400 | 0x3000 | 0 | 0x20000
     *    = 0x23520
     *------------------------------------------------------------*/
setup_tcr:
    ldr x0, =0x23520
    msr TCR_EL3, x0
    isb

    /*------------------------------------------------------------
     * 8. Set TTBR0_EL3 to point to L1 page table
     *------------------------------------------------------------*/
    ldr x0, =page_table_l1
    msr TTBR0_EL3, x0
    isb

    /*------------------------------------------------------------
     * 9. Enable the MMU and Caches
     *
     *    - Set SMPEN bit in CPUECTLR first (required by spec)
     *    - Then set SCTLR_EL3: M(MMU), C(DCache), I(ICache)
     *    - DSB+ISB to ensure the enable takes effect before 
     *      any subsequent instructions are fetched/executed.
     *------------------------------------------------------------*/
enable_mmu:
    /* Flush TLBs before enabling MMU */
    tlbi alle3
    dsb sy
    isb

    /* Set SMPEN bit (bit 6) in CPUECTLR_EL1 (S3_1_C15_C2_1) */
    mrs x0, S3_1_C15_C2_1
    orr x0, x0, #(1 << 6)
    msr S3_1_C15_C2_1, x0
    isb

    // Enable MMU(M), D-Cache(C), I-Cache(I) in SCTLR_EL3
    mrs x0, SCTLR_EL3
    orr x0, x0, #(1 << 0)      /* M: enable MMU */
    orr x0, x0, #(1 << 2)      /* C: enable D-cache */
    orr x0, x0, #(1 << 12)     /* I: enable I-cache */
    msr SCTLR_EL3, x0
    dsb sy
    isb

    /*------------------------------------------------------------
     * 10. Jump to C code
     *------------------------------------------------------------*/
    bl main

    /* Should never return, but park here if it does. */
.park:
    wfe
    b .park


/*------------------------------------------------------------
 * Page tables placed in .bss (zeroed by the BSS section).
 * MUST be 4KB aligned (required by hardware).
 *------------------------------------------------------------*/
.section .bss
.align 12
.global page_table_l1
page_table_l1:
    .space 4096

.align 12
.global page_table_l2
page_table_l2:
    .space 4096
