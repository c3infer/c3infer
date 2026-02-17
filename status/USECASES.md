# Usecases Runbook

This file explains how to run each usecase, split by Host actions and Realm actions.

## Usecase: `rnet_ra`

### Host
Run:

```bash
c3infer/buildroot-external-cca/overlay/realm1_overlay/root/usecases/rnet_ra/start_realms.sh
```

This starts:
- `rnet` realm (with net)
- `ra` realm

### Realms
Inside the started realms:

1. Start consumer/receiver side first (`ra` side).
2. Start producer/sender side second (`rnet` side).

Main scripts in disk:
- `/root/usecases/rnet_ra/rnet.sh`
- `/root/usecases/rnet_ra/ra.sh` (or `/root/usecases/rnet_ra/ra_slave.sh` depending on scenario)

---

## Usecase: `rg_rn_re`

### Host
Run:

```bash
c3infer/buildroot-external-cca/overlay/realm1_overlay/root/usecases/rg_ri_re/start_realms.sh
```

This starts:
- `RG` realm (with net)
- `RE` realm
- `RN` realm

### Realms
Usecase folder in disk:

- `/root/usecases/rg_rn_re`

Scripts are split in two phases:
- Setup phase (prefault + policy upload): `rg_setup.sh`, `rn_setup.sh`, `re_setup.sh`
- App phase (stream/analyze/encode): `rg_app.sh`, `rn_app.sh`, `re_app.sh`

Compatibility wrappers:
- `rg.sh`, `rn.sh`, `re.sh` (run setup+app together)

Recommended execution order:

1. Setup/install phase (strictly sequential):
```bash
# RG terminal (wait until complete)
cd /root/usecases/rg_rn_re && ./rg_setup.sh

# RE terminal (start only after RG setup finished)
cd /root/usecases/rg_rn_re && ./re_setup.sh

# RN terminal (start only after RE setup finished)
cd /root/usecases/rg_rn_re && ./rn_setup.sh
```

2. App phase:
```bash
# RN terminal
cd /root/usecases/rg_rn_re && ./rn_app.sh

# RE terminal
cd /root/usecases/rg_rn_re && ./re_app.sh

# RG terminal
cd /root/usecases/rg_rn_re && ./rg_app.sh
```

Before app phase, generate tiny input video once in RG realm:
```bash
cd /root/usecases/rg_rn_re && ./make_tiny.sh
```
This creates `/root/usecases/rg_rn_re/tiny.mp4` (target: `<= 262112` bytes).

Current configured sizing for `rg_rn_re`:
- Per-shmem size in policy: `0x40000` (256 KiB)
- Single payload cap: `262112` bytes (256 KiB minus 32-byte header)

---

## Quick Checks

- If upload fails with SGT errors, run setup scripts one-by-one before app scripts.
- If parse fails, inspect the exact runtime config under `/root/usecases/.../configs`.
