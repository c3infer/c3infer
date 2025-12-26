# cca_patches
Patches for our project

Requirements: ts

## Build components
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
<<<<<<< HEAD
=======

## Run Qemu
a) Start ptys:
```
./build/start_cca_pty.sh
```

b) Open a new concole in tmux with `ctrl+b+c`

c) Run Qemu:
```
make run-only
```

## Boot realms for use-cases
>>>>>>> 21bba74 (update README)
