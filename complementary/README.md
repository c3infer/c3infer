# Running attestation token RSI

```bash
cca-workload-attestation report
```

# Inspecting policies

```bash
cat /sys/kernel/debug/cca_policies/payload0 #or payload1, payload2, etc.. if more than one realm in group
```

# Running RSI (if BLOCKED, fails)

```bash
echo 1 > /dev/set_range
```
