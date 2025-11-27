$(BUILD)/chroot: $(BUILD)/debootstrap 
	scripts/unmount.sh "$@.partial"
	sudo rm -rf "$@" "$@.partial"
	
	sudo cp -a "$<" "$@.partial"
	sudo mkdir -p "$@.partial/work"

	sudo cp "scripts/apt.sh" "$@.partial/work/apt.sh"
	"scripts/mount.sh" "$@.partial"

	# Configure sources
	sudo truncate --size=0 "$@.partial/etc/apt/sources.list"
	echo $(UBUNTU_REPOS) | sudo tee "$@.partial/etc/apt/sources.list"
	sudo sed -i 's/ deb/\ndeb/g' "$@.partial/etc/apt/sources.list"

	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"APT_CACHE=$(LOCAL_APT_PROXY) \
		UPDATE=1 \
		UPGRADE=1 \
		INSTALL=\"--no-install-recommends gnupg software-properties-common\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		work/apt.sh"

	sudo cp "scripts/chroot.sh" "$@.partial/work/chroot.sh"
	sudo chmod +x "$@.partial/work/chroot.sh"
	sudo cp -r "src/$(shell basename $@)/data" "$@.partial/work/data"

	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"APT_CACHE=$(LOCAL_APT_PROXY) \
		DISTRO_BASE_VERSION=$(DISTRO_BASE_VERSION) \
		FILE=/work/data/init.sh \
		/work/chroot.sh"

	scripts/unmount.sh "$@.partial"

	sudo rm -rf "$@.partial/work"
	mv "$@.partial" "$@"
