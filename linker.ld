MEMORY
{
	RAM(rwx) : ORIGIN = 0x40100000, LENGTH = 127M
}

SECTIONS
{
	. = 0x40100000;
	
	.text : {
	    *(.text.boot)
	    *(.text)
	} > RAM

	.data : {
            *(.data)
        } > RAM

	/* Alignment for 4KB  */
	. = ALIGN(4096);
	.bss : {
            *(.bss)
        } > RAM

	_stack_top = ORIGIN(RAM) + LENGTH(RAM);


}
