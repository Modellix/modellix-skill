# Modellix Agent Skill

Agent skill for integrating [Modellix](https://modellix.ai), a unified Model-as-a-Service (MaaS) platform for image and video generation.

## What This Skill Provides

- CLI-first, REST-fallback workflow for async generation tasks
- Model discovery using bundled `references/REFERENCE.md`
- Task submission + polling guidance (`pending` / `success` / `failed`)
- Retry/error handling for `429`, `500`, `503`
- Credential and egress transparency (`MODELLIX_API_KEY`, outbound calls to `api.modellix.ai`)

## Install

### From GitHub

General:

```bash
npx skills add https://github.com/Modellix/modellix-skill/tree/main/modellix-skill
```

Cursor:

```bash
npx skills add https://github.com/Modellix/modellix-skill/tree/main/modellix-skill --agent cursor
```

Update skills:

```bash
npx skills update
```

### From Smithery

General:

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
```

Update all installed skills:

```bash
clawhub update --all
```

## Credential

This skill requires:

- `MODELLIX_API_KEY` (required)
- Primary credential: `MODELLIX_API_KEY`
- Required env vars: `MODELLIX_API_KEY`
- Registry-facing requirement: package metadata should expose `MODELLIX_API_KEY` as both primary credential and required env var.
- CLI usage policy: default to the two-command flow (`modellix-cli model invoke` and `modellix-cli task get`); use `--help` as assistive fallback, not as trial-and-error.
- If CLI is missing, install is optional (`npm i -g modellix-cli`) and should be done only with explicit user consent; REST fallback is supported.

Create API key at: <https://modellix.ai/console/api-key>

## Supported Task Types

| Type | Description |
| --- | --- |
| `text-to-image` | Generate images from text prompts |
| `image-to-image` | Edit or transform images with text instructions |
| `text-to-video` | Create videos from text descriptions |
| `image-to-video` | Convert static images into video sequences |
| `video-to-video` | Transform existing videos |

## Skill Structure

```text
modellix-skill/
├── SKILL.md
├── skill.json
├── scripts/
├── references/
└── assets/
```

## Links

- Docs: [docs.modellix.ai](https://docs.modellix.ai)
- Agent Skill Guide: [ways-to-use/skill](https://docs.modellix.ai/ways-to-use/skill.md)
- REST API Guide: [ways-to-use/api](https://docs.modellix.ai/ways-to-use/api.md)
- CLI Guide: [ways-to-use/cli](https://docs.modellix.ai/ways-to-use/cli.md)
- Pricing: [get-started/pricing](https://docs.modellix.ai/get-started/pricing)
- Support: [support@modellix.ai](mailto:support@modellix.ai)
- Community: [Discord](https://discord.gg/N2FbcB2cZT)
