file="${1}"
if [ "${file}" = "" ] ; then
	# No file was provided.
	echo "This script requires you to provide the path for the file you wish to use!"
	echo "Example:"
	echo -e "\t./run.sh \"/path/to/my.iso\""
else
	# File was provided.
	qemu-system-i386 -cdrom "${file}"
fi
