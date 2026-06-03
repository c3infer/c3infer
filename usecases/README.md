# Use Cases Runbook

This file explains how to run each use case, split by Host and Realm steps.

## tmux Quick Navigation

Use `Ctrl+b` as the tmux prefix, then:

```bash
# next window
Ctrl+b n

# previous window
Ctrl+b p

# switch to specific window number
Ctrl+b 0
Ctrl+b 1
Ctrl+b 2
```

## Important

Always restart the full stack before running a use case (or switching to a different use case).

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

### Run group attestation
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
Login password: `root`.
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

Recommended execution order:

1. Setup/install phase (strictly sequential):
```bash
# realmA (rg) terminal (wait until complete)
cd /root/usecases/rg_rn_re && ./rg_setup.sh

# realmB (re) terminal (start only after RG setup finished)
cd /root/usecases/rg_rn_re && ./re_setup.sh

# realmC (rn) terminal (start only after RE setup finished)
cd /root/usecases/rg_rn_re && ./rn_setup.sh
```

2. App phase:
```bash
# realmC (rn) terminal
cd /root/usecases/rg_rn_re && ./rn_app.sh

# realmB (re) terminal
cd /root/usecases/rg_rn_re && ./re_app.sh

# realmA (rg) terminal
cd /root/usecases/rg_rn_re && ./rg_app.sh
```

### Run group attestation
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
Login password: `root`.
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
# realmA (rg) terminal (wait until complete)
cd /root/usecases/rg_rf_ri && ./rg_setup.sh

# realmB (rf) terminal (start only after RG setup finished)
cd /root/usecases/rg_rf_ri && ./rf_setup.sh

# realmC (ri) terminal (start only after RF setup finished)
cd /root/usecases/rg_rf_ri && ./ri_setup.sh
```

2. App phase:
```bash
# realmC (ri) terminal (wait for filtered prompt)
cd /root/usecases/rg_rf_ri && ./ri_app.sh

# realmB (rf) terminal (wait for prompt, then filter->infer->filter-back)
cd /root/usecases/rg_rf_ri && ./rf_app.sh

# realmA (rg) terminal (interactive prompt + final output)
cd /root/usecases/rg_rf_ri && ./rg_app.sh
```

### Run group attestation
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

## Use Case: `agent` - Chatbot Agent and Model

### Host
Login password: `root`.
Run:

```bash
/root/usecases/agent/start_realms.sh
```

This starts:
- `model_chatbot` realm
- `agent_chatbot` realm

### Realms
Usecase folder in disk:

- `/root/usecases/agent`

Scripts are split by role:
- Model realm script (prefault + policy upload + inference loop): `model_chatbot.sh`
- Agent realm script (prefault + policy upload + workload runner): `agent_chatbot.sh`

Recommended execution order:

```bash
# realmA (model_chatbot) terminal (wait for prompt)
cd /root/usecases/agent && ./model_chatbot.sh

# realmB (agent_chatbot) terminal (send workload prompts)
cd /root/usecases/agent && ./agent_chatbot.sh
```

The default workload has 3 prompts and `agent_chatbot.sh` repeats it 3 times,
so the agent sends 9 tasks. `model_chatbot.sh` is configured with
`--max-inferences 9` to match.

### Run group attestation
Inside gateway realm A (`model_chatbot`):

```bash
/root/cca-workload-attestation report
```

On host, inspect policy payloads for this 2-realm group:

```bash
cat /sys/kernel/debug/cca_policies/payload0
cat /sys/kernel/debug/cca_policies/payload1
```

### Notes

- The model side reuses `/root/usecases/rg_rf_ri/model.gguf` and
  `/root/usecases/rg_rf_ri/llama-cli`.
- Agent-to-model prompts and model-to-agent responses use the same single
  ivshmem slot in alternating producer/consumer mode.
- The Python scripts wait on `rw_ivshmem` header counters after each `-P` so
  the next message does not race the peer's consumer.

---

## Quick Checks

- If upload fails with SGT errors, run setup scripts one-by-one before app scripts.
- If parse fails, inspect the exact runtime config under `/root/usecases/.../configs`.
