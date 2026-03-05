## C3Infer: A Framework for Compartmentalized, Confidential, and Certified AI Inference

AI systems are increasingly organized as pipelines, where each stage may run as confidential computation but the steps in between still depend heavily on implicit trust. As part of the broader [AISI](https://www.aisi.gov.uk) mission to improve AI safety, security, and resilience in real-world deployment, **C3Infer** focuses on providing stronger control and attestation over how data and execution move across those boundaries. This organization hosts the code for **C3Infer**, an [AISI](https://www.aisi.gov.uk) project.

The main outcome of the project is **Mica** ([cite](#citation)), a confidential computing architecture for running **realistic AI inference pipelines** with **explicit, enforceable, and attestable** security policies across all stages.

We implement Mica on **Qemu support for Arm CCA** by extending **KVM**, **RMM**, and **QEMU VMM**, enabling compartmentalized pipelines spanning multiple isolated Realms.

A lightweight **DSL**, enforced inside the **RMM**, specifies:
- **shared memory ranges** and **ACLs** for Realm to Realm communication, including **confidential shared memory between Realms**
- allowed **non-memory transitions** with the hypervisor, such as **interrupts** and **RSIs**

This approach removes implicit trust between pipeline components by constraining all data and control flows to explicitly authorized and attestable paths.
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

See the detailed runbook [here](usecases/README.md).

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

## Troubleshooting

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

## Citation

If you use Mica/C3Infer in research, please cite:

```bibtex
@misc{mica,
      title={Sharing is caring: Attestable and Trusted Workflows out of Distrustful Components}, 
      author={Amir Al Sadi and Sina Abdollahi and Adrien Ghosn and Hamed Haddadi and Marios Kogias},
      year={2026},
      eprint={2603.03403},
      archivePrefix={arXiv},
      primaryClass={cs.CR},
      url={https://arxiv.org/abs/2603.03403}, 
}
```

## Get in Touch

Questions, bug reports, and collaboration ideas are all welcome. Feel free to reach out at [a.al-sadi@imperial.ac.uk](mailto:a.al-sadi@imperial.ac.uk).
