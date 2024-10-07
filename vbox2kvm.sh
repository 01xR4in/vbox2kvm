#!/bin/bash

# Looking for the commande "vboxmanage", used later in the script to dump the data
if ! command -v vboxmanage >/dev/null 2>&1; then
    echo "vboxmanage could not be found"
    exit 1
fi
# Looking for the commande "qemu-img", used later in the script to insert the data
if ! command -v qemu-img >/dev/null 2>&1; then
    echo "qemu-img could not be found"
    exit 1
fi

# Looking for number of arguments passed in the script
if [[ "$#" -ne 1 ]]; then
    echo "Wrong arguments passed to the script, check the documentation."
    exit 1
fi

# Checking if the argument (aka. virtualbox diskFile) exists
if [[ -f $1 ]]; then
    if [[ "$1" =~ \.vdi$ ]] || [[ "$1" =~ \.vmdk$ ]] || [[ "$1" =~ \.VHD$ ]] || [[ "$1" =~ \.HDD$ ]]; then
        baseDisk="$1"
        strippedPath="${baseDisk%.*}"
        echo "$strippedPath"
    else
        echo "File not ending in a format of a known virtualbox disk, exiting..."
        exit 1
    fi
else
    echo "File not found, does the script have the rights to run ?"
    exit 1
fi

# Creating variables to make the script clearer
tempDisk="$strippedPath".img
qcowDisk="$strippedPath".qcow2



echo "Exporting $baseDisk to $tempDisk as raw image file..."
vboxmanage clonehd "$baseDisk" "$tempDisk" -format raw 
echo "Done!"

echo "Converting $tempDisk into $qcowDisk"
qemu-img convert -f raw -O qcow2 "$tempDisk" "$qcowDisk"
echo "Done!"

echo "Removing $tempDisk..."
rm $tempDisk
echo "Done!"