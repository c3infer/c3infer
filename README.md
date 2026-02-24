# cca_patches

Minimal guide for the current `default_remote_disk.xml` flow.

## 1) Host prerequisites
```bash
sudo apt update
sudo apt install -y git repo tmux screen docker.io
sudo systemctl enable --now docker
```

Enable Docker access for your user (one-time):
```bash
sudo usermod -aG docker $USER
newgrp docker

docker ps
```
If `docker ps` still fails, log out and log back in once.

## 2) Fresh workspace
```bash
mkdir -p c3infer
cd c3infer

repo init -u ssh://git@gitlab.doc.ic.ac.uk/c3infer/cca_patches.git -b master -m default_remote_disk.xml
repo sync -j32 --no-clone-bundle
```

## 3) Build disk + full stack
From workspace `build/`:
```bash
cd build

# Build debos disk in OpenCCA container (requires sudo inside container)
sudo ./build_debos_disk_container_sudo.sh

# Build toolchains + firmware + kernels + buildroot/qemu artifacts
make -j32 full-stack
```

## 4) Run
From workspace `build/`:
```bash
# Copy debos-fs/out/rootfs.img -> out-br/images/rootfs{1,2,3}.img and start PTYs
./start_cca.sh

# In another terminal/pane
make run-only-multiregion
```

## 5) Use Cases
See the use-case [guide](usecases/README.md)

## Notes
- `start_cca.sh` expects `../debos-fs/out/rootfs.img`.
- Override disk path if needed:
```bash
DEBOS_OUT_IMG=/absolute/path/rootfs.img ./start_cca.sh
```
