# Modellix Agent Skill

Agent skill for integrating [Modellix](https://modellix.ai), a unified Model-as-a-Service (MaaS) platform for image and video generation.

The published package lives in [`modellix-skill/`](modellix-skill/). Install URLs must point at that subdirectory, not the repo root.

## What this skill provides

- CLI-first workflow: `modellix-cli doctor` → `model run --wait` → `task download`
- REST fallback when the CLI is unavailable
- Default models when the user does not specify one
- Model discovery via `modellix-cli model list` / `model describe`, plus live docs at [llms.txt](https://docs.modellix.ai/llms.txt)
- Retry and error guidance aligned with CLI exit codes and paid-submit safety
- Credential handling for `MODELLIX_API_KEY` and CLI auth profiles

## Requirements

- A Modellix API key from the [Console](https://modellix.ai/console/api-key)
- Recommended: [modellix-cli](https://www.npmjs.com/package/modellix-cli) (Node.js 18.17+)

```bash
npm i -g modellix-cli@latest
modellix-cli doctor --json
```

## Install

### From GitHub

```bash
npx skills add https://github.com/Modellix/modellix-skill/tree/main/modellix-skill
```

Cursor:

```bash
npx skills add https://github.com/Modellix/modellix-skill/tree/main/modellix-skill --agent cursor
```

Update installed skills:

```bash
npx skills update
```

### From Smithery

```bash
npx @smithery/cli@latest skill add modellix/modellix-skill
```

Cursor:

```bash
npx @smithery/cli@latest skill add modellix/modellix-skill --agent cursor
```

### From ClawHub

```bash
clawhub install modellix
clawhub update --all
```

## Credential

| Item | Value |
| --- | --- |
| Primary credential / env | `MODELLIX_API_KEY` |
| Console | https://modellix.ai/console/api-key |

- REST requires `MODELLIX_API_KEY`.
- CLI may use the env var **or** a saved profile (`modellix-cli auth login` / `init`).
- Prefer session-only keys; persist only when the user explicitly asks.
- Never print API keys in logs or commits.

Key resolution order in the CLI: `--api-key` → `MODELLIX_API_KEY` → selected saved profile.

## Quick start (CLI)

```bash
export MODELLIX_API_KEY="your_api_key"

modellix-cli doctor --json

modellix-cli model run \
  --model-slug google/nano-banana-2-lite \
  --body '{"prompt":"A cinematic sunset over a futuristic city skyline"}' \
  --wait --timeout 5m --json

modellix-cli task download <task_id> --output-dir ./outputs --json
```

If `task download` fails with a private/reserved network error (common behind local proxies that map CDN hosts into `198.18.0.0/15`), retry with `--allow-private-network` for trusted Modellix CDN hosts, or download the resource URL with `curl`.

`model invoke` remains a compatibility alias of `model run`. Prefer `model run` in new scripts.

## Default models

Used when the user does **not** name a model:

| Task type | Default model slug |
| --- | --- |
| Text-to-image (T2I) | `google/nano-banana-2-lite` |
| Text-to-video (T2V) | `bytedance/seedance-2.0-mini-t2v` |
| Image editing / I2I | `bytedance/seedream-5.0-lite-edit` |
| Image-to-video / I2V | `bytedance/seedance-2.0-fast-i2v` |
| Video-to-video (V2V) | `bytedance/seedance-2.0-v2v` |

To discover or inspect other models:

```bash
modellix-cli model list --type text-to-image --output slugs
modellix-cli model describe <provider/model> --json
```

Request-body schemas come from each model’s docs (`docs_url` from `model describe`, or links in [llms.txt](https://docs.modellix.ai/llms.txt)).

## Execution guidance

1. Prefer CLI when installed; otherwise use REST ([API guide](https://docs.modellix.ai/ways-to-use/api.md)).
2. Do not hand-roll `task get` polling loops when `model run --wait` or `task wait` is available.
3. Do not blindly retry a paid `model run` after an unknown submission outcome — check `modellix-cli task history` first.
4. Optional helpers in `modellix-skill/scripts/` wrap CLI/REST; if they fail, call the CLI commands directly.
5. CLI behavior source of truth: [npm modellix-cli](https://www.npmjs.com/package/modellix-cli) and `modellix-cli --help` (not the website CLI guide page, which may lag).

## Supported task types

| Type | Description |
| --- | --- |
| `text-to-image` | Generate images from text prompts |
| `image-to-image` | Edit or transform images with text instructions |
| `text-to-video` | Create videos from text descriptions |
| `image-to-video` | Convert static images into video sequences |
| `video-to-video` | Transform existing videos |

## Repository structure

```text
.
├── README.md                 # This file (humans)
├── AGENTS.md                 # Maintainer / coding-agent instructions
├── modellix-skill/           # Published skill package
│   ├── SKILL.md
│   ├── skill.json
│   ├── evals/
│   ├── scripts/
│   ├── references/
│   └── assets/
└── .github/workflows/        # Publish sync (Smithery / skills add)
```

## Maintaining this skill

See [AGENTS.md](AGENTS.md) for sources of truth, update checklists, smoke tests, versioning, and PR conventions.

Current package version: see [`modellix-skill/skill.json`](modellix-skill/skill.json).

## Links

- Product: [modellix.ai](https://modellix.ai)
- Docs: [docs.modellix.ai](https://docs.modellix.ai)
- Models index: [llms.txt](https://docs.modellix.ai/llms.txt)
- Agent skill guide: [ways-to-use/skill](https://docs.modellix.ai/ways-to-use/skill.md)
- REST API: [ways-to-use/api](https://docs.modellix.ai/ways-to-use/api.md)
- CLI package: [npmjs.com/package/modellix-cli](https://www.npmjs.com/package/modellix-cli)
- Pricing: [get-started/pricing](https://docs.modellix.ai/get-started/pricing)
- Support: [support@modellix.ai](mailto:support@modellix.ai)
- Community: [Discord](https://discord.gg/N2FbcB2cZT)
