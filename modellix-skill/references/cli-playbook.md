# CLI Playbook

Use this reference when `modellix-cli` is available and authenticated.

## Install

```bash
npm install -g modellix-cli
modellix-cli --version
```

## Authentication

Preferred:

```bash
export MODELLIX_API_KEY="your_api_key"
```

PowerShell:

```powershell
$env:MODELLIX_API_KEY="your_api_key"
```

Alternative per-command:

```bash
modellix-cli ... --api-key <your_api_key>
```

## Core Command Flow

1) Discover model types:

```bash
modellix-cli model types
modellix-cli model types --json
```

2) Invoke async task:

```bash
modellix-cli model invoke \
  --model-type text-to-image \
  --model-slug bytedance/seedream-4.5-t2i \
  --body '{"prompt":"A cinematic portrait of a fox in a misty forest at sunrise"}'
```

`--model-slug` is required and must use `provider/model` format, for example:
- `bytedance/seedream-4.5-t2i`
- `alibaba/qwen-image-edit`

3) Poll task result:

```bash
modellix-cli task get <task_id>
```

## Polling Guidance

- Start with 1-2s delay
- Use exponential backoff (`1s -> 2s -> 4s`, cap near 10s)
- Stop on `success` or `failed`

## Error Handling

The CLI surfaces API errors directly:
- `400`: invalid request body or parameters
- `401`: invalid/missing API key
- `402`: balance/billing issue
- `404`: invalid task or model slug
- `429`: retry with backoff
- `500`/`503`: retry up to 3 times with backoff

## Platform Notes

- Prefer `--json` output for machine-readable parsing.
- On Windows PowerShell, set env vars with `$env:VAR_NAME="value"`.
