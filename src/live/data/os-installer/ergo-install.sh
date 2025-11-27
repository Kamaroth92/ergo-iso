#!/usr/bin/env bash

set -e

# Arg defaults
PROVISIONER_EXPORTS=/ergo/provisioner/files/node_exports.sh
if [ -f $PROVISIONER_EXPORTS ]; then
	source $PROVISIONER_EXPORTS
fi

CURR_HOSTNAME=$(hostname)
LARGEST_DISK=$(lsblk -b -d -o NAME,SIZE | sort -k2 -n | tail -n1 | awk '{print $1}')

HOSTNAME="${VAR_name:-$CURR_HOSTNAME}"
DISK="${VAR_disk:-$LARGEST_DISK}"
FACTORY_RESET=false
# -----

# Config
OS_PART_LABEL="ERGO_OS"
DATA_PART_LABEL="ERGO_DATA"
DATA_PART_SIZE=10GiB
DATA_PART_MOUNT="/ergo-data"

MOUNTPOINT="/mnt"
SQUASHFS_PATH="/cdrom/casper/filesystem.squashfs"
# CMDLINE_PARAMS="console=tty1 console=ttyS4,115200n8 systemd.wants=serial-getty@ttyS4"

BOOTLOADERID="Ergo"
GUID=$(cat /proc/sys/kernel/random/uuid)
# -----

PARSED=$(getopt -o h:d:f --long hostname:,disk:,factory -n "$0" -- "$@")
if [[ $? -ne 0 ]]; then
	echo "Failed to parse arguments." >&2
	exit 1
fi

eval set -- "$PARSED"

FACTORY_RESET="false"

while true; do
	case "$1" in
	-h | --hostname)
		HOSTNAME="$2"
		shift 2
		;;
	-d | --disk)
		DISK="$2"
		shift 2
		;;
	-f | --factory)
		FACTORY_RESET="true"
		shift
		;;
	--)
		shift
		break
		;;
	*)
		echo "Unknown option: $1" >&2
		exit 1
		;;
	esac
done

echo "Hostname: $HOSTNAME"
echo "Disk: $DISK"
echo "Factory reset: $FACTORY_RESET"

read -p "Do you want to continue? [y/N]: " confirm
confirm=${confirm,,}

if [[ "$confirm" != "y" && "$confirm" != "yes" ]]; then
	echo "Aborted by user."
	exit 1
fi

check_for_default_drive() {
	if $(lsblk | grep -q "^$DISK"); then
		echo "Disk $DISK found"
	else
		echo "Unable to find disk '$DISK'. Use --disk to specify a target disk to wipe"
		exit 1
	fi
}

check_data_partition() {
	# echo "Checking to see if data partition already exists"
	data_partition=$(lsblk --list -o name,label | grep "$DATA_PART_LABEL" | awk '{print $1}')
	if [ ! -z $data_partition ]; then
		echo $data_partition
	fi
}

quick_wipe_disk() {
	disk=$1
	echo "Quick formatting /dev/$disk"
	vgchange -an
	wipefs -af /dev/$disk
	dd if=/dev/zero of=/dev/$disk bs=1M count=100
}

disk_name_seperator() {
	input=$1
	if [[ $input == nvme0* ]]; then
		echo "p"
	else
		echo ""
	fi
}

initialize_for_new_install() {
	disk=$1
	echo "Creating partitions on /dev/$disk"
	parted /dev/$disk -s mklabel gpt
	parted /dev/$disk -s mkpart ESP fat32 1MiB 512MiB # EFI partition (512MB)
	parted /dev/$disk -s set 1 boot on
	mkfs.fat -F32 "/dev/${disk}$(disk_name_seperator $disk)1"
}

format_data_partition() {
	disk=$1
	parted /dev/$disk -s mkpart primary ext4 512MiB $DATA_PART_SIZE
	mkfs.ext4 -F "/dev/${disk}$(disk_name_seperator $disk)2" -L $DATA_PART_LABEL
}

format_partition() {
	disk=$1
	label=$2
	parted /dev/$disk -s mkpart primary ext4 512MiB $DATA_PART_SIZE
	mkfs.ext4 -F "/dev/${disk}$(disk_name_seperator $disk)2" -L $DATA_PART_LABEL
}

