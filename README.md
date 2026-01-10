# cca_patches
This repository provides a step-by-step guide to reproduce and customize usecases of the paper.

## 1 Install Requirements
```
sudo apt update
sudo apt install tmux screen
```
## 2 Build Components
```
mkdir c3infer
cd c3infer
repo init -u ssh://git@gitlab.doc.ic.ac.uk/c3infer/cca_patches.git
repo sync -j16 --no-clone-bundle
./cca_patches/apply_patches.sh
cd build
make -j16 toolchains
make -j16
```

## 3 Run QEMU
a) Start ptys:
```
./start_cca_multiregion_pty.sh
```

b) Open a new concole in tmux with `ctrl+b + c`

c) Run Qemu:
```
make run-only-multiregion
```
d) Open `host` concole and log into NW userspace with `root` username. You can move between tmux consoles with `ctrl+b + n` or `ctrl+b + p`

## 4 Boot realms for use cases
For reproducing each use case, please continue the steps above in the guidance provided at [use cases](https://gitlab.doc.ic.ac.uk/c3infer/cca_patches/-/tree/master/usecases?ref_type=heads) page.
