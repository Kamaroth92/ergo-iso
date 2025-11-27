ifeq ($(DISTRO_BASE_VERSION),24.04)
UBUNTU_CODE:=noble
UBUNTU_NAME:=Noble Numbat
else ifeq ($(DISTRO_BASE_VERSION),26.04)
UBUNTU_CODE:=resolute
UBUNTU_NAME:=Resolute Raccoon
else
$(error unsupported DISTRO_VERSION $(DISTRO_BASE_VERSION))
endif

ifeq ($(DISTRO_ARCH),amd64)
UBUNTU_MIRROR:=http://archive.ubuntu.com/ubuntu
else
$(error unsupported DISTRO_ARCH $(DISTRO_ARCH))
endif

UBUNTU_COMPONENTS:=\
	main \
	restricted \
	universe \
	multiverse

UBUNTU_REPOS:=\
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE) $(UBUNTU_COMPONENTS)' \
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE)-security $(UBUNTU_COMPONENTS)' \
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE)-updates $(UBUNTU_COMPONENTS)' \
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE)-backports $(UBUNTU_COMPONENTS)'
