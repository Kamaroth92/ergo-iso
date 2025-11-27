$(BUILD)/debootstrap:
	mkdir -p $(@D)

	$(SUDO) rm -rf "$@" "$@.partial"

	if ! $(SUDO) debootstrap \
		--arch=$(DISTRO_ARCH) \
		"$(UBUNTU_CODE)" \
		"$@.partial" \
		$(if $(LOCAL_APT_PROXY),$(LOCAL_APT_PROXY)/ubuntu,$(UBUNTU_MIRROR)); \
	then \
		cat "$@.partial/debootstrap/debootstrap.log"; \
		false; \
	fi

	$(SUDO) mv "$@.partial" "$@"