# Capability Matrix

Use this matrix to switch between CLI and REST without changing task semantics.

| Capability | CLI | REST | Notes |
| --- | --- | --- | --- |
| List model types | `modellix-cli model types` | N/A in this skill | Use CLI for enum discovery |
| Submit async task | `modellix-cli model invoke --model-type <type> --model-slug <provider/model> --body/--body-file ...` | `POST /api/v1/{type}/{provider}/{model_id}/async` | Script fallback parses `model-slug` into `provider` + `model_id` |
| Poll task status/result | `modellix-cli task get <task_id>` | `GET /api/v1/tasks/{task_id}` | Same status lifecycle |
| API key auth | `MODELLIX_API_KEY` or `--api-key` | `Authorization: Bearer <key>` | Prefer env var for both |

## Slug Mapping

- Canonical CLI identifier: `model-slug` in `provider/model` format.
- REST fallback transformation:
  - Input: `bytedance/seedream-4.5-t2i`
  - Derived path parts: `provider=bytedance`, `model_id=seedream-4.5-t2i`

## Fallback Rules

Use REST when any condition is true:
- `modellix-cli` not installed
- CLI auth unavailable
- CLI command surface does not expose required behavior

Otherwise use CLI-first.
