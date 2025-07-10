ifeq ($(DISTRO_ARCH),amd64)
QEMU=qemu-system-x86_64
QEMUFLAGS=\
	-m 4G \
	-smp 4 \
	-display none \
	-vnc :0

ifeq ($(IS_WSL),0)
QEMUFLAGS+=\
	-enable-kvm \
	-cpu host \
	-chardev serial,path=/dev/ttyS4,id=hostusbserial \
	-device pci-serial,chardev=hostusbserial \
	-bios /usr/share/OVMF/OVMF_CODE.fd
else
# WSL2 does not support KVM and other serial interfaces
QEMUFLAGS+=\
	-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
	-chardev file,path=serial.log,id=virtserial \
	-device isa-serial,chardev=virtserial
endif

BOOTLOADER=UEFI
# QEMUFLAGS+=
QEMUFLAGS+=-netdev user,id=net0 -device e1000,netdev=net0
else
$(error unknown DISTRO_ARCH $(DISTRO_ARCH))
endif

$(BUILD)/%.img:
	mkdir -p $(BUILD)
	qemu-img create -f qcow2 "$@.partial" 60G
	mv "$@.partial" "$@"

qemu: $(ISO) $(BUILD)/qemu.img
	$(SUDO) $(QEMU) $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) $(DISTRO_ARCH) $(BOOTLOADER) ISO" \
		-drive file=$(BUILD)/qemu.img,format=qcow2,if=none,id=nvme0 \
		-device nvme,drive=nvme0,serial=deadbeef \
		-boot d -cdrom "$<" 
		
		# -hda $(BUILD)/qemu.img \

qemu_wsl2: $(ISO) $(BUILD)/qemu.img
	$(SUDO) $(QEMU) $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) $(DISTRO_ARCH) $(BOOTLOADER) ISO" \
		-drive file=$(BUILD)/qemu.img,format=qcow2,if=none,id=nvme0 \
		-device nvme,drive=nvme0,serial=deadbeef \
		-boot d -cdrom "$<" \
		-chardev serial,path=/dev/ttyS4,id=hostusbserial \
		-device pci-serial,chardev=hostusbserial
		# -hda $(BUILD)/qemu.img \

qemu_usb: $(ISO) $(BUILD)/qemu.img
	$(QEMU) $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) $(DISTRO_ARCH) $(BOOTLOADER) USB" \
		-hda $(BUILD)/qemu.img \
		-boot d -drive if=none,id=img,file="$<" \
		-device nec-usb-xhci,id=xhci \
		-device usb-storage,bus=xhci.0,drive=img
