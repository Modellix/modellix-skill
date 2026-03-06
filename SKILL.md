---
name: Modellix
description: Use when building applications that generate images, videos, or other AI-generated content. Reach for this skill when you need to integrate text-to-image, text-to-video, image-to-image, image-to-video, or video editing models into your application via a unified API.
metadata:
    mintlify-proj: modellix
    version: "1.0"
---

# Modellix Skill

## Product Summary

Modellix is a Model-as-a-Service (MaaS) platform providing unified API access to 100+ AI models for image and video generation. It supports text-to-image, text-to-video, image-to-image, image-to-video, and video editing tasks from providers like Alibaba (Qwen, Wanx), ByteDance (Seedream, Seedance), Kling, and MiniMax. All requests use the same async API pattern: submit a task, receive a `task_id`, then poll for results. The primary documentation is at https://docs.modellix.ai. Key endpoints: `POST /api/v1/{type}/{provider}/{model_id}/async` (submit task) and `GET /api/v1/tasks/{task_id}` (query results). Authentication uses `Authorization: Bearer YOUR_API_KEY` header.

## When to Use

Reach for Modellix when:
- Building applications that generate images from text prompts (text-to-image)
- Creating video content from text descriptions or images (text-to-video, image-to-video)
- Implementing image editing or transformation features (image-to-image)
- Needing to support multiple AI model providers through a single API
- Handling long-running generation tasks that require async polling
- Integrating AI generation into web apps, mobile apps, or backend services
- Comparing model quality/cost across different providers (Alibaba, ByteDance, Kling, MiniMax)

Do not use Modellix for: real-time synchronous generation, models not in their catalog, or tasks requiring immediate results (all operations are async).

## Quick Reference

### API Endpoints

| Operation | Method | Endpoint | Purpose |
|-----------|--------|----------|---------|
| Submit task | POST | `/api/v1/{type}/{provider}/{model_id}/async` | Start generation, get `task_id` |
| Query result | GET | `/api/v1/tasks/{task_id}` | Check status and retrieve results |

### Path Parameters

| Parameter | Values | Example |
|-----------|--------|---------|
| `type` | text-to-image, text-to-video, image-to-image, image-to-video | text-to-image |
| `provider` | alibaba, bytedance, kling, minimax | alibaba |
| `model_id` | Model-specific ID | qwen-image-plus, seedream-4.5-t2i |

### Authentication

```bash
Authorization: Bearer YOUR_API_KEY
```

Get API key from https://modellix.ai/console/api-key (displayed once—save immediately).

### Response Format

