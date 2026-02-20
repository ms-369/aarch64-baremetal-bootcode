MEMORY
{
	RAM(rwx) : ORIGIN = 0x40000000, LENGTH = 128M
}

SECTIONS
{
	. = ORIGIN(RAM);
	
	.text : {
	    *(.text)
	} > RAM

	.data : {
            *(.data)
        } > RAM

	/* Alignment for 4KB  */
	. = ALIGN(4096)
	.bss : {
            *(.bss)
        } > RAM

	_stack_top = ORIGIN(RAM) + LENGTH(RAM);


}
