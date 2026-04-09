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

## Preflight and Deterministic Execution

Use bundled scripts before ad-hoc commands:

1. `scripts/preflight.py`
   - Validates CLI availability and API key presence.
   - Returns recommended mode (`cli` or `rest`).
2. `scripts/invoke_and_poll.py`
   - Executes CLI-first with REST fallback support.
   - Handles exponential backoff polling and retryable submit errors.
   - Emits normalized JSON result output.

Quick commands:

```powershell
python scripts/preflight.py --json
python scripts/invoke_and_poll.py --model-slug bytedance/seedream-4.5-t2i --body '{"prompt":"A cinematic portrait of a fox in a misty forest at sunrise"}'
```

## Core Workflow

### 1) Obtain API key

- Create key in [Modellix Console](https://modellix.ai/console/api-key)
- Save immediately (shown once)
- Store as `MODELLIX_API_KEY`

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
