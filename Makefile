# Import any local testing overrides if they exist
-include locals.mk

# Import any global variables
include src/globals.mk

# Import debootstrap upstream settings
include src/base/ubuntu.mk

# Check running environment
include src/base/detect-environment.mk

# Helpers
bootstrap: $(BUILD)/debootstrap
chroot: $(BUILD)/chroot
live: $(BUILD)/live.packages
squashfs: $(BUILD)/iso_casper.stamp
iso_data: $(BUILD)/iso/md5sum.txt
iso: $(ISO)
img: $(IMG)
	
format-check:
	shfmt -l src scripts deps.sh

format:
	shfmt -l -w src scripts deps.sh

include src/debootstrap.mk
include src/chroot/filesystem.mk
include src/live/filesystem.mk
include src/iso/squashfs.mk
include src/iso/iso_data.mk
include src/qemu.mk
include src/clean.mk
