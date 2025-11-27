#!/bin/bash
set -e

# Find the device containing a partition labeled VENTOY or VTOYEFI
usb_info=$(lsblk -fli -o NAME,LABEL,FSTYPE | grep -i ventoy)
if [[ -z "$usb_info" ]]; then
    echo "No Ventoy USB found."
    exit 1
fi

# Extract device and partition
# Assuming the EFI partition is vfat or fat16/fat32 and labeled VTOYEFI
efi_partition=$(lsblk -fli | grep -i 'VTOYEFI' | awk '{print $1}')
if [[ -z "$efi_partition" ]]; then
    echo "EFI partition (VTOYEFI) not found on Ventoy USB."
    exit 1
fi

# Get the full device path and partition number
efi_dev="/dev/$efi_partition"
usb_dev="/dev/$(echo $efi_partition | sed 's/[0-9]*$//')"
part_num=$(echo $efi_partition | grep -o '[0-9]\+$')

echo "Found Ventoy EFI partition: $efi_dev on device $usb_dev (partition $part_num)"

# Mount the EFI partition temporarily to check for BOOTX64.EFI
mount_point=$(mktemp -d)
sudo mount "$efi_dev" "$mount_point"

if [[ ! -f "$mount_point/EFI/BOOT/BOOTX64.EFI" ]]; then
    echo "BOOTX64.EFI not found in $efi_dev!"
    sudo umount "$mount_point"
    rmdir "$mount_point"
    exit 1
fi

echo "BOOTX64.EFI found. Creating efibootmgr entry..."

# Create the efibootmgr entry
sudo efibootmgr -c -d "$usb_dev" -p "$part_num" -L "Ventoy USB" -l '\EFI\BOOT\BOOTX64.EFI'

# Get the boot number of the newly created entry
bootnum=$(efibootmgr | grep "Ventoy USB" | awk '{print $1}' | sed 's/Boot//;s/\*//')

echo "Setting Ventoy USB as next boot device (Boot$bootnum)..."
sudo efibootmgr -n "$bootnum"

# Cleanup
sudo umount "$mount_point"
rmdir "$mount_point"

echo "Done. Ventoy USB should boot on next reboot."
