---
name: Modellix
description: Use when building AI-powered applications that need to generate images, videos, or other media. Reach for this skill when you need to integrate text-to-image, image-to-video, video generation, or other AI model APIs into applications, or when debugging API integration issues.
metadata:
    mintlify-proj: modellix
    version: "1.0"
---

# Modellix Skill

## Product Summary

Modellix is a Model-as-a-Service (MaaS) platform providing unified API access to 100+ AI models for image generation, video generation, image-to-image, image-to-video, and more. Models include FLUX, Kling, Seedance, Qwen, Wanx, and others. All API calls are asynchronous: submit a task, receive a `task_id`, then poll for results. Access the API at `https://api.modellix.ai/api/v1/`. Authenticate with `Authorization: Bearer YOUR_API_KEY` header. Results are retained for 24 hours. See the primary docs at https://docs.modellix.ai.

## When to Use

Use this skill when:
- Building applications that generate images from text prompts (text-to-image)
- Creating videos from images or text (image-to-video, text-to-video)
- Performing image editing or transformation (image-to-image)
- Integrating multiple AI model providers through a single API
- Debugging API authentication, rate limiting, or task status issues
- Implementing batch processing or long-running generation tasks
- Handling asynchronous task polling and result retrieval
- Selecting between different model versions or providers for quality/cost tradeoffs

## Quick Reference

### API Endpoint Structure
```
POST https://api.modellix.ai/api/v1/{type}/{provider}/{model_id}/async
GET https://api.modellix.ai/api/v1/tasks/{task_id}
```

### Authentication
```bash
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

### Common Request Parameters
| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `prompt` | string | ✅ | Text description of desired output |
| `negative_prompt` | string | ❌ | What to exclude from generation |
| `size` | string | ❌ | Format: `width*height` (e.g., `1024*1024`) |
| `style` | string | ❌ | Style parameter (model-specific) |
| `seed` | integer | ❌ | Random seed for reproducibility |

### Task Status Values
| Status | Meaning |
|--------|---------|
| `pending` | Task queued, waiting to process |
| `processing` | Task actively processing |
| `success` | Task completed, results available |
| `failed` | Task failed, check error details |

### Response Headers (Rate Limiting)
| Header | Description |
|--------|-------------|
| `X-RateLimit-Limit` | Max requests per minute |
| `X-RateLimit-Remaining` | Remaining quota in current window |
| `X-RateLimit-Reset` | Unix timestamp when limit resets |

## Decision Guidance

### When to Use Which Model Type

| Task | Model Type | Example | Notes |
|------|-----------|---------|-------|
| Generate image from text | Text-to-Image (T2I) | "A sunset over mountains" | Fastest, lowest cost |
| Animate a static image | Image-to-Video (I2V) | Upload photo + prompt | Requires reference image |
| Create video from text | Text-to-Video (T2V) | "A person walking in a park" | Longer processing time |
| Edit/modify existing image | Image-to-Image (I2I) | Upload image + edit prompt | Preserves composition |
| Extend image boundaries | Image Expansion | Upload image + direction | Panorama/canvas expansion |

### When to Retry vs. Fail

| Error Code | Retryable? | Action |
|-----------|-----------|--------|
| 400 (Bad Request) | ❌ No | Fix parameters, check format |
| 401 (Unauthorized) | ❌ No | Verify API key and header format |
| 404 (Not Found) | ❌ No | Check task ID exists, not expired |
| 429 (Rate Limited) | ✅ Yes | Use exponential backoff, check headers |
| 500 (Server Error) | ✅ Yes | Retry after 1-4 seconds (max 3 times) |
| 503 (Unavailable) | ✅ Yes | Retry with exponential backoff |

## Workflow

### Standard Image Generation Workflow

1. **Prepare the request**: Compose a clear prompt. Decide on size (e.g., `1024*1024`), style, and any negative prompts.

2. **Submit the task**: POST to the async endpoint with your API key. Capture the `task_id` from the response.

3. **Poll for results**: Query `GET /api/v1/tasks/{task_id}` every 2-5 seconds. Check the `status` field.

4. **Handle status states**:
   - `pending` or `processing`: Continue polling
   - `success`: Extract URLs from `result.resources[].url`
   - `failed`: Log error details and retry or escalate

5. **Download and store**: Retrieve images/videos from CDN URLs before 24-hour expiration.

6. **Verify output**: Check dimensions, format, and quality match expectations.

### Handling Rate Limits

1. **Monitor headers**: Check `X-RateLimit-Remaining` after each request.

2. **Implement backoff**: On 429 error, wait using exponential backoff (1s, 2s, 4s, etc.).

3. **Proactive throttling**: If remaining quota drops below 20% of limit, add 1-second delays between requests.

4. **Concurrent control**: Limit concurrent tasks to team quota (typically 3). Use semaphores or queues to enforce.

## Common Gotchas

- **API key format**: Must be `Authorization: Bearer YOUR_API_KEY`, not `Authorization: YOUR_API_KEY`. Missing `Bearer` causes 401.

- **Results expire after 24 hours**: Download and store generated images/videos immediately. Querying an expired task returns 404.

- **Size format error**: Use `width*height` format (e.g., `1024*1024`), not `1024` or `1024x1024`. Invalid format returns 400.

- **Task ID typos**: A single character error in `task_id` returns 404. Verify the ID matches exactly.

- **Async-only operations**: All model calls are asynchronous. You cannot get results in the initial response; you must poll with the `task_id`.

- **Missing required prompt**: The `prompt` parameter is required for most models. Omitting it returns 400 with "Missing required parameter".

- **Rate limit headers are advisory**: `X-RateLimit-Remaining` shows quota, but the actual limit may vary. Always implement retry logic for 429 errors.

- **Different models, different parameters**: Each model may support different optional parameters (e.g., `motion_brush`, `camera_motion`). Check the specific model's API documentation.

- **Concurrent task limits are team-wide**: All API keys under the same team share the concurrent task quota. One key's tasks count toward the team limit.

## Verification Checklist

Before submitting work with Modellix integration:

- [ ] API key is set and in correct format (`Authorization: Bearer <key>`)
- [ ] Request body uses correct parameter names (check model-specific docs)
- [ ] Size parameter (if used) is in `width*height` format
- [ ] Task polling loop includes exponential backoff for retries
- [ ] Code handles all four task statuses: `pending`, `processing`, `success`, `failed`
- [ ] Results are downloaded/stored before 24-hour expiration window
- [ ] Rate limit headers (`X-RateLimit-*`) are logged or monitored
- [ ] 429 errors trigger backoff; 4xx errors are not retried
- [ ] Error responses are parsed for category and detail (format: `"Category: detail"`)
- [ ] Timeout is set appropriately (30-60s for images, 60-120s for videos)

## Resources

- **Comprehensive page listing**: https://docs.modellix.ai/llms.txt
- **API Usage Guide**: https://docs.modellix.ai/ways-to-use/api
- **Error Handling & Best Practices**: https://docs.modellix.ai/ways-to-use/error-handling
- **Model API Reference**: https://docs.modellix.ai/api-reference/introduction

---

> For additional documentation and navigation, see: https://docs.modellix.ai/llms.txt