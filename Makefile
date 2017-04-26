ROOTDIR!=pwd
SRCDIR?=$(ROOTDIR)/src
BUILDDIR?=$(ROOTDIR)/build
SYSROOT?=$(BUILDDIR)/sysroot
ISOROOT?=$(BUILDDIR)/isoroot
ISODIR?=$(ROOTDIR)/iso

DEFAULT_HOST!=scripts/default-host.sh
HOST?=$(DEFAULT_HOST)
HOSTARCH!=scripts/target-triplet-to-arch.sh $(HOST)

# Make sure we're using the right archive manager, assembler, and compilers.
ifeq ($(origin AR), default)
AR=$(HOST)-ar
endif
ifeq ($(origin AS), default)
AS=$(HOST)-as
endif
ifeq ($(origin CC), default)
CC=$(HOST)-gcc
endif
ifeq ($(origin CXX), default)
CXX=$(HOST)-g++
endif

# Configure the cross-compiler to use the desired system root.
CC:=$(CC) --sysroot=$(SYSROOT)

CFLAGS?=-O2 -g
CPPFLAGS?=
LDFLAGS?=
LIBS?=

DESTDIR?=$(SYSROOT)
PREFIX?=/usr
EXEC_PREFIX?=$(PREFIX)
BOOTDIR?=/boot
LIBDIR?=$(EXEC_PREFIX)/lib
INCLUDEDIR?=$(PREFIX)/include

# Workaround for when the -elf gcc targets don't have a system include
# directory because it was configured with --without-headers rather than
# --with-sysroot.
CC:=$(CC) -isystem=$(INCLUDEDIR)

# Export all variables.
export

.PHONY: all clean run image headers libc kernel

all: image

run: image
	qemu-system-$(HOSTARCH) -cdrom $(ISODIR)/os.iso

image: libc kernel
	echo $@
	mkdir -p $(ISOROOT)
	mkdir -p $(ISOROOT)/boot
	mkdir -p $(ISOROOT)/boot/grub
	cp $(SYSROOT)/boot/os.kernel $(ISOROOT)/boot/os.kernel
	echo -e "set timeout=1" > "$(ISOROOT)/boot/grub/grub.cfg"
	echo -e "menuentry \"JoshOS\" {" >> "$(ISOROOT)/boot/grub/grub.cfg"
	echo -e "  multiboot /boot/os.kernel" >> "$(ISOROOT)/boot/grub/grub.cfg"
	echo -e "}" >> "$(ISOROOT)/boot/grub/grub.cfg"
	mkdir -p $(ISODIR)
	grub-mkrescue -o $(ISODIR)/os.iso $(ISOROOT)

headers:
	mkdir -p $(SYSROOT)
	make -C $(SRCDIR)/libc -f $(SRCDIR)/libc/Makefile install-headers
	make -C $(SRCDIR)/kernel -f $(SRCDIR)/kernel/Makefile install-headers

libc: headers
	make -C $(SRCDIR)/libc -f $(SRCDIR)/libc/Makefile install-libs

kernel: headers libc
	make -C $(SRCDIR)/kernel -f $(SRCDIR)/kernel/Makefile install-kernel

clean:
	make -C $(SRCDIR)/libc -f $(SRCDIR)/libc/Makefile clean
	make -C $(SRCDIR)/kernel -f $(SRCDIR)/kernel/Makefile clean
	rm -rf $(BUILDDIR)
	rm -rf $(ISODIR)
