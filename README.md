## C3Infer: A Framework for Compartmentalized, Confidential, and Certified AI Inference

This organization hosts the code developed for **C3Infer**, a framework for running **AI inference pipelines** that are *compartmentalized*, *confidential*, and *policy-controlled end-to-end*.

### What we built: Mica
The main outcome of this project is **Mica**: a confidential computing architecture that replaces implicit “TEE-to-TEE trust” with **explicit, enforceable, and attestable communication policies**. Instead of assuming components won’t leak data, Mica requires that **every cross-component interaction** (memory sharing + control transitions) is **declared and constrained**.

### Implementation (Arm CCA)
We implement Mica on **Arm CCA** by extending the full virtualization stack:
- **KVM**
- **RMM** (policy enforcement point)
- **QEMU VMM**

This enables realistic **multi-stage inference pipelines** spanning multiple **Realms**, with tight control over how data and control signals move across compartments.

### Policy model
We develop a simple **DSL** that is **enforced inside the RMM** to explicitly define:
- **Shared memory ranges** between Realms
- **ACLs** governing which Realms can access which shared regions
- Support for **confidential shared memory** between Realms
- Allowed **non-memory transitions** involving the hypervisor, e.g.:
  - **interrupt delivery**
  - **RSIs (Realm Service Interface)** and other permitted Realm↔hypervisor interactions

### Why it matters (AI-friendly)
With Mica, we can run **realistic AI inference workloads** as compartmentalized pipelines where the **entire execution path**—from data ingress, to preprocessing, to model execution, to postprocessing—operates under **explicit security policy control**, rather than relying on fragile trust assumptions between pipeline stages.

## Build and Install

### Install

Install OP-TEE/QEMU prerequisites from Linaro [here](https://linaro.atlassian.net/wiki/spaces/QEMU/pages/29051027459/Building+an+RME+stack+for+QEMU#With-the-OP-TEE-build-environment).

```bash
# Host dependencies
sudo apt update
sudo apt install -y git tmux screen docker.io gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
sudo systemctl enable --now docker

# Fresh workspace
mkdir -p c3infer
cd c3infer

repo init -u https://github.com/c3infer/c3infer.git -b master -m default_remote_disk.xml
repo sync -j32 --no-clone-bundle
# Run a second sync to resolve occasional copyfile/linkfile inconsistencies
repo sync
```

### Build

```bash
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

Login note: Host and `realmB` (`ra`) use password `root`.

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

## C3Infer Components (Org Repositories)

| Repo Path | Repo Name | Purpose |
|---|---|---|
| `c3infer` | `c3infer` | (this repository) Manifest, glue scripts, and build integration. |
| `buildroot-external-cca/overlay` | `buildroot_overlay` | Realm/rootfs overlay content (`f_realm`) used in the RamFS image. |
| `debos-fs` | `debos-fs` | Debos rootfs image build and disk overlay pipeline. |
| `opencca-build` | `opencca-build` | Dockerized environment used to run debos disk builds. |
| `qemu` | `qemu` | CCA-enabled QEMU fork used by the stack. |
| `linux` | `host-linux` | Host kernel tree used by the stack. |
| `linux-guest` | `guest-linux` | Guest/realm kernel tree used by the stack. |
| `rmm` | `rmm` | Realm Management Monitor implementation. |

## Troubleshooting / Gotcha

### QEMU Missing `ivshmem-plain.protected`

If startup fails with:

`Property 'ivshmem-plain.protected' not found`

the wrong QEMU ref/binary is being used.

Check active Buildroot QEMU from workspace root (`c3infer`):

```bash
./out-br/host/bin/qemu-system-aarch64 -device ivshmem-plain,help
```

If `protected` is missing, clean only qemu-cca caches and rebuild:

```bash
rm -rf buildroot/dl/qemu-cca out-br/build/qemu-cca-* out-br/per-package/qemu-cca
cd build
make -j32 buildroot
```

Verify package source/ref in:

- `buildroot-external-cca/package/qemu-cca/qemu.mk` (`QEMU_CCA_SITE`, `QEMU_CCA_VERSION`)