**Success (code = 0)**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "status": "pending|success|failed",
    "task_id": "task-abc123",
    "model_id": "qwen-image-plus",
    "duration": 150,
    "result": { "resources": [...] }
  }
}
```

**Error (code = HTTP status)**:
```json
{
  "code": 400,
  "message": "Invalid parameters: parameter 'prompt' is required"
}
```

### Task Statuses

| Status | Meaning | Action |
|--------|---------|--------|
| pending | Task queued or processing | Poll again in 1-5 seconds |
| success | Generation complete | Extract results from `data.result` |
| failed | Generation failed | Check error message, retry or debug |

### Pricing Units

- **Image generation** (x-to-image): USD per image
- **Video generation** (x-to-video): USD per second of video

## Decision Guidance

### When to Use Async vs Stream

| Aspect | Async (POST /async) | Stream (POST /stream) |
|--------|-------------------|----------------------|
| **Use case** | Batch processing, fire-and-forget, long tasks | Real-time progress feedback, UI updates |
| **Response** | Immediate `task_id`, poll later | Server-Sent Events (SSE) stream |
| **Polling** | Manual polling required | Automatic push updates |
| **Model support** | All models | Not all models support streaming |
| **Complexity** | Simpler, stateless | More complex, requires stream handling |

**Decision**: Use async for most cases. Use stream only if you need real-time progress and the model supports it.

### When to Retry vs Fail

| Error Code | Retryable | Strategy |
|------------|-----------|----------|
| 400 | ❌ No | Fix parameters (missing/invalid fields) |
| 401 | ❌ No | Verify API key format and validity |
| 404 | ❌ No | Check task ID exists and hasn't expired (24h limit) |
| 429 | ✅ Yes | Use exponential backoff; check `X-RateLimit-Reset` |
| 500 | ✅ Yes | Retry up to 3 times with exponential backoff |
| 503 | ✅ Yes | Retry with longer backoff; service temporarily down |

## Workflow

### Standard Task Submission and Polling

1. **Prepare request parameters**
   - Identify the task type (text-to-image, image-to-video, etc.)
   - Choose provider and model_id from API reference
   - Validate required parameters (e.g., `prompt` for text-to-image)
   - Prepare optional parameters (size, steps, seed, etc.)

2. **Submit async task**
   ```bash
   curl -X POST https://api.modellix.ai/api/v1/text-to-image/alibaba/qwen-image-plus/async \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"prompt": "A cat in a garden"}'
   ```
   - Extract `task_id` from response
   - Store task_id for later retrieval

3. **Poll for results**
   - Wait 1-5 seconds before first poll
   - Query status: `GET /api/v1/tasks/{task_id}`
   - Check `status` field in response
   - If `pending`, wait and retry
   - If `success`, extract results from `data.result.resources`
   - If `failed`, log error and handle failure

4. **Download/use results**
   - Extract image/video URLs from `resources` array
   - Download or stream content before 24-hour expiration
   - Store results in your system

5. **Handle errors**
   - Parse error code and message
   - Apply retry logic for 429/500/503
   - Log non-retryable errors (400/401/404)
   - Notify user of failures

### Batch Processing Multiple Tasks

1. Submit multiple tasks in quick succession (respect rate limits)
2. Store all `task_id` values in a queue or database
3. Poll all tasks periodically (e.g., every 5 seconds)
4. Process completed tasks as they finish
5. Implement concurrency control (team limit typically 3 concurrent tasks)

## Common Gotchas

- **API key displayed once**: Save immediately after creation. Lost keys require creating a new one.
- **Results expire after 24 hours**: Download or store generated content promptly; URLs become invalid after 24 hours.
- **Async-only by default**: All operations are asynchronous. Polling is required; there is no synchronous endpoint.
- **Rate limiting is team-wide**: All API keys under the same team share rate limits. One key's heavy usage affects others.
- **Concurrent task limit**: Team has a concurrent task limit (typically 3). Submitting too many tasks simultaneously triggers 429 errors.
- **Task ID typos cause 404**: Double-check task IDs when querying; a single character error returns "task not found."
- **Missing Authorization header**: Requests without the header fail with 401. Format must be `Bearer <token>`, not `Basic` or other schemes.
- **Parameter validation is strict**: Required parameters (e.g., `prompt`) must be present. Optional parameters have specific formats (e.g., `size` as "1024*1024").
- **Model availability varies by provider**: Not all models support all features. Check API reference for each model's capabilities.
- **Polling too aggressively wastes quota**: Implement exponential backoff (1s, 2s, 4s) rather than polling every 100ms.

## Verification Checklist

Before submitting work with Modellix integration:

- [ ] API key is stored securely (environment variable, not hardcoded)
- [ ] Authorization header format is correct: `Authorization: Bearer YOUR_API_KEY`
- [ ] Request parameters match the model's requirements (check API reference)
- [ ] Task submission returns a valid `task_id` (not an error)
- [ ] Polling logic handles all three statuses: pending, success, failed
- [ ] Error handling distinguishes retryable (429/500/503) from non-retryable (400/401/404) errors
- [ ] Exponential backoff is implemented for retries (not fixed intervals)
- [ ] Results are downloaded/stored before 24-hour expiration
- [ ] Rate limit headers (`X-RateLimit-Remaining`, `X-RateLimit-Reset`) are monitored
- [ ] Concurrent task limit is respected (implement semaphore or queue)
- [ ] Timeout is set appropriately (30-60s for images, 60-120s for videos)
- [ ] Error messages are logged with full context (request, response, timestamp)

## Resources

- **Comprehensive navigation**: https://docs.modellix.ai/llms.txt — lists all pages and sections
- **API Usage Guide**: https://docs.modellix.ai/ways-to-use/api — step-by-step task submission and polling
- **Error Handling Reference**: https://docs.modellix.ai/ways-to-use/error-handling — error codes, retry strategies, and best practices
- **Model API Reference**: https://docs.modellix.ai/api-reference/introduction — all available models and their parameters

---

> For additional documentation and navigation, see: https://docs.modellix.ai/llms.txt