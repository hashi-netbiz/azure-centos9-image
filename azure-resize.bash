#!/usr/bin/env bash

# This script resizes a drive to what Azure requires.
#
# reference: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-generic#resizing-vhds

rawdisk="$1"

MB=$(( 1024*1024 ))
size=$( qemu-img info -f raw --output json "$rawdisk" | gawk 'match($0, /"virtual-size": ([0-9]+),/, val) {print val[1]}' )

rounded_size=$(( ( ( $size + $MB - 1 ) / $MB ) * $MB ))

cat << EOF

	Rounded Size = $rounded_size

	Resize it with:

		qemu-img resize $rawdisk $rounded_size

	Convert it with:

		qemu-img convert -f raw -o subformat=fixed,force_size -O vpc $rawdisk my_os.vhd

EOF

