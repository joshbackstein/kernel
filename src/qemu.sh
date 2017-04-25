#!/bin/sh
set -e
source ./iso.sh

qemu-system-$(./target-triplet-to-arch.sh $HOST) -cdrom os.iso
