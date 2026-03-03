---
name: Modellix
description: Use when building AI-powered applications that need to generate images, videos, or other media. Reach for this skill when you need to integrate text-to-image, text-to-video, image-to-image, image-to-video, or video editing capabilities via API. Also use when debugging API integration issues, handling async task workflows, or managing rate limits and error responses.
metadata:
    mintlify-proj: modellix
    version: "1.0"
---

# Modellix Skill

## Product Summary

Modellix is a Model-as-a-Service (MaaS) platform providing unified API access to 100+ AI models for image generation, video generation, image-to-image, image-to-video, video editing, and more. Models include FLUX, Kling, Veo, Seedance, Qwen, Wanx, and others. Access models via REST API at `https://api.modellix.ai/api/v1/` using Bearer token authentication. All model calls are asynchronous—submit a request, receive a `task_id`, then poll for results. Primary documentation: https://docs.modellix.ai

**Key files and endpoints**:
- API Key management: Modellix console at https://modellix.ai/console/api-key
- Async submission: `POST /api/v1/{type}/{provider}/{model_id}/async`
- Task query: `GET /api/v1/tasks/{task_id}`
- Authorization header: `Authorization: Bearer YOUR_API_KEY`

## When to Use

Use Modellix when:
- Building applications that generate images from text prompts (text-to-image)
- Creating video content from text or images (text-to-video, image-to-video)
- Performing image transformations (image-to-image, inpainting, style transfer)
- Editing or processing video content
- Integrating multiple AI model providers through a single API
- You need to handle asynchronous task workflows with polling
- Debugging API integration issues, rate limiting, or task failures
- Implementing error handling for 400/401/404/429/500/503 responses
- Managing concurrent task limits or rate limits across a team

## Quick Reference

### Authentication
```bash
# All requests require Bearer token in Authorization header
Authorization: Bearer YOUR_API_KEY
```

### API Endpoint Structure
```
POST /api/v1/{type}/{provider}/{model_id}/async
```

| Component | Examples |
|-----------|----------|
| `{type}` | `text-to-image`, `text-to-video`, `image-to-image`, `image-to-video` |
| `{provider}` | `alibaba`, `bytedance`, `kling`, `minimax` |
| `{model_id}` | `qwen-image-plus`, `kling-v2.6-t2v`, `seedance-1.5-pro-t2v` |

### Async Workflow
1. **Submit request** → Receive `task_id` immediately (status: `pending`)
2. **Poll for results** → Query `GET /api/v1/tasks/{task_id}` until status is `success` or `failed`
3. **Retrieve output** → Access generated resources in `result.resources` array
4. **Save promptly** → Results retained for 24 hours only

### Response Structure
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "status": "pending|success|failed",
    "task_id": "task-abc123",
    "model_id": "qwen-image-plus",
    "duration": 150,
    "result": {
      "resources": [
        {
          "url": "https://cdn.example.com/images/abc123.png",
          "type": "image",
          "width": 1024,
          "height": 1024,
          "format": "png",
          "role": "primary"
        }
      ]
    }
  }
}
```

### Common Request Parameters
| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `prompt` | string | ✅ | Text description of desired output |
| `size` | string | ❌ | Format: `width*height` (e.g., `1024*1024`) |
| `steps` | integer | ❌ | Generation steps; range varies by model |
| `seed` | integer | ❌ | For reproducible results |
| `image` | base64/URL | ❌ | For image-to-X models; provide base64 or URL |

### Rate Limit Headers
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704067260
```

## Decision Guidance

### When to Use Each Integration Method

| Scenario | Use | Why |
|----------|-----|-----|
| Direct API calls in backend | REST API with curl/requests | Full control, simple integration, no dependencies |
| AI coding assistant integration | MCP (Model Context Protocol) | Seamless documentation search in Cursor/Claude Desktop |
| Agent-powered development | Agent Skill | Automatic task assistance in coding agents |
| One-off testing | curl/Postman | Quick validation without code |

### When to Retry vs. Fail

| Error Code | Retryable? | Action |
|-----------|-----------|--------|
| 400 Bad Request | ❌ No | Fix parameters; check required fields and format |
| 401 Unauthorized | ❌ No | Verify API key format (`Bearer <key>`) and validity |
| 404 Not Found | ❌ No | Check task ID exists; verify model/provider names |
| 429 Too Many Requests | ✅ Yes | Use exponential backoff; check `X-RateLimit-Reset` |
| 500 Server Error | ✅ Yes | Retry up to 3 times with exponential backoff |
| 503 Service Unavailable | ✅ Yes | Retry with longer backoff; provider may be down |

## Workflow

### Typical Task: Generate Image from Text

1. **Prepare request**
   - Identify model: Browse `/api-reference/introduction` for available models
   - Craft prompt: Clear, descriptive text for best results
   - Set optional parameters: size, steps, seed if needed

2. **Submit async request**
   ```bash
   curl -X POST https://api.modellix.ai/api/v1/text-to-image/alibaba/qwen-image-plus/async \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"prompt": "A serene mountain landscape at sunset"}'
   ```

3. **Extract task_id from response**
   - Save the `task_id` from `data.task_id` field
   - Note the `duration` estimate (milliseconds)

