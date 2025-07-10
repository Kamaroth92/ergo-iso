$(BUILD)/iso_dir.stamp:
	sudo rm -rf "$(BUILD)/iso"
	mkdir -p "$(BUILD)/iso"
	touch "$@"

$(BUILD)/iso/$(CASPER_PATH)/filesystem.size: $(BUILD)/live.packages $(BUILD)/iso_dir.stamp
	sudo rm -rf "$(BUILD)/iso/casper"*
	mkdir -p "$(BUILD)/iso/$(CASPER_PATH)"

	cp "$(BUILD)/live.packages" "$(BUILD)/iso/$(CASPER_PATH)/filesystem.manifest"
	# grep -F -x -v -f "$(BUILD)/chroot.packages" "$(BUILD)/live.packages" | cut -f1 > "$(BUILD)/iso/$(CASPER_PATH)/filesystem.manifest-remove"

	sudo du -sx --block-size=1 "$(BUILD)/live" | cut -f1 > "$(BUILD)/iso/$(CASPER_PATH)/filesystem.size"

$(BUILD)/iso_squashfs.stamp: $(BUILD)/iso/$(CASPER_PATH)/filesystem.size
	rm -rf "$@.partial"
	rm -rf "$@"
	touch "$@.partial"
	sudo mksquashfs "$(BUILD)/live" \
		"$(BUILD)/iso/$(CASPER_PATH)/filesystem.squashfs.partial" \
		-noappend -fstime "$(DISTRO_EPOCH)" \
		-comp xz -b 1M -Xdict-size 1M -Xbcj x86

	mv "$(BUILD)/iso/$(CASPER_PATH)/filesystem.squashfs.partial" "$(BUILD)/iso/$(CASPER_PATH)/filesystem.squashfs"
	mv "$@.partial" "$@"

$(BUILD)/iso_casper.stamp: $(BUILD)/iso_squashfs.stamp
	sudo cp "$(BUILD)/live/boot/vmlinuz" "$(BUILD)/iso/$(CASPER_PATH)/vmlinuz"
	sudo cp "$(BUILD)/live/boot/initrd.img" "$(BUILD)/iso/$(CASPER_PATH)/initrd.img"

	sudo chown -R "$(USER):$(USER)" "$(BUILD)/iso/$(CASPER_PATH)"

	ln -sf "$(CASPER_PATH)" "$(BUILD)/iso/casper"

	touch "$@"