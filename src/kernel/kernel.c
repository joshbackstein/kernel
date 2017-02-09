#if !defined(__cplusplus)
/* C doesn't have booleans by default.
 */
#include <stdbool.h>
#endif
#include <stddef.h>
#include <stdint.h>

/* Check if the compiler thinks we are targeting the wrong operating system.
 */
#if defined(__linux__)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif

/* This tutorial will only work for the 32-bit ix86 targets.
 */
#if !defined(__i386__)
#error "this tutorial needs to be compiled with an ix86-elf compiler"
#endif

/* Hardware text mode color constants.
 */
enum vga_color {
	COLOR_BLACK = 0,
	COLOR_BLUE = 1,
	COLOR_GREEN = 2,
	COLOR_CYAN = 3,
	COLOR_RED = 4,
	COLOR_MAGENTA = 5,
	COLOR_BROWN = 6,
	COLOR_LIGHT_GREY = 7,
	COLOR_DARK_GREY = 8,
	COLOR_LIGHT_BLUE = 9,
	COLOR_LIGHT_GREEN = 10,
	COLOR_LIGHT_CYAN = 11,
	COLOR_LIGHT_RED = 12,
	COLOR_LIGHT_MAGENTA = 13,
	COLOR_LIGHT_BROWN = 14,
	COLOR_WHITE = 15,
};

/* Create a VGA color attribute
 *
 * Param fg: The foreground color
 * Type fg: vga_color
 *
 * Param bg: The background color
 * Type bg: vga_color
 *
 * Returns: the color attribute
 * RType: uint8_t
 *
 * Explanation:
 * 	Type vga_color is 4 bits. Because we are returning
 * 	an 8-bit value, we will shift the background color
 * 	4 bits to the left, then perform a bitwise OR on the
 * 	two values to combine them into 1 8-bit value.
 * Example:
 * 	4-bit fg = b0100
 * 	4-bit bg = b1011
 * 	8-bit fg = b00000100
 * 	8-bit bg = b00001011
 * 	8-bit bg << 4 = b10110000
 * 	8-bit fg | 8-bit bg << 4 = b10110100
 */
uint8_t make_color(enum vga_color fg, enum vga_color bg) {
	return fg | bg << 4;
}

uint16_t make_vgaentry(char c, uint8_t color) {
	uint16_t c16 = c;
	uint16_t color16 = color;
	return c16 | color16 << 8;
}

size_t strlen(const char* str) {
	size_t ret = 0;
	while ( str[ret] != 0 ) {
		ret++;
	}
	return ret;
}

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer;

void terminal_initialize() {
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = make_color(COLOR_LIGHT_GREY, COLOR_BLACK);
	terminal_buffer = (uint16_t*) 0xB8000;
	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = make_vgaentry(' ', terminal_color);
		}
	}
}

void terminal_setcolor(uint8_t color) {
	terminal_color = color;
}

void terminal_putentryat(char c, uint8_t color, size_t x, size_t y) {
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = make_vgaentry(c, color);
}

void terminal_scroll() {
	for (size_t y = 0; y < VGA_HEIGHT - 1; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = terminal_buffer[index + VGA_WIDTH];
		}
	}
	for (size_t x = 0; x < VGA_WIDTH; x++) {
		const size_t index = (VGA_HEIGHT - 1) * VGA_WIDTH + x;
		terminal_buffer[index] = make_vgaentry(' ', terminal_color);
	}
	terminal_row = VGA_HEIGHT - 1;
}

void terminal_putchar(char c) {
	/* Check for newline character. Only output an actual character if it is not
	 * a newline.
	 */
	if (c == '\n') {
		terminal_column = 0;
		if (++terminal_row == VGA_HEIGHT) {
			terminal_scroll();
		}
	} else {
		terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
		if (++terminal_column == VGA_WIDTH) {
			terminal_column = 0;
			if (++terminal_row == VGA_HEIGHT) {
				terminal_scroll();
			}
		}
	}
}

void terminal_writestring(const char* data) {
	size_t datalen = strlen(data);
	for (size_t i = 0; i < datalen; i++) {
		terminal_putchar(data[i]);
	}
}

#if defined(__cplusplus)
/* Use C linkage for kernel_main.
 */
extern "C"
#endif
void kernel_main() {
	/* Initialize terminal interface
	 */
	terminal_initialize();

	/* Since there is no support for newlines in terminal_putchar
	 * yet, '\n' will produce some VGA specific character instead.
	 * This is normal.
	 */
	//terminal_writestring("Hello, Kernel World!\nSecond line");
	terminal_writestring("1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n21\n22\n23\n24\n25\n26\n27\nabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz");
}