wipe_os_partition() {
	os_partition=$(lsblk --list -o name,label | grep "$OS_PART_LABEL" | awk '{print $1}')
	echo $os_partition
}

format_os_partition() {
	disk=$1
	action=$2
	if [ "$action" == "init" ]; then
		parted /dev/$disk -s mkpart primary ext4 $DATA_PART_SIZE 100%
	fi
	mkfs.ext4 -F "/dev/${disk}$(disk_name_seperator $disk)3" -L $OS_PART_LABEL
}

mount_os_filesystem() {
	disk=$1
	mountpoint=$2
	mount "/dev/${disk}$(disk_name_seperator $disk)3" $mountpoint
	mkdir -p $mountpoint/boot/efi
	mount "/dev/${disk}$(disk_name_seperator $disk)1" $mountpoint/boot/efi
}

unmount_os_filesystem() {
	mountpoint=$1
	if $(mount | grep -q "$mountpoint"); then
		echo "Unmounting '$mountpoint'"
		umount -R $mountpoint
	else
		echo "Mountpoint '$mountpoint' not mounted"
	fi
}

copy_live_filesystem() {
	disk=$1
	mountpoint=$2
	squashfs_path=$3
	echo "Copying live filesystem from $squashfs_path to $mountpoint"
	mount_os_filesystem $disk $mountpoint

	unsquashfs -f -d $mountpoint $squashfs_path
}

chroot_bind() {
	mountpoint=$1
	mount --bind /dev $mountpoint/dev
	mount --bind /proc $mountpoint/proc
	mount --bind /sys $mountpoint/sys
}

chroot_configure() {
	disk=$1
	mountpoint=$2
	hostname=$3

	rm $2/etc/resolv.conf
	cp /etc/resolv.conf $2/etc/resolv.conf

	chroot $2 /bin/bash <<EOF
  mount -t efivarfs none /sys/firmware/efi/efivars
  
  echo 'UUID=$(blkid -s UUID -o value /dev/${disk}$(disk_name_seperator $disk)3) / ext4 defaults 0 1' > /etc/fstab
  echo 'UUID=$(blkid -s UUID -o value /dev/${disk}$(disk_name_seperator $disk)1) /boot/efi vfat defaults 0 1' >> /etc/fstab
  echo 'UUID=$(blkid -s UUID -o value /dev/${disk}$(disk_name_seperator $disk)2) $DATA_PART_MOUNT ext4 defaults 0 2' >> /etc/fstab

  echo "$hostname" > /etc/hostname

  apt update
  apt install -y grub-efi-amd64
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=$BOOTLOADERID

  rm /etc/update-motd.d/20-install-instructions || true

  update-grub
EOF
}

set_next_boot() {
	partuuid=$(blkid | awk '/PARTLABEL="ESP"/ {print $NF}' | cut -d'=' -f2 | tr -d '"')
	targetboot=$(efibootmgr | grep "$partuuid" | awk '{print $1}')
	efibootmgr --bootnum "${targetboot:4:4}" -L "$BOOTLOADERID"
	efibootmgr --bootnext "${targetboot:4:4}" >/dev/null && echo "BootNext set to '$BOOTLOADERID' (Boot${targetboot:4:4})"
}

unmount_os_filesystem $MOUNTPOINT
check_for_default_drive
data_partition=$(check_data_partition)
if [ -z "$data_partition" ] || [ "$FACTORY_RESET" == "true" ]; then
	# REINITIALIZE DISK
	if [ "$FACTORY_RESET" == "true" ]; then
		echo "FACTORY_RESET param set to 'true'"
	else
		echo "Cannot find the $DATA_PART_LABEL partition"
	fi
	quick_wipe_disk $DISK
	initialize_for_new_install $DISK
	format_data_partition $DISK init
	format_os_partition $DISK init
else
	# DO UPDATE PROCESS HERE
	echo "Updating!"
	format_os_partition $DISK
fi

# Mount the filesystem
copy_live_filesystem $DISK $MOUNTPOINT $SQUASHFS_PATH
chroot_bind $MOUNTPOINT

chroot_configure $DISK $MOUNTPOINT $HOSTNAME

# unmount_os_filesystem $MOUNTPOINT
set_next_boot

echo "[✔] Installation Done! Reboot when ready."
