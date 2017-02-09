# Set variables.
# Do not add trailing slashes to directories.
BOOTSTRAPDIR="./src/bootstrap"
BOOTSTRAPFILEIN="bootstrap.s"
BOOTSTRAPFILEOUT="bootstrap.o"
KERNELDIR="./src/kernel"
KERNELFILEIN="kernel.c"
KERNELFILEOUT="kernel.o"
COMPILEOUTDIR="./out"
LINKOUTDIR="./bin"
LINKERSCRIPTDIR="./src/linkerscript"
LINKERSCRIPTFILE="linker.ld"
LINKOUTFILE="os.bin"
IMAGEOUTDIR="./image"
IMAGEBOOTFILE="osboot.bin"
IMAGEBOOTMENUTIMEOUT="1"
IMAGEBOOTMENUENTRYNAME="JoshOS"
IMAGEOUTFILE="osimage.iso"

# Colors
COLORBLACK="\e[0;30m"
COLORBLUE="\e[0;34m"
COLORGREEN="\e[0;32m"
COLORCYAN="\e[0;36m"
COLORRED="\e[0;31m"
COLORPURPLE="\e[0;35m"
COLORBROWN="\e[0;33m"
COLORGREY="\e[1;30m"
COLORLTGREY="\e[0;37m"
COLORLTBLUE="\e[1;34m"
COLORLTGREEN="\e[1;32m"
COLORLTCYAN="\e[1;36m"
COLORLTRED="\e[1;31m"
COLORLTPURPLE="\e[1;35m"
COLORYELLOW="\e[1;33m"
COLORWHITE="\e[1;37m"
COLOREND="\e[0m"

# If an argument was passed, we will use it for IMAGEOUTFILE
if [ ! "$1" = "" ] ; then
	IMAGEOUTFILE="$1"
fi

# Clean up and remove unneeded files and folders after everything is finished
CLEANUP=1

# Exit on errors
set -e


# Make sure bootstrap and kernel directories exist.
# Create them if they don't.
echo ""
echo -e "${COLORBLUE}Checking for source files${COLOREND}"
echo "Searching for directory \"$BOOTSTRAPDIR\""
if [ -d "$BOOTSTRAPDIR" ] ; then
	# Directory exists.
	echo -e "${COLORGREEN}OK:${COLOREND} Found directory \"$BOOTSTRAPDIR\""

	# Search for bootstrap source file.
	echo "Searching for file \"$BOOTSTRAPDIR/$BOOTSTRAPFILEIN\""
	if [ -f "$BOOTSTRAPDIR/$BOOTSTRAPFILEIN" ] ; then
		echo -e "${COLORGREEN}OK:${COLOREND} Found file \"$BOOTSTRAPDIR/$BOOTSTRAPFILEIN\""
	else
		echo -e "${COLORRED}ERROR:${COLOREND} Could not find file \"$BOOTSTRAPDIR/$BOOTSTRAPFILEIN\""
		exit 1
	fi
elif [ -e "$BOOTSTRAPDIR" ] ; then
	# Exists, but not as a directory.
	echo -e "${COLORRED}ERROR:${COLOREND} \"$BOOTSTRAPDIR\" already exists, but it is not a directory!"
	exit 1
else
	# Directory does not exist.
	echo -e "${COLORRED}ERROR:${COLOREND} \"$BOOTSTRAPDIR\" does not exist!"
	echo "Please create directory \"$BOOTSTRAPDIR\" and file \"$BOOTSTRAPFILEIN\""
	exit 1
fi
echo "Searching for directory \"$KERNELDIR\""
if [ -d "$KERNELDIR" ] ; then
	# Directory exists.
	echo -e "${COLORGREEN}OK:${COLOREND} Found directory \"$KERNELDIR\""

	# Search for kernel source file.
	echo "Searching for file \"$KERNELDIR/$KERNELFILEIN\""
	if [ -f "$KERNELDIR/$KERNELFILEIN" ] ; then
		echo -e "${COLORGREEN}OK:${COLOREND} Found file \"$KERNELDIR/$KERNELFILEIN\""
	else
		echo -e "${COLORRED}ERROR:${COLOREND} Could not find file \"$KERNELDIR/$KERNELFILEIN\""
		exit 1
	fi
elif [ -e "$KERNELDIR" ] ; then
	# Exists, but not as a directory.
	echo -e "${COLORRED}ERROR:${COLOREND} \"$KERNELDIR\" already exists, but it is not a directory!"
	exit 1
else
	# Does not exist. Try to create it.
	echo -e "${COLORRED}ERROR:${COLOREND} \"$KERNELDIR\" does not exist."
	echo "Please create directory \"$KERNELDIR\" and file \"$KERNELFILEIN\""
	exit 1
fi


