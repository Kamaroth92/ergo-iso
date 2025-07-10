clean-live: clean-squashfs
	scripts/unmount.sh "$(BUILD)/live"
	$(SUDO) rm -rf $(BUILD)/live
	$(SUDO) rm -rf $(BUILD)/live.packages

clean-chroot: clean-live
	scripts/unmount.sh "$(BUILD)/chroot"
	$(SUDO) rm -rf $(BUILD)/chroot
	$(SUDO) rm -rf $(BUILD)/chroot.packages

clean-squashfs: clean-iso
	$(SUDO) rm -rf $(BUILD)/iso
	$(SUDO) rm -rf $(BUILD)/iso_dir.stamp
	$(SUDO) rm -rf $(BUILD)/iso_casper.stamp
	$(SUDO) rm -rf $(BUILD)/iso_squashfs.stamp

clean-iso:
	$(SUDO) rm -rf $(BUILD)/grub
	$(SUDO) rm -rf $(BUILD)/grub.partial
	$(SUDO) rm -rf $(BUILD)/iso/efi
	$(SUDO) rm -rf $(BUILD)/iso_data.stamp
	$(SUDO) rm -rf $(BUILD)/iso_casper.stamp
	$(SUDO) rm -rf $(ISO)
	$(SUDO) rm -rf $(BUILD)/qemu.img

clean-common:
	$(SUDO) rm -rf $(COMMON)


clean-all:
	$(SUDO) rm -rf build
