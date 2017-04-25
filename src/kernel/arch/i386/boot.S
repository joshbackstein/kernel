# Declare constants for the multiboot header.
# Align loaded modules on page boundaries.
.set ALIGN, 1<<0
# Provide memory map.
.set MEMINFO, 1<<1
# This is the Multiboot 'flag' field.
.set FLAGS, ALIGN | MEMINFO
# 'Magic number' lets bootloader find the header.
.set MAGIC, 0x1BADB002
# Checksum of above to prove we are multiboot.
.set CHECKSUM, -(MAGIC + FLAGS)

# Declare a header as in the Multiboot Standard.
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# Reserve a stack for the initial thread. Currently, the stack pointer register
# (esp) points at anything and using it may cause massive harm. Insteadl, we'll
# provide our own stack. We will allocate room for a small temporary stack by
# creating a symbol at the bottom of it, then allocating 16384 bytes for it,
# and finally creating a symbol at the top.
.section .bss
.align 16
stack_bottom:
# 16 KiB
.skip 16384
stack_top:

# The kernel entry point.
.section .text
.global _start
.type _start, @function
_start:
	movl $stack_top, %esp

	# Call the global constructors.
	call _init

	# Transfer control to the kernel.
	call kernel_main

	# Hang if kernel_main unexpectedly returns. To do that, we use the clear
	# interrupt ('cli') instruction to disable interrupts, the halt instruction
	# ('hlt') to stop the CPU until the next interrupt arrives, and jumping to
	# the halt instruction if it ever continues, just to be safe. We will create
	# a local label rather than a real symbol and jump to there endlessly.
	cli
.Lhang:
	hlt
	jmp .Lhang

# Set the size of the _start symbol to the current location '.' minus its start.
# This is useful when debugging or when you implement call tracing.
.size _start, . - _start
