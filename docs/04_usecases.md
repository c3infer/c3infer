# Usecases

Start from a built stack. Refresh Buildroot after changing the realm launchers, then start the host realm and run the selected launcher from its host shell.

## Video

```text
RNET(A) -> ENC(B) -> NUD(C) -> RNET(A)
```

The shared channels are `shm1` between RNET and ENC and `shm2` between ENC and NUD. RNET starts with a local MP4, ENC encodes it, NUD checks it, and RNET transmits the result using UDP.

```bash
# Host realm
/root/usecases/video/start_realms.sh

# RNET
/root/usecases/video/rnet_setup.sh

# ENC
/root/usecases/video/enc_setup.sh
/root/usecases/video/enc_app.sh

# NUD
/root/usecases/video/nud_setup.sh
/root/usecases/video/nud_app.sh

# RNET, after ENC and NUD are waiting
VIDEO_INPUT=/root/usecases/video/tiny.mp4 \
VIDEO_DST=10.0.2.2 \
/root/usecases/video/rnet_app.sh
```

## Agent and RNET

```text
Agent(B) -> RNET(A) -> UDP
         <- acknowledgement
```

The Agent creates a payload and sends it to RNET through the bidirectional `shm1` channel. RNET forwards the payload over UDP and returns a transmission acknowledgement to Agent through the same channel.

```bash
# Host realm
/root/usecases/agent_rnet/start_realms.sh

# RNET
/root/usecases/agent_rnet/rnet_setup.sh
RNET_DST=10.0.2.2 RNET_PORT=5000 \
/root/usecases/agent_rnet/rnet_app.sh

# Agent
/root/usecases/agent_rnet/agent_setup.sh

# Agent, after RNET is waiting
AGENT_PAYLOAD="hello from agent" \
/root/usecases/agent_rnet/agent_app.sh
```

No external UDP receiver is required for completion. Replace `10.0.2.2` with another reachable destination when needed.

## Agent, LLM, and RNET

```text
Agent(B) -> LLM(C) -> Agent(B) -> RNET(A) -> UDP
```

The Agent creates the request. LLM processes it and returns the result to Agent. Agent forwards the result to RNET, which transmits it externally and returns a shared-memory acknowledgement.

```bash
# Host realm
/root/usecases/agent_llm_rnet/start_realms.sh

# RNET
/root/usecases/agent_llm_rnet/rnet_setup.sh
RNET_DST=10.0.2.2 RNET_PORT=5000 \
/root/usecases/agent_llm_rnet/rnet_app.sh

# Agent
/root/usecases/agent_llm_rnet/agent_setup.sh

# LLM
/root/usecases/agent_llm_rnet/llm_setup.sh
/root/usecases/agent_llm_rnet/llm_app.sh

# Agent, after LLM and RNET are waiting
PROMPT_FILE=/root/usecases/agent_llm_rnet/agent_prompt.txt \
/root/usecases/agent_llm_rnet/agent_app.sh
```

## Agent, Guardrails, LLM, and RNET

```text
Agent(B) -> Guardrails(C) -> LLM(D) -> Guardrails(C)
         -> Agent(B) -> RNET(A) -> UDP
```

Guardrails checks the Agent request before LLM processing and checks the LLM result before returning it to Agent. Rejected requests do not reach RNET.

```bash
# Host realm
/root/usecases/agent_guardrails_llm_rnet/start_realms.sh

# RNET
/root/usecases/agent_guardrails_llm_rnet/rnet_setup.sh
RNET_DST=10.0.2.2 RNET_PORT=5000 \
/root/usecases/agent_guardrails_llm_rnet/rnet_app.sh

# Agent
/root/usecases/agent_guardrails_llm_rnet/agent_setup.sh

# Guardrails
/root/usecases/agent_guardrails_llm_rnet/guardrails_setup.sh
/root/usecases/agent_guardrails_llm_rnet/guardrails_app.sh

# LLM
/root/usecases/agent_guardrails_llm_rnet/llm_setup.sh
/root/usecases/agent_guardrails_llm_rnet/llm_app.sh

# Agent, after the downstream realms are waiting
PROMPT_FILE=/root/usecases/agent_guardrails_llm_rnet/agent_prompt.txt \
/root/usecases/agent_guardrails_llm_rnet/agent_app.sh
```

For QEMU user-mode networking, `10.0.2.2` is normally the host-side destination. Otherwise use the reachable IP of the external UDP destination. No external UDP receiver is required for completion; RNET transmits and acknowledges locally through the shared channel.

## Shared-memory mappings

The Agent-LLM-RNET usecase uses:

```text
shm1: Agent 0x18000000000 <-> LLM 0x18000000000
shm2: Agent 0x18004000000 <-> RNET 0x18000000000
```

The Guardrails usecase uses:

```text
shm1: Agent      0x18000000000 <-> Guardrails 0x18000000000
shm2: Guardrails 0x18004000000 <-> LLM       0x18000000000
shm3: Agent      0x18004000000 <-> RNET      0x18000000000
```

All mappings in these bidirectional channels are `RW`. Setup scripts perform prefaulting and upload the corresponding RSI policy before the application scripts are started.
