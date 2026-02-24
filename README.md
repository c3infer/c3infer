# cca_patches

Minimal guide for the current `default_remote_disk.xml` flow.

## 1) Host prerequisites
Base tools:
```bash
sudo apt update
sudo apt install -y git repo tmux screen docker.io
sudo systemctl enable --now docker
```

OP-TEE build environment prerequisites:
- Follow the OP-TEE environment setup from Linaro:
  <https://linaro.atlassian.net/wiki/spaces/QEMU/pages/29051027459/Building+an+RME+stack+for+QEMU#With-the-OP-TEE-build-environment>
- Ensure the OP-TEE/QEMU build prerequisites from that page are installed before running the steps below.

## 2) Fresh workspace
```bash
mkdir -p c3infer
cd c3infer

repo init -u https://github.com/c3infer/cca_patches.git -b master -m default_remote_disk.xml
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
