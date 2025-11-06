# cca_patches
Patches for our project

```bash
mkdir c3infer
cd c3infer
repo init -u ssh://git@gitlab.doc.ic.ac.uk/aalsadi/cca_patches.git
repo sync -j8 --no-clone-bundle
cd build
make -j8 toolchains
make -j8
```bash