4. **Poll for completion**
   ```bash
   curl -X GET https://api.modellix.ai/api/v1/tasks/task-abc123 \
     -H "Authorization: Bearer YOUR_API_KEY"
   ```
   - Check `data.status`: `pending`, `success`, or `failed`
   - Poll every 1-2 seconds for images; every 5-10 seconds for videos
   - Stop when status is `success` or `failed`

5. **Retrieve and save results**
   - Extract image/video URLs from `data.result.resources[].url`
   - Download and store immediately (24-hour retention limit)
   - Log metadata: `submit_time`, `end_time`, `request_id`

6. **Handle errors**
   - If status is `failed`, check error message in response
   - For retryable errors (429, 500, 503), implement exponential backoff
   - For non-retryable errors (400, 401, 404), fix and resubmit

### Typical Task: Debug API Integration

1. **Verify authentication**
   - Confirm API key is set and copied correctly (displayed once only)
   - Check Authorization header format: `Bearer YOUR_API_KEY` (not `Basic` or other schemes)
   - Test with a simple request to confirm 401 vs. other errors

2. **Validate request parameters**
   - Check required fields: `prompt` for text-to-image, `image` for image-to-X
   - Verify parameter format: `size` must be `width*height`, not `1024`
   - Confirm value ranges: `steps` typically 10-50, varies by model

3. **Check rate limits**
   - Read response headers: `X-RateLimit-Remaining`, `X-RateLimit-Reset`
   - If 429 error, wait until `X-RateLimit-Reset` timestamp before retrying
   - Implement client-side concurrency control (max 3 concurrent tasks typical)

4. **Verify task query**
   - Confirm task_id is correct (no typos)
   - Check task hasn't expired (24-hour window)
   - Ensure querying with same API key that submitted task

5. **Review error response**
   - Parse `message` field: format is `"<Category>: <detail>"`
   - Match error code to HTTP status code
   - Log full response for debugging

## Common Gotchas

- **API Key displayed once only**: Save immediately after creation in console. If lost, generate a new key.
- **Bearer token format required**: Use `Authorization: Bearer YOUR_API_KEY`, not `Basic` or missing `Bearer` prefix. Missing or malformed header causes 401.
- **Async workflow mandatory**: All model calls are asynchronous. Never expect results in the initial response. Always poll with task_id.
- **24-hour result retention**: Generated images/videos are deleted after 24 hours. Download and store immediately; don't rely on CDN URLs long-term.
- **Task ID typos cause 404**: Verify task_id exactly matches response. A single character error returns 404 "Resource not found".
- **Rate limits are team-wide**: All API keys under the same team share the same rate limit quota. One key's requests affect others.
- **Concurrent task limits**: Team has a concurrent task limit (typically 3). Submitting too many simultaneous requests triggers 429 "Concurrent limit exceeded".
- **Parameter format errors silent**: Invalid `size` format (e.g., `1024` instead of `1024*1024`) returns 400 "Invalid format", not a helpful message. Always use `width*height`.
- **Model/provider names case-sensitive**: `qwen-image-plus` works; `Qwen-Image-Plus` fails with 404.
- **Polling too aggressively**: Excessive polling counts toward rate limits. Use exponential backoff or longer intervals for video generation.
- **Expired tasks return 404**: If task is older than 24 hours, querying returns 404 even if task_id is correct.
- **No nested error field**: Error responses use `message` field directly, not `data.error`. Parsing `data.error` returns null.
- **500 errors lack detail**: Server errors intentionally omit technical details. Retry or contact support; don't try to parse error message for root cause.

## Verification Checklist

Before submitting work with Modellix integration:

- [ ] **API Key**: Verified key is valid, not expired, and has correct format in Authorization header
- [ ] **Request structure**: Confirmed endpoint URL, HTTP method (POST for submit, GET for query), and Content-Type header
- [ ] **Required parameters**: Checked that `prompt` (text-to-image) or `image` (image-to-X) is present and non-empty
- [ ] **Parameter format**: Validated `size` is `width*height`, `steps` is within range, JSON is valid
- [ ] **Async workflow**: Confirmed code submits request, extracts task_id, and polls for completion (not expecting immediate results)
- [ ] **Error handling**: Implemented retry logic for 429/500/503; non-retry logic for 400/401/404
- [ ] **Rate limit awareness**: Checked response headers for remaining quota; implemented backoff if approaching limit
- [ ] **Result handling**: Confirmed code downloads/stores results within 24 hours, doesn't rely on CDN URLs long-term
- [ ] **Logging**: Added logging for task_id, status transitions, error codes, and full error messages
- [ ] **Testing**: Tested with valid API key, invalid key (401), missing required parameter (400), and non-existent task_id (404)

## Resources

**Comprehensive navigation**: https://docs.modellix.ai/llms.txt — Full page-by-page listing for agent reference.

**Critical documentation**:
1. [How to Use API](https://docs.modellix.ai/ways-to-use/api) — Step-by-step guide for authentication, submission, and result retrieval
2. [Error Handling](https://docs.modellix.ai/ways-to-use/error-handling) — Error codes, retry strategies, rate limiting, and best practices
3. [Model API Reference](https://docs.modellix.ai/api-reference/introduction) — Complete list of available models, providers, and endpoints

**Support**: Email support@modellix.ai or join Discord community at https://discord.gg/N2FbcB2cZT

---

> For additional documentation and navigation, see: https://docs.modellix.ai/llms.txt