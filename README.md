
# Ergo

An automated RKE2 provisioner ISO for use in my homelab. Backed with Bitwarden Secrets Manager for managing secrets.
Harbor is used for imaged caching and in an environment where needed images are already cached it takes ~5 minutes from booting into the ISO on a USB drive to having a healthy control plane node in an existing cluster.
The ISO creation approach heavily borrows what is done for [POP!_OS](https://github.com/pop-os/iso)



## Usage/Examples
Specifying variables is done in two sections. One for the ISO itself, and another for provisioning target which utilizes `ergo-provisioner` for the post install provisioning.

Copy `locals.mk.example` and complete for ISO specific variabkes.
Copy `src/live/data/ergo-provisioner/uuid-node-map.json.example` and complete for each provisioning target.

Create and compress the live environment and then create an ISO with that image
```makefile
make iso
```

Once in the live environment you can write it to the disk with 
```bash
sudo ergo-install
sudo ergo-install -d <disk>
```
The largest disk will be automatically selected as the installation target but it can be overridden with `-d <disk>`
There will be a small directory at `/ergo-data` that will persist between `ergo-install` operations to persist config if needed between rebuilds / upgrades

## Notes

`ergo-provisioner` can definitely be swapped out with something like an API endpoint for fetching on first boot preventing it needing to be baked into the ISO.

`ansible` could be used for provisioning, but where is the fun in that.