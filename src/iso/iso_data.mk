$(BUILD)/iso/efi/dir.stamp:
	rm -rf "$(BUILD)/iso/efi"
	mkdir -p "$(BUILD)/iso/efi/boot/"
	
	touch "$@"

$(BUILD)/grub: $(BUILD)/iso_dir.stamp $(BUILD)/iso/efi/dir.stamp
	rm -rf "$@.partial"
	rm -rf "$@"
	mkdir "$@.partial"

	grub-mkimage \
		--directory /usr/lib/grub/i386-pc \
		--prefix /boot/grub \
		--output "$@.partial/eltorito.img" \
		--format i386-pc-eltorito \
		--compression auto \
		biosdisk iso9660

	# cp -r "src/iso/data/efi/shimx64.efi.signed" "$(BUILD)/iso/efi/boot/bootx64.efi"
	# cp -r "/usr/lib/grub/x86_64-efi-signed/gcdx64.efi.signed" "$(BUILD)/iso/efi/boot/grubx64.efi"

	cp -r "src/iso/data/efi/bootx64.efi" "$(BUILD)/iso/efi/boot/"
	cp -r "src/iso/data/efi/grubx64.efi" "$(BUILD)/iso/efi/boot/"
	cp -r "src/iso/data/efi/mmx64.efi" "$(BUILD)/iso/efi/boot/"

	mkfs.vfat -C "$@.partial/efi.img" 4096
	mcopy -s -i "$@.partial/efi.img" "$(BUILD)/iso/efi" ::/

	mv "$@.partial" "$@"

$(BUILD)/iso_data.stamp: $(BUILD)/grub
	rm -rf "$(BUILD)/iso/.disk"
	mkdir -p "$(BUILD)/iso/.disk"
	sed "$(SED)" "src/iso/data/disk/info" > "$(BUILD)/iso/.disk/info"

	rm -rf "$(BUILD)/iso/boot/grub"
	mkdir -p "$(BUILD)/iso/boot/grub"
	sed "$(SED)" "src/iso/data/grub/grub.cfg" > "$(BUILD)/iso/boot/grub/grub.cfg"
	cp /usr/share/grub/unicode.pf2 "$(BUILD)/iso/boot/grub/font.pf2"

	mkdir -p "$(BUILD)/iso/boot/grub/i386-pc"
	cp "$(BUILD)/grub/eltorito.img" "/usr/lib/grub/i386-pc/"*.mod "$(BUILD)/iso/boot/grub/i386-pc/"

	cp "$(BUILD)/grub/efi.img" "$(BUILD)/iso/boot/grub"
	mkdir -p "$(BUILD)/iso/boot/grub/x86_64-efi"
	cp "/usr/lib/grub/x86_64-efi/"*.mod "$(BUILD)/iso/boot/grub/x86_64-efi/"

	rm -rf "$(BUILD)/iso/isolinux"
	mkdir -p "$(BUILD)/iso/isolinux"
	cp /usr/lib/ISOLINUX/isolinux.bin "$(BUILD)/iso/isolinux/isolinux.bin"
	cp /usr/lib/syslinux/modules/bios/ldlinux.c32 "$(BUILD)/iso/isolinux/ldlinux.c32"
	sed "$(SED)" "src/iso/data/isolinux/isolinux.cfg" > "$(BUILD)/iso/isolinux/isolinux.cfg"

	touch "$@"

$(BUILD)/iso/md5sum.txt: $(BUILD)/iso_casper.stamp $(BUILD)/iso_data.stamp
	cd "$(BUILD)/iso" && \
	rm -f md5sum.txt && \
	find ! -name "*.stamp" -type f -print0 | sort -z | xargs -0 md5sum > $(shell basename $@)

$(ISO): $(BUILD)/iso/md5sum.txt
	sudo rm -f $(ISO)
	sudo rm -f "build/build.iso"
	sudo rm -f "build/$(ISO_NAME).iso"
	
	xorriso -as mkisofs \
		-J \
		-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
		-c isolinux/boot.cat -b isolinux/isolinux.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		-eltorito-alt-boot -e boot/grub/efi.img \
		-no-emul-boot -isohybrid-gpt-basdat \
		-r -V "$(DISTRO_VOLUME_LABEL)" \
		-m "*.stamp" \
		-o "$@.partial" "$(BUILD)/iso" -- \
		-volume_date all_file_dates ="$(DISTRO_EPOCH)"

	mv "$@.partial" "$@"
	ln "$@" "build/build.iso"
	ln "$@" "build/$(ISO_NAME).iso"
