# Use Cases Runbook

This file explains how to run each use case, split by Host and Realm steps.

## Shared Rule: Policy Payload Visibility

Policy payloads are exposed through host debugfs and are visible to the gateway realm of the group:
- `rnet_ra`: gateway is `RNET`
- `rg_rn_re` and `rg_rf_ri`: gateway is `RG`

In other words, each payload is seen by either `RG` or `RNET`, depending on the use case topology.

## Shared Rule: tmux Realm Mapping

- For `rnet_ra`:
- `rnet` = `realmA` in tmux
- `ra` = `realmB` in tmux

- For the other use cases, realms follow launch order:
- `realmA` = first name in the use case
- `realmB` = second name in the use case
- `realmC` = third name in the use case (when present)
- Example: `rg_rn_re` => `rg=realmA`, `rn=realmB`, `re=realmC`
- Example: `rg_rf_ri` => `rg=realmA`, `rf=realmB`, `ri=realmC`

## Use Case: `rnet_ra` - Network service Realm

### Host
Login password: `root`.

Run:

```bash
/root/usecases/rnet_ra/start_realms.sh
```

This starts:
- `rnet` realm (with net)
- `ra` realm

### Realms
Inside the started realms:

`RA` login password: `root`.

Run realms like this:
```bash
# realmA (rnet)
/root/usecases/rnet_ra/rnet.sh

# realmB (ra)
/root/usecases/rnet_ra/ra.sh
```

Main scripts in disk:
- `/root/usecases/rnet_ra/rnet.sh`
- `/root/usecases/rnet_ra/ra.sh`


### Attestation
Inside gateway realm A (`rnet`):

```bash
/root/cca-workload-attestation report
```

On host, inspect policy payloads for this 2-realm group:

```bash
cat /sys/kernel/debug/cca_policies/payload0
cat /sys/kernel/debug/cca_policies/payload1
```

---

## Use Case: `rg_rn_re` - Multi-stage Video Moderation

### Host
Run:

```bash
/root/usecases/rg_ri_re/start_realms.sh
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

### Attestation
Inside gateway realm A (`RG`):

```bash
/root/cca-workload-attestation report
```

On host, inspect policy payloads for this 3-realm group:

```bash
cat /sys/kernel/debug/cca_policies/payload0
cat /sys/kernel/debug/cca_policies/payload1
cat /sys/kernel/debug/cca_policies/payload2
```

---

## Use Case: `rg_rf_ri` - Guard-Railed LLM Inference

### Host
Run:

```bash
/root/usecases/rg_rf_ri/start_realms.sh
```

This starts:
- `RG` realm (with net)
- `RF` realm
- `RI` realm

### Realms
Usecase folder in disk:

- `/root/usecases/rg_rf_ri`

Scripts are split in two phases:
- Setup phase (prefault + policy upload): `rg_setup.sh`, `rf_setup.sh`, `ri_setup.sh`
- App phase (prompt/filter/inference/filter-back): `rg_app.sh`, `rf_app.sh`, `ri_app.sh`

Recommended execution order:

1. Setup/install phase (strictly sequential):
```bash
# RG terminal (wait until complete)
cd /root/usecases/rg_rf_ri && ./rg_setup.sh

# RF terminal (start only after RG setup finished)
cd /root/usecases/rg_rf_ri && ./rf_setup.sh

# RI terminal (start only after RF setup finished)
cd /root/usecases/rg_rf_ri && ./ri_setup.sh
```

2. App phase:
```bash
# RI terminal (wait for filtered prompt)
cd /root/usecases/rg_rf_ri && ./ri_app.sh

# RF terminal (wait for prompt, then filter->infer->filter-back)
cd /root/usecases/rg_rf_ri && ./rf_app.sh

# RG terminal (interactive prompt + final output)
cd /root/usecases/rg_rf_ri && ./rg_app.sh
```

Current configured sizing for `rg_rf_ri`:
- Per-shmem size in policy: `0x2000`
- Shared-memory policy permissions: `RW`

### Attestation
Inside gateway realm A (`RG`):

```bash
/root/cca-workload-attestation report
```

On host, inspect policy payloads for this 3-realm group:

```bash
cat /sys/kernel/debug/cca_policies/payload0
cat /sys/kernel/debug/cca_policies/payload1
cat /sys/kernel/debug/cca_policies/payload2
```

---

## Quick Checks

- If upload fails with SGT errors, run setup scripts one-by-one before app scripts.
- If parse fails, inspect the exact runtime config under `/root/usecases/.../configs`.
