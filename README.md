# cca_patches

Minimal guide for the current `default_remote_disk.xml` flow.

## 1) Host prerequisites
Base tools:
```bash
sudo apt update
sudo apt install -y git tmux screen docker.io gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
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
sudo DEBOS_MODE=container ./build_debos_disk_with_remote_gguf.sh

# Build toolchains + firmware + kernels + buildroot/qemu artifacts
make -j32 full-stack

# Re-sync manifests/projects, then rebuild (workaround when cca_patches update is missed)
cd ..
repo sync -j32 --no-clone-bundle
cd build
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
Use the external use case guide [here](https://github.com/c3infer/cca_patches/tree/master/usecases).

## 6) Gotcha: Wrong QEMU at Runtime
If realm startup fails with:
- `Property 'ivshmem-plain.protected' not found`

you are running a QEMU binary that does not include the expected CCA patchset/ref.

Debug:
```bash
# Run from workspace root (c3infer)
./out-br/host/bin/qemu-system-aarch64 -device ivshmem-plain,help
```
If `protected` is missing in the option list, your built `qemu-cca` ref does not provide it (or you are executing a different binary).

Fix:
```bash
# Clean qemu-cca download/build cache only
rm -rf buildroot/dl/qemu-cca out-br/build/qemu-cca-* out-br/per-package/qemu-cca

# Rebuild buildroot artifacts
cd build
make -j32 buildroot
```

Also verify the package source/ref:
- `buildroot-external-cca/package/qemu-cca/qemu.mk` (`QEMU_CCA_SITE`, `QEMU_CCA_VERSION`)

## Notes
- `start_cca.sh` expects `../debos-fs/out/rootfs.img`.
- Override disk path if needed:
```bash
DEBOS_OUT_IMG=/absolute/path/rootfs.img ./start_cca.sh
```

## C3Infer Components (Org Repositories)
Summary of the C3Infer-owned parts used by this stack.

| Repo Path | Repo Name | Purpose |
|---|---|---|
| `cca_patches` | `cca_patches` | (this repository) Manifest, glue scripts, and build integration. |
| `buildroot-external-cca/overlay` | `buildroot_overlay` | Realm/rootfs overlay content (`f_realm`) used in the RamFS image. |
| `debos-fs` | `debos-fs` | Debos rootfs image build and disk overlay pipeline. |
| `opencca-build` | `opencca-build` | Dockerized environment used to run debos disk builds. |
| `linux` | `host-linux` | Host kernel tree used by the stack. |
| `linux-guest` | `guest-linux` | Guest/realm kernel tree used by the stack. |
| `rmm` | `rmm-private` | Realm Management Monitor implementation. |
