#!/bin/bash
sudo apt-get update --yes
sudo apt install --yes \
	debootstrap \
	grub-efi-amd64-signed \
	grub-pc-bin \
	isolinux \
	mtools \
	ovmf \
	qemu-system \
	squashfs-tools \
	xorriso \
	dosfstools \
	zsync \
	unzip \
	make \
	shfmt \
	jq

# Install bws
BWS_CLI_VERSION=1.0.0
BWS_DOWNLOAD=https://github.com/bitwarden/sdk-sm/releases/download/bws-v${BWS_CLI_VERSION}/bws-x86_64-unknown-linux-gnu-${BWS_CLI_VERSION}.zip
wget $BWS_DOWNLOAD -O /tmp/bws.zip
sudo unzip -qn /tmp/bws.zip -d /usr/local/bin
