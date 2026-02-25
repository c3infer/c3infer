# Build and Run

## Build

From workspace `build/`:

```bash
cd build

# Build debos disk in OpenCCA container and fetch model.gguf
sudo DEBOS_MODE=container ./build_debos_disk_with_remote_gguf.sh

# Build toolchains + firmware + kernels + buildroot/qemu artifacts
make -j32 full-stack

# Re-sync and rebuild (workaround if c3infer update is missed)
cd ..
repo sync -j32 --no-clone-bundle
cd build
make -j32 full-stack
```

## Run Stack

From workspace `build/`:

```bash
# Copy debos-fs/out/rootfs.img -> out-br/images/rootfs{1,2,3}.img and start PTYs
./start_cca.sh

# In another terminal/pane
make run-only-multiregion
```

## Run Use Cases

Use the per-usecase guide:

- [usecases/README.md](../usecases/README.md)
