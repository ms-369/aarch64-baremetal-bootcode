/* --- UART Hardware Addresses (Mapped as Device-nGnRnE in MMU) --- */
#define UART0_BASE 0x09000000
#define UART0_DR   ((volatile unsigned int*)(UART0_BASE + 0x00)) /* Data Register */
#define UART0_FR   ((volatile unsigned int*)(UART0_BASE + 0x18)) /* Flag Register */

/* --- UART Functions --- */

/**
 * Sends a single character to the UART.
 * Because we mapped this as "Device" memory, the CPU will not cache 
 * these reads/writes, ensuring the hardware sees them immediately.
 */
void uart_putc(char c) {
    /* Wait until the Transmit FIFO is not full (Bit 5 of Flag Register) */
    while (*UART0_FR & (0x20)); 
    *UART0_DR = c;
}

/**
 * Sends a null-terminated string to the UART.
 */
void uart_puts(const char *s) {
    while (*s) {
        uart_putc(*s++);
    }
}

/**
 * Helper to print hex values (useful for debugging MMU addresses)
 */
void uart_puthex(unsigned long n) {
    const char *hexdigits = "0123456789ABCDEF";
    for (int i = 60; i >= 0; i -= 4) {
        uart_putc(hexdigits[(n >> i) & 0xF]);
    }
}

/* --- The Main Entry Point --- */

void main() {
    uart_puts("\r\n--- AArch64 Bare Metal Boot ---\r\n");
    uart_puts("MMU Status: ENABLED\r\n");
    uart_puts("Region 0x09000000: Mapped as Device (UART)\r\n");
    uart_puts("Region 0x40000000: Mapped as Normal Cacheable (RAM)\r\n");
    
    uart_puts("\r\nTesting Cache Speed...\r\n");
    
    for (volatile int i = 0; i < 1000000; i++);

    uart_puts("Execution Finished. System alive.\r\n");

    while (1) {
        asm volatile("wfi");
    }
}
