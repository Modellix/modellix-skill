---
name: modellix
description: Integrate Modellix's unified API for AI image and video generation into applications. Use this skill whenever the user wants to generate images from text, create videos from text or images, edit images, do virtual try-on, or call any Modellix model API. Also trigger when the user mentions Modellix, model-as-a-service for media generation, or needs to work with providers like Qwen, Wan, Seedream, Seedance, Kling, Hailuo, or MiniMax through a unified API.
metadata:
    mintlify-proj: modellix
    version: "2.0"
    primaryEnv: MODELLIX_API_KEY
    requiredEnv:
      - MODELLIX_API_KEY
---

# Modellix Skill

Modellix is a Model-as-a-Service (MaaS) platform with async image/video generation APIs. The invariant flow is: submit task -> get `task_id` -> poll until `success` or `failed`.

## Execution Policy (CLI-first)

Always choose execution path in this order:

1. Use **CLI** when `modellix-cli` is available and authenticated.
2. Fall back to **REST** when CLI is unavailable, unsuitable, or missing capability.
3. Prefer machine-readable outputs (`--json`) in CLI flows.

## API Key Lifecycle Policy

Always handle `MODELLIX_API_KEY` with this lifecycle: `discover -> request -> persist`.

### 1) Discover existing key first

Before asking the user for credentials, check in this order:

1. System/user environment variable `MODELLIX_API_KEY`.
2. Agent-specific local config for the currently active coding agent.
3. If both are unavailable, treat as first-use and request key from user.

Never ask for a key again when a valid key is already discoverable.

### 2) Request key only when missing

If no usable key is found:

- Ask user to provide a Modellix API key.
- Do not print or echo key values in logs/output.
- Use the key only for current authentication flow, then persist it immediately.

### 3) Persist key for future sessions

Persist in this priority:

1. Preferred: write `MODELLIX_API_KEY` to persistent system/user environment settings.
2. Fallback: write to the current coding agent's local configuration file if env persistence is blocked.

Use local-machine storage only and least-privilege file permissions.

### 4) Replace key when user provides a new one

If the user provides a new API key, treat it as a key rotation event:

1. Replace existing stored value in the primary location (persistent env var if available).
2. Update fallback agent config value as well when that location is in use.
3. Do not keep old and new keys active in parallel in this skill workflow.
4. Re-run `scripts/preflight.py --json` after replacement and continue only if the new key is valid.

When replacement fails validation, keep the flow blocked, report the validation failure, and request a corrected key.

### Agent-specific fallback locations (examples)

When environment-variable persistence is not allowed, store the key in the active agent's native config location using that agent's secret/config mechanism.

- Claude Code: agent config/credentials file for local API keys.
- Codex/Cursor/OpenCode/OpenClaw/Gemini CLI/Qwen CLI/CodeBuddy: corresponding local config file used by that tool for persistent secrets.

Do not hardcode one universal path in this skill. Detect current agent and OS first; if the path is unclear, ask the user to confirm the target config file before writing.

## Preflight and Deterministic Execution

Use bundled scripts before ad-hoc commands:

1. `scripts/preflight.py`
   - Validates CLI availability and API key presence.
   - Returns recommended mode (`cli` or `rest`).
2. `scripts/invoke_and_poll.py`
   - Executes CLI-first with REST fallback support.
   - Handles exponential backoff polling and retryable submit errors.
   - Emits normalized JSON result output.

When preflight reports missing credentials, apply the lifecycle policy above:

1. Try discover flow (env -> agent config).
2. Request key from user only if still missing.
3. Persist key before retrying preflight/invocation.

Quick commands:

```powershell
python scripts/preflight.py --json
python scripts/invoke_and_poll.py --model-slug bytedance/seedream-4.5-t2i --body '{"prompt":"A cinematic portrait of a fox in a misty forest at sunrise"}'
```

## Core Workflow

### 1) Discover or request API key

- Run key discovery first (environment variable, then active agent config).
- If not found, ask user for key created in [Modellix Console](https://modellix.ai/console/api-key).
- Persist the key immediately after receiving it:
  - Preferred: `MODELLIX_API_KEY` in persistent environment settings.
  - Fallback: current coding agent's config file.
- If user provides a new key later, replace the existing stored key and re-run preflight validation.
- Retry preflight and continue only after key is discoverable.

### 2) Select model

Read `references/REFERENCE.md` to find model docs and parameters.

### 3) Run invocation and poll

- Preferred: `scripts/invoke_and_poll.py`
- Manual CLI flow: `references/cli-playbook.md`
- Manual REST flow: `references/rest-playbook.md`

### 4) Consume resources

Output media URLs are under `result.resources`. Persist assets promptly; results expire in 24 hours.

## Progressive Reference Routing

Read only what the task needs:

- `references/cli-playbook.md`
  - CLI install/auth/command flow and retry guidance
- `references/rest-playbook.md`
  - REST endpoints, headers, status model, retry policy
- `references/capability-matrix.md`
  - CLI command <-> REST endpoint mapping and fallback rules

## Bundled Assets

- Output schema:
  - `assets/output/task-result.schema.json`

## Credential and Data Egress

- Required credential: `MODELLIX_API_KEY` (this skill does not require any other secret).
- Network egress: sends requests to `https://api.modellix.ai`.
- User payload handling: prompts and user-provided inputs (including media URLs or file-derived content) may be sent to Modellix endpoints during invocation.
- Result handling: generated resource URLs come from Modellix response payloads and should be downloaded before expiry (about 24 hours).
- Secret hygiene:
  - Never expose API keys in terminal output, logs, screenshots, transcripts, or commit content.
  - Mask sensitive values when showing command examples.
  - Prefer local persistent storage only (environment variables first, agent config fallback).

## Error/Retry Policy

Unified non-success codes:

- Non-retryable: `400`, `401`, `402`, `404`
- Retryable: `429`, `500`, `503`

Retry behavior:

- Exponential backoff (`1s -> 2s -> 4s`, capped)
- For `500`/`503`, max 3 retries
- For `429`, respect `X-RateLimit-Reset` if present

## Verification Checklist

- [ ] Preflight executed and mode selected (`cli` or `rest`)
- [ ] API key configured (`MODELLIX_API_KEY` or CLI `--api-key`)
- [ ] Model parameters verified against model doc from `references/REFERENCE.md`
- [ ] Task submit returns `task_id` with success code
- [ ] Polling handles `pending`, `processing`, `success`, `failed`
- [ ] Retry behavior implemented for `429/500/503`
- [ ] Result URLs persisted before 24-hour expiration
- [ ] REST fallback validated when CLI path is unavailable

## Official Docs

- API: https://docs.modellix.ai/ways-to-use/api
- CLI: https://docs.modellix.ai/ways-to-use/cli
- Pricing: https://docs.modellix.ai/get-started/pricing
- Full docs index: https://docs.modellix.ai/llms.txt
