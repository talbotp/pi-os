##############################################################################
# Makefile utility to build our Rubus Kernel.
#
# Author: P Talbot
# Reference: https://github.com/s-matyukevich
##############################################################################


# Cross compiler prefix.
ARMGNU ?= aarch64-linux-gnu

# -Wall -> Show all warnings.
# -nostdlib -> C std lib make system calls to OS, we dont't have.
# - nostartfiles -> used to set initial stack pointer, we do this.
# -ffreestanding -> std lib may not exist
# -mgeneral-regs-only -> Only use general purpose registers. Can get too complex.
COPS = -Wall -nostdlib -nostartfiles -ffreestanding -mgeneral-regs-only

# search for headers in include folder.
ASMOPS = -Iinclude

BUILD_DIR = build
SRC_DIR = src


# Default make.
all: kernel8.img

# Delete all binaries
clean :
    rm -rf $(BUILD_DIR) *.img 

# Build all c files.
$(BUILD_DIR)/%_c.o: $(SRC_DIR)/%.c
    mkdir -p $(@D)
    $(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

# Build all assembler files.
$(BUILD_DIR)/%_s.o: $(SRC_DIR)/%.S
    $(ARMGNU)-gcc $(ASMOPS) -MMD -c $< -o $@


# Build an array of all object files from both .c and .S origin.
C_FILES = $(wildcard $(SRC_DIR)/*.c)
ASM_FILES = $(wildcard $(SRC_DIR)/*.S)
OBJ_FILES = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(ASM_FILES:$(SRC_DIR)/%.S=$(BUILD_DIR)/%_s.o)

DEP_FILES = $(OBJ_FILES:%.o=%.d)
-include $(DEP_FILES)

kernel8.img: $(SRC_DIR)/linker.ld $(OBJ_FILES)
    $(ARMGNU)-ld -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/kernel8.elf  $(OBJ_FILES)
    $(ARMGNU)-objcopy $(BUILD_DIR)/kernel8.elf -O binary kernel8.img
