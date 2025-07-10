# $(COMMON):
# 	$(SUDO) mkdir -p "$(COMMON)"

common-live: $(COMMON)/rke2

$(COMMON)/rke2:
	$(SUDO) rm -rf "$@"
	$(SUDO) mkdir -p "$@.partial"

	curl -Lso "$@.partial/rke2.linux-amd64.tar.gz" https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2.linux-amd64.tar.gz
	curl -Lso "$@.partial/rke2-images.linux-amd64.tar.gz" https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-images.linux-amd64.tar.gz
	curl -Lso "$@.partial/sha256sum-amd64.txt" https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/sha256sum-amd64.txt
	curl -Lso "$@.partial/install.sh" https://get.rke2.io

	$(SUDO) mkdir -p "$@.partial/images"
	curl -Lso "$@.partial/images/rke2-images-core.linux-amd64.tar.gz" https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-images-core.linux-amd64.tar.gz
	curl -Lso "$@.partial/images/rke2-images-canal.linux-amd64.tar.gz" https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-images-cilium.linux-amd64.tar.gz
	curl -Lso "$@.partial/images/rke2-images-cilium.linux-amd64.tar.gz" https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-images-cilium.linux-amd64.tar.gz

	mv "$@.partial" "$@"

.SILENT: $(BUILD)/live/build_vars.sh
$(BUILD)/build_vars.sh:
	$(SUDO) rm -rf "$@" "$@.partial"
	$(SUDO) echo "#!/usr/bin/env bash" > "$@.partial"
	$(SUDO) echo export ADMINISTRATOR_USER_PASSWORD=\''$(ADMINISTRATOR_USER_PASSWORD)'\' >> "$@.partial"
	$(SUDO) echo export ADMINISTRATOR_SSH_KEY=\''$(ADMINISTRATOR_SSH_KEY)'\' >> "$@.partial"
	$(SUDO) echo export HARBOR_IMAGE_MIRROR_USERNAME=\''$(HARBOR_IMAGE_MIRROR_USERNAME)'\' >> "$@.partial"
	$(SUDO) echo export HARBOR_IMAGE_MIRROR_PASSWORD=\''$(HARBOR_IMAGE_MIRROR_PASSWORD)'\' >> "$@.partial"
	$(SUDO) echo export HARBOR_IMAGE_MIRROR_REGISTRY=\''$(HARBOR_IMAGE_MIRROR_REGISTRY)'\' >> "$@.partial"
	$(SUDO) echo export DISTRO_BASE_VERSION=\''$(DISTRO_BASE_VERSION)'\' >> "$@.partial"
	mv "$@.partial" "$@"

$(BUILD)/live: $(BUILD)/debootstrap $(BUILD)/build_vars.sh common-live # $(COMMON)/rke2/images $(BUILD)/chroot 
	scripts/unmount.sh "$@.partial"
	$(SUDO) rm -rf "$@" "$@.partial"
	
	$(SUDO) cp -a "$<" "$@.partial"
	$(SUDO) mkdir -p "$@.partial/work"

	$(SUDO) cp "scripts/chroot.sh" "$@.partial/work/chroot.sh"
	$(SUDO) chmod +x "$@.partial/work/chroot.sh"
	$(SUDO) cp -r "src/$(shell basename $@)/data" "$@.partial/work/data"
	$(SUDO) cp -r "$(COMMON)" "$@.partial/work/common"

	"scripts/mount.sh" "$@.partial" "$(LOCAL_APT_PROXY)"

	# Configure sources
	$(SUDO) truncate --size=0 "$@.partial/etc/apt/sources.list"
	echo $(UBUNTU_REPOS) | $(SUDO) tee "$@.partial/etc/apt/sources.list"
	$(SUDO) sed -i 's/ deb/\ndeb/g' "$@.partial/etc/apt/sources.list"

	# Pass build vars
	mv "$(BUILD)/build_vars.sh" "$@.partial/work/"

	# Create directories and write vars into the filesystem
	$(SUDO) mkdir -p "$@.partial/work/vars"
	$(SUDO) echo -n '$(DISTRO_CODE)' > "$@.partial/work/vars/DISTRO_CODE"
	$(SUDO) echo -n '$(DISTRO_VERSION)' > "$@.partial/work/vars/DISTRO_VERSION"
	$(SUDO) echo -n '$(DISTRO_NAME)' > "$@.partial/work/vars/DISTRO_NAME"
	$(SUDO) echo -n '$(BUILD_TIME)' > "$@.partial/work/vars/BUILD_TIME"

	# Install live packages
	$(SUDO) $(CHROOT) "$@.partial" /bin/bash -e -c \
		"APT_CACHE=$(LOCAL_APT_PROXY) \
		FILE=/work/data/init.sh \
		/work/chroot.sh"

	scripts/unmount.sh "$@.partial"

	$(SUDO) rm -rf "$@.partial/work"
	mv "$@.partial" "$@"

$(BUILD)/live.packages: $(BUILD)/live
	$(SUDO) $(CHROOT) "$<" /bin/bash -e -c "dpkg-query -W --showformat='\$${Package}\t\$${Version}\n'" > "$@"
