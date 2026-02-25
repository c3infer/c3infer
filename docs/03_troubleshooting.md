# Troubleshooting

## QEMU Missing `ivshmem-plain.protected`

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

## Disk Path Override

`start_cca.sh` expects `../debos-fs/out/rootfs.img`.

Override if needed:

```bash
DEBOS_OUT_IMG=/absolute/path/rootfs.img ./start_cca.sh
```
