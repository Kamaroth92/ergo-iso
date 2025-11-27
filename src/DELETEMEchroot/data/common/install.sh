PACKAGES="
    ethtool
    nano
    curl
    traceroute
    python3
    ubuntu-server
    rsync
    linux-virtual-hwe-$DISTRO_BASE_VERSION
    initramfs-tools
"

apt-get update
apt-get install --yes $PACKAGES
apt-get autoremove --purge -y
apt-get clean -y
