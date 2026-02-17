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

	.bss : {
            *(.bss)
        } > RAM

	_stack_top = ORIGIN(RAM) + LENGTH(RAM);


}
