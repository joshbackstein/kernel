SRCDIR?=$(ROOTDIR)/src
BUILDDIR?=$(ROOTDIR)/build
SYSROOT?=$(BUILDDIR)/sysroot
ISOROOT?=$(BUILDDIR)/isoroot
ISODIR?=$(ROOTDIR)/iso

DEFAULT_HOST!=$(ROOTDIR)/scripts/default-host.sh
HOST?=$(DEFAULT_HOST)
HOSTARCH!=$(ROOTDIR)/scripts/target-triplet-to-arch.sh $(HOST)

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

CFLAGS?=-O2 -g
CPPFLAGS?=
LDFLAGS?=
LIBS?=

DESTDIR?=$(SYSROOT)
PREFIX?=/usr
EXEC_PREFIX?=$(PREFIX)
INCLUDEDIR?=$(PREFIX)/include

# Configure the cross-compiler to user the desired system root.
CC:=$(CC) --sysroot=$(SYSROOT)

# Workaround for when the -elf gcc targets don't have a system include
# directory because it was configured with --without-headers rather than
# --with-sysroot.
CC:=$(CC) -isystem=$(INCLUDEDIR)

# Use these compiler standards.
CSTD?=c11
