# cca_patches
Patches for our project

Requirements: ts, tmux

## 1 Build components
```
mkdir c3infer
cd c3infer
repo init -u ssh://git@gitlab.doc.ic.ac.uk/c3infer/cca_patches.git
repo sync -j8 --no-clone-bundle
repo sync cca_patches
cd build
make -j8 toolchains
make -j8
```

## 2 Run QEMU
a) Start ptys:
```
./start_cca_multiregion_pty.sh
```

b) Open a new concole in tmux with `ctrl+b+c`

c) Run Qemu:
```
make run-only-multiregion
```
d) Open host concole and log into NW userspace with `root` username.

## 3 Boot realms for use cases
For reproducing each use case, please follow the guidance provided at [use cases](https://gitlab.doc.ic.ac.uk/c3infer/cca_patches/-/tree/master/usecases?ref_type=heads) page.
