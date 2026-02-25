# C3Infer

TODO: Add C3Infer description here.

## Build and Install

```bash
# Host dependencies
sudo apt update
sudo apt install -y git tmux screen docker.io gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
sudo systemctl enable --now docker

# Follow OP-TEE/QEMU prerequisites:
# https://linaro.atlassian.net/wiki/spaces/QEMU/pages/29051027459/Building+an+RME+stack+for+QEMU#With-the-OP-TEE-build-environment

# Fresh workspace
mkdir -p c3infer
cd c3infer

repo init -u https://github.com/c3infer/cca_patches.git -b master -m default_remote_disk.xml
repo sync -j32 --no-clone-bundle

# Build disk + full stack
cd build
sudo DEBOS_MODE=container ./build_debos_disk_with_remote_gguf.sh
make -j32 full-stack
```

## Run

From workspace `build/`:

```bash
# Copy debos-fs/out/rootfs.img -> out-br/images/rootfs{1,2,3}.img and start PTYs
./start_cca.sh

# In another terminal/pane
make run-only-multiregion
```

## Example Use Case: `rnet_ra` - Network service Realm

```bash
# Host
/root/usecases/rnet_ra/start_realms.sh

# realmA (rnet)
/root/usecases/rnet_ra/rnet.sh

# realmB (ra)
/root/usecases/rnet_ra/ra.sh
```

## More Use Cases

See the detailed runbook:

- [usecases/README.md](usecases/README.md)
