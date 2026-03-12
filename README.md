# Modellix Agent Skill

An Agent Skill for integrating [Modellix](https://modellix.ai) — a unified Model-as-a-Service (MaaS) platform providing REST API access to 100+ AI models for image and video generation.

## What It Does

This skill guides AI agents through the Modellix API workflow:

1. **Obtain an API Key** — directs users to the Modellix console
2. **Find the Right Model** — searches the bundled model catalog (`references/REFERENCE.md`) and fetches model-specific API docs
3. **Submit Async Tasks** — constructs REST API calls to `POST /api/v1/{type}/{provider}/{model_id}/async`
4. **Poll for Results** — queries task status via `GET /api/v1/tasks/{task_id}` with exponential backoff
5. **Handle Results** — extracts generated content URLs from the response

## Supported Task Types

| Type | Description |
|------|-------------|
| text-to-image | Generate images from text prompts |
| image-to-image | Edit or transform images with text instructions |
| text-to-video | Create videos from text descriptions |
| image-to-video | Convert static images into video sequences |

## Providers

Alibaba (Qwen, Wan, Wanx), ByteDance (Seedream, Seedance, SeedEdit), Kling, MiniMax (Hailuo)

## Project Structure

```
skill/
├── SKILL.md                  # Skill instructions
└── references/
    └── REFERENCE.md          # Model catalog with API doc links
```

## Links

- **Docs**: [docs.modellix.ai](https://docs.modellix.ai)
- **API Guide**: [REST API](https://docs.modellix.ai/ways-to-use/api)
- **Pricing**: [Pricing](https://docs.modellix.ai/get-started/pricing)
- **Support**: [support@modellix.ai](mailto:support@modellix.ai)
- **Community**: [Discord](https://discord.gg/N2FbcB2cZT)
