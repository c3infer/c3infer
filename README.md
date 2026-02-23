# cca_patches

Find the project status [here](status/README.md)

This repository provides a step-by-step guide to reproduce and customize usecases of the paper.

## 1 Install Requirements
```
sudo apt update
sudo apt install tmux screen docker.io
sudo systemctl enable --now docker
```

Container mode (used in fresh installation below) requires Docker socket access for your user:
```bash
sudo usermod -aG docker $USER
newgrp docker
docker ps
```
If `docker ps` still fails, log out and log back in once.

## 2 Fresh Installation in `c3infer` (remote disk + model)
```bash
mkdir -p c3infer
cd c3infer

repo init -u ssh://git@gitlab.doc.ic.ac.uk/c3infer/cca_patches.git -b master -m default_remote_disk.xml
repo sync -j32 --no-clone-bundle

cd build
sudo ./build_debos_disk_container_sudo.sh
make -j32 full-stack
```

This flow uses `default_remote_disk.xml` and automatically prepares:
- model download into disk overlay
- debos disk image build
- normal firmware/kernel/qemu/rootfs build

Note: `start_cca_multiregion_pty_with_remote_disk.sh` does not compile components and does not build a disk. It only copies the already built `opencca-build/out/rootfs.img` into `out-br/images/rootfs{1,2,3}.img` and starts PTYs.
Also make sure `../opencca-build/docker` exists in the same workspace (or set `OPENCCA_DOCKER_DIR` to your actual path).

Run:
```bash
./start_cca_multiregion_pty_with_remote_disk.sh
make run-only-multiregion
```

Disk build controls (optional):
- `DEBOS_MODE=auto|local|container` (default: `auto`)
- `OPENCCA_DOCKER_DIR=<path to opencca-build/docker>`
- `MODEL_SHA256=<expected model sha256>`
- `FORCE_REBUILD_DISK=1`

If you already built the disk separately with `sudo ./build_debos_disk_container_sudo.sh`, no extra `DEBOS_MODE`/`OPENCCA_DOCKER_DIR` flags are needed for `make -j32 full-stack`.

## 3 Build Components (kernel from source)
```
mkdir c3infer
cd c3infer
repo init -u ssh://git@gitlab.doc.ic.ac.uk/c3infer/cca_patches.git -b master -m default.xml
repo sync -j32 --no-clone-bundle
repo sync cca_patches
cd build
make -j32 toolchains
make -j32
```

## 4 Build Components (with patches)
```
mkdir c3infer
cd c3infer
repo init -u ssh://git@gitlab.doc.ic.ac.uk/c3infer/cca_patches.git -b master -m default.xml
repo sync -j16 --no-clone-bundle
./cca_patches/apply_patches.sh
cd build
make -j16 toolchains
make -j16
TODO: copy Makefile
```

## 5 Run QEMU
a) Start ptys:
```
./start_cca_multiregion_pty.sh
```

b) Open a new console in tmux with `ctrl+b + c`

c) Run Qemu:
```
make run-only-multiregion
```
d) Open `host` concole and log into NW userspace with `root` username. You can move between tmux consoles with `ctrl+b + n` or `ctrl+b + p`

## 6 Boot realms for use cases
For reproducing each use case, please continue the steps above in the guidance provided at [use cases](https://gitlab.doc.ic.ac.uk/c3infer/cca_patches/-/tree/master/usecases?ref_type=heads) page.
