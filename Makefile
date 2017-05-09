ROOTDIR!=pwd
include ./make/common.mk

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
