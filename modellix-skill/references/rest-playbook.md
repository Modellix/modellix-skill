# REST Playbook

Use this reference when CLI is unavailable, unsuitable, or missing required capability.

## Base URL

`https://api.modellix.ai/api/v1`

## Auth

Header:

```http
Authorization: Bearer <MODELLIX_API_KEY>
```

## Core Endpoint Flow

1) Submit async task:

```http
POST /{type}/{provider}/{model_id}/async
```

2) Poll task:

```http
GET /tasks/{task_id}
```

## cURL Example

Submit:

```bash
curl -X POST "https://api.modellix.ai/api/v1/text-to-image/alibaba/qwen-image-plus/async" \
  -H "Authorization: Bearer $MODELLIX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"prompt":"A cute cat playing in a garden on a sunny day"}'
```

Poll:

```bash
curl -X GET "https://api.modellix.ai/api/v1/tasks/<task_id>" \
  -H "Authorization: Bearer $MODELLIX_API_KEY"
```

## Status Model

- `pending`: still processing, continue polling
- `success`: read output from `data.result.resources`
- `failed`: inspect error payload

## Retry Policy

Retryable:
- `429` (too many requests)
- `500` (internal server error)
- `503` (service unavailable)

Strategy:
- Exponential backoff (`1s -> 2s -> 4s`)
- Max 3 retries for `500`/`503`
- Respect `X-RateLimit-Reset` for `429` when available

Non-retryable:
- `400`, `401`, `402`, `404`

## Notes

- Task outputs expire after 24 hours.
- Parameter shapes vary per model; always verify model docs before invocation.
