# Install and Workspace Setup

## Host Dependencies

```bash
sudo apt update
sudo apt install -y git tmux screen docker.io gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
sudo systemctl enable --now docker
```

## OP-TEE/QEMU Prerequisites

Follow the OP-TEE environment prerequisites from Linaro:

<https://linaro.atlassian.net/wiki/spaces/QEMU/pages/29051027459/Building+an+RME+stack+for+QEMU#With-the-OP-TEE-build-environment>

## Fresh Workspace

```bash
mkdir -p c3infer
cd c3infer

repo init -u https://github.com/c3infer/cca_patches.git -b master -m default_remote_disk.xml
repo sync -j32 --no-clone-bundle
```