# Clean compile output directory.
echo ""
echo ""
echo -e "${COLORBLUE}Cleaning compile output directory${COLOREND}"
echo "Searching for directory \"$COMPILEOUTDIR\""
if [ -d "$COMPILEOUTDIR" ] ; then
	# Directory exists.
	echo -e "${COLORGREEN}OK:${COLOREND} Found directory \"$COMPILEOUTDIR\""
	echo "Emptying directory \"$COMPILEOUTDIR\""
	rm -rf "$COMPILEOUTDIR"/*
	echo -e "${COLORGREEN}OK:${COLOREND} Emptied directory \"$COMPILEOUTDIR\""
elif [ -e "$COMPILEOUTDIR" ] ; then
	# Exists, but not as a directory.
	echo -e "${COLORRED}ERROR:${COLOREND} \"$COMPILEOUTDIR\" already exists, but it is not a directory!"
	exit 1
else
	# Does not exist. Try to create it.
	echo "Directory \"$COMPILEOUTDIR\" does not exist."
	echo "Creating directory \"$COMPILEOUTDIR\""
	mkdir -p "$COMPILEOUTDIR"
	echo -e "${COLORGREEN}OK:${COLOREND} Created directory \"$COMPILEOUTDIR\""
fi


# Assemble bootstrap.
echo ""
echo ""
echo -e "${COLORBLUE}Assembling bootstrap${COLOREND}"
i686-elf-as "$BOOTSTRAPDIR/$BOOTSTRAPFILEIN" -o "$COMPILEOUTDIR/$BOOTSTRAPFILEOUT"
echo -e "${COLORGREEN}OK:${COLOREND} Assembled \"$BOOTSTRAPDIR/$BOOTSTRAPFILEIN\" to \"$COMPILEOUTDIR/$BOOTSTRAPFILEOUT\""


# Compile kernel.
echo ""
echo ""
echo -e "${COLORBLUE}Compiling kernel${COLOREND}"
i686-elf-gcc -c "$KERNELDIR/$KERNELFILEIN" -o "$COMPILEOUTDIR/$KERNELFILEOUT" -std=gnu99 -ffreestanding -O2 -Wall -Wextra
echo -e "${COLORGREEN}OK:${COLOREND} Compiled \"$KERNELDIR/$KERNELFILEIN\" to \"$COMPILEOUTDIR/$KERNELFILEOUT\""


# Clean link output directory.
echo ""
echo ""
echo -e "${COLORBLUE}Cleaning link output directory${COLOREND}"
echo "Searching for directory \"$LINKOUTDIR\""
if [ -d "$LINKOUTDIR" ] ; then
	# Directory exists.
	echo -e "${COLORGREEN}OK:${COLOREND} Found directory \"$LINKOUTDIR\""
	echo "Emptying directory \"$LINKOUTDIR\""
	rm -rf "$LINKOUTDIR"/*
	echo -e "${COLORGREEN}OK:${COLOREND} Emptied directory \"$LINKOUTDIR\""
elif [ -e "$LINKOUTDIR" ] ; then
	# Exists, but not as a directory.
	echo -e "${COLORRED}ERROR:${COLOREND} \"$LINKOUTDIR\" already exists, but it is not a directory!"
	exit 1
else
	# Does not exist. Try to create it.
	echo "Directory \"$LINKOUTDIR\" does not exist."
	echo "Creating directory \"$LINKOUTDIR\""
	mkdir -p "$LINKOUTDIR"
	echo -e "${COLORGREEN}OK:${COLOREND} Created directory \"$LINKOUTDIR\""
fi


# Link kernel
echo ""
echo ""
echo -e "${COLORBLUE}Linking kernel${COLOREND}"
i686-elf-gcc -T "$LINKERSCRIPTDIR/$LINKERSCRIPTFILE" -o "$LINKOUTDIR/$LINKOUTFILE" -ffreestanding -O2 -nostdlib "$COMPILEOUTDIR/$BOOTSTRAPFILEOUT" "$COMPILEOUTDIR/$KERNELFILEOUT" -lgcc
echo -e "${COLORGREEN}OK:${COLOREND} Kernel linked as output file \"$LINKOUTDIR/$LINKOUTFILE\""


# Clean image output directory
echo ""
echo ""
echo -e "${COLORBLUE}Cleaning image output directory${COLOREND}"
echo "Searching for directory \"$IMAGEOUTDIR\""
if [ -d "$IMAGEOUTDIR" ] ; then
	# Directory exists.
	echo -e "${COLORGREEN}OK:${COLOREND} Found directory \"$IMAGEOUTDIR\""
	echo "Emptying directory \"$IMAGEOUTDIR\""
	rm -rf "$IMAGEOUTDIR"/*
	echo -e "${COLORGREEN}OK:${COLOREND} Emptied directory \"$IMAGEOUTDIR\""
elif [ -e "$IMAGEOUTDIR" ] ; then
	# Exists, but not as a directory
	echo -e "${COLORRED}ERROR:${COLOREND} \"$IMAGEOUTDIR\" already exists, but it is not a directory!"
	exit 1
else
	# Does not exist. Try to create it.
	echo "Directory \"$IMAGEOUTDIR\" does not exist."
	echo "Creating directory \"$IMAGEOUTDIR\""
	mkdir -p "$IMAGEOUTDIR"
	echo -e "${COLORGREEN}OK:${COLOREND} Created directory \"$IMAGEOUTDIR\""
fi


# Build image
echo ""
echo ""
echo -e "${COLORBLUE}Building image${COLOREND}"
echo "Creating directory \"$IMAGEOUTDIR/conf\""
mkdir -p "$IMAGEOUTDIR/conf"
echo -e "${COLORGREEN}OK:${COLOREND} Created directory \"$IMAGEOUTDIR/conf\""
echo "Touching file \"$IMAGEOUTDIR/conf/grub.cfg\""
touch "$IMAGEOUTDIR/conf/grub.cfg"
echo -e "${COLORGREEN}OK:${COLOREND} Touched file \"$IMAGEOUTDIR/conf/grub.cfg\""
echo "Configuring file \"$IMAGEOUTDIR/conf/grub.cfg\""
echo -e "set timeout=$IMAGEBOOTMENUTIMEOUT" >> "$IMAGEOUTDIR/conf/grub.cfg"
echo -e "menuentry \"$IMAGEBOOTMENUENTRYNAME\" {" >> "$IMAGEOUTDIR/conf/grub.cfg"
echo -e "\tmultiboot /boot/$IMAGEBOOTFILE" >> "$IMAGEOUTDIR/conf/grub.cfg"
echo -e "}" >> "$IMAGEOUTDIR/conf/grub.cfg"
echo -e "${COLORGREEN}OK:${COLOREND} Configured file \"$IMAGEOUTDIR/conf/grub.cfg\""
echo "Creating ISO directory structure in \"$IMAGEOUTDIR/isoroot\""
mkdir -p "$IMAGEOUTDIR/isoroot/boot/grub"
echo -e "${COLORGREEN}OK:${COLOREND} Created ISO directory structure in \"$IMAGEOUTDIR/isoroot\""
echo "Copying \"$LINKOUTDIR/$LINKOUTFILE\" to \"$IMAGEOUTDIR/isoroot/boot/$IMAGEBOOTFILE\""
cp "$LINKOUTDIR/$LINKOUTFILE" "$IMAGEOUTDIR/isoroot/boot/$IMAGEBOOTFILE"
echo -e "${COLORGREEN}OK:${COLOREND} Copied \"$LINKOUTDIR/$LINKOUTFILE\" to \"$IMAGEOUTDIR/isoroot/boot/$IMAGEBOOTFILE\""
echo "Copying \"$IMAGEOUTDIR/conf/grub.cfg\" to \"$IMAGEOUTDIR/isoroot/boot/grub/grub.cfg\""
cp "$IMAGEOUTDIR/conf/grub.cfg" "$IMAGEOUTDIR/isoroot/boot/grub/grub.cfg"
echo -e "${COLORGREEN}OK:${COLOREND} Copied \"$IMAGEOUTDIR/conf/grub.cfg\" to \"$IMAGEOUTDIR/isoroot/boot/grub/grub.cfg\""
echo "Building ISO as \"$IMAGEOUTDIR/$IMAGEOUTFILE\""
grub2-mkrescue -o "$IMAGEOUTDIR/$IMAGEOUTFILE" "$IMAGEOUTDIR/isoroot"
echo -e "${COLORGREEN}OK:${COLOREND} Image saved as \"$IMAGEOUTDIR/$IMAGEOUTFILE\""


# Check if we want to clean up and remove any unneeded files and folders
# If $CLEANUP is NOT equal to 0...
if [ ! $CLEANUP = 0 ] ; then
	# Remove unneeded files and folders
	echo ""
	echo ""
	echo -e "${COLORBLUE}Removing unneeded files and folders${COLOREND}"
	echo "Removing directory \"$COMPILEOUTDIR\""
	rm -rf "$COMPILEOUTDIR"
	echo -e "${COLORGREEN}OK:${COLOREND} Removed directory \"$COMPILEOUTDIR\""
	echo "Removing directory \"$LINKOUTDIR\""
	rm -rf "$LINKOUTDIR"
	echo -e "${COLORGREEN}OK:${COLOREND} Removed directory \"$LINKOUTDIR\""
	echo "Removing directory \"$IMAGEOUTDIR/conf\""
	rm -rf "$IMAGEOUTDIR/conf"
	echo -e "${COLORGREEN}OK:${COLOREND} Removed directory \"$IMAGEOUTDIR/conf\""
	echo "Removing directory \"$IMAGEOUTDIR/isoroot\""
	rm -rf "$IMAGEOUTDIR/isoroot"
	echo -e "${COLORGREEN}OK:${COLOREND} Removed directory \"$IMAGEOUTDIR/isoroot\""
fi


# Add some extra white space to the end
echo ""
echo ""
