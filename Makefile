CC       = aarch64-linux-gnu-gcc
LD       = aarch64-linux-gnu-ld
OBJCOPY  = aarch64-linux-gnu-objcopy
OBJDUMP  = aarch64-linux-gnu-objdump

# -march=armv8-a: target ARMv8-A
# -ffreestanding: no hosted stdlib assumptions
# -nostdlib -nostartfiles: don't link standard startup files
# -O2: optimise (helps compiler not assume hosted environment)
CFLAGS   = -Wall -O2 -ffreestanding -nostdlib -nostartfiles -march=armv8-a

SRC_DIR   = src
BUILD_DIR = build
IMG_DIR   = img

OBJ_FILES = $(BUILD_DIR)/boot.o $(BUILD_DIR)/vector_table.o $(BUILD_DIR)/main.o

.PHONY: all clean run disasm directories

all: directories $(IMG_DIR)/kernel.img

directories:
	mkdir -p $(BUILD_DIR) $(IMG_DIR)

$(BUILD_DIR)/boot.o: $(SRC_DIR)/boot.S
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/vector_table.o: $(SRC_DIR)/vector_table.S
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/main.o: $(SRC_DIR)/main.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel.elf: $(OBJ_FILES) linker.ld
	$(LD) -T linker.ld $(OBJ_FILES) -o $@

$(IMG_DIR)/kernel.img: $(BUILD_DIR)/kernel.elf
	$(OBJCOPY) -O binary $< $@

# Handy disassembly target for debugging
disasm: $(BUILD_DIR)/kernel.elf
	$(OBJDUMP) -D $< | less

clean:
	rm -rf $(BUILD_DIR) $(IMG_DIR)

# QEMU launch notes:
#   -M virt,secure=on  : 'virt' board with Security Extensions (needed for EL3)
#   -cpu cortex-a53    : ARMv8-A core
#   -device loader...  : load raw binary at our exact link address
#   -nographic         : redirect UART to stdout (PL011 at 0x09000000)
#   No -dtb flag:      : let QEMU generate the DTB at 0x40000000 (below our image)
run: $(IMG_DIR)/kernel.img
	qemu-system-aarch64 \
	  -M virt,secure=on \
	  -cpu cortex-a53 \
	  -device loader,file=$(IMG_DIR)/kernel.img,addr=0x40100000,cpu-num=0 \
	  -nographic
