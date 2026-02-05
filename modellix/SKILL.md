---
name: Modellix
description: Documentation and capabilities reference for Modellix
metadata:
    mintlify-proj: modellix
    version: "1.0"
---

## Capabilities

Modellix is a unified API platform that enables agents to access 100+ AI models for generative tasks. Agents can generate images from text, create videos from text or images, edit existing images, and perform specialized tasks like virtual try-on, image outpainting, and text-based image translation. The platform supports asynchronous task processing with full request/response logging and transparent pricing.

## Skills

### Text-to-Image Generation
- Generate images from text prompts using models like Qwen Image Plus, Wanx, Seedream, and Hailuo
- Supports multiple artistic styles and high-quality image generation
- Endpoint: `POST /api/v1/text-to-image/{provider}/{model_id}/async`
- Example: `curl -X POST https://api.modellix.ai/api/v1/text-to-image/alibaba/qwen-image-plus/async -H "Authorization: Bearer YOUR_API_KEY" -d '{"prompt": "A cute cat playing in a garden"}'`

### Text-to-Video Generation
- Create videos from text descriptions with cinematic quality
- Models include Wan 2.6 T2V, Seedance, and Hailuo 02 T2V
- Supports automatic dubbing and custom audio file uploads
- Endpoint: `POST /api/v1/text-to-video/{provider}/{model_id}/async`
- Charged by video duration (USD/sec)

### Image-to-Image Editing
- Edit existing images through text instructions
- Capabilities include style transfer, watermark removal, image expansion, detail enhancement, and object addition/removal
- Models: Wanx 2.1 Image Edit, Qwen Image Edit Plus, Seedream 4.0+ I2I, Seededit 3.0
- Endpoint: `POST /api/v1/image-to-image/{provider}/{model_id}/async`

### Image-to-Video Generation
- Generate videos from image references combined with text prompts
- Supports first-and-last-frame video generation (KF2V models)
- Models: Wan 2.6 I2V, Seedance I2V, Hailuo 02 I2V
- Endpoint: `POST /api/v1/image-to-video/{provider}/{model_id}/async`
- Charged by video duration (USD/sec)

### Specialized Image Tasks
- **Virtual Try-On**: Generate try-on images from portrait and clothing photos (AI Try-On, AI Try-On Plus)
- **Image Outpainting**: Extend images with free expansion and rotation support
- **Image Translation**: Translate text in images across 11 languages while preserving layout
- **WordArt**: Create artistic text with semantic deformation or texture effects
- **Image Parsing**: Segment model and clothing images for preprocessing

### Async Task Management
- Submit tasks and receive immediate task_id response
- Query task status and results using: `GET /api/v1/tasks/{task_id}`
- Task results include resource URLs, metadata, and timing information
- Results retained for 24 hours after completion
- Response includes status (pending/success/failed), duration, and generated resources

### API Authentication & Key Management
- Create, view, and delete API keys through Modellix console
- Authentication via Bearer token: `Authorization: Bearer YOUR_API_KEY`
- API keys displayed only once after creation
- Support for Email OTP, Google, and GitHub authentication

### Rate Limiting & Quotas
- Global limit: 1000 requests/minute
- Per API key limit: 100 requests/minute
- Per model limits subject to provider constraints
- Response headers include: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset
- Concurrent task limits enforced per team

### Error Handling
- Unified error response format with code and message fields
- HTTP status codes: 200 (success), 400 (bad request), 401 (unauthorized), 404 (not found), 429 (rate limit), 500 (server error), 503 (service unavailable)
- Error categories: Invalid parameters, Missing required parameter, Invalid format, Value out of range, Authentication failed, Resource not found, Rate limit exceeded, Concurrent limit exceeded
- Retryable errors: 429, 500, 503 with exponential backoff strategy

### Request/Response Logging
- Complete logging of all API calls including input parameters, output parameters, timestamps, response time, and cost consumption
- Financial-grade transaction ledger system for every user
- Real-time visibility into recharge records and consumption details
- Supports business optimization and audit compliance

## Workflows

### Basic Image Generation Workflow
1. Register and log in to Modellix console
2. Create API key at https://modellix.ai/console/api-key
3. Submit text-to-image request: `POST /api/v1/text-to-image/alibaba/qwen-image-plus/async`
4. Receive task_id in response
5. Poll task status: `GET /api/v1/tasks/{task_id}`
6. Retrieve generated image URL from result when status is "success"
7. Download image before 24-hour expiration

### Video Generation with Custom Audio
1. Prepare text prompt describing desired video
2. Submit text-to-video request with optional audio parameters
3. Receive task_id
4. Monitor task progress via polling or streaming interface
5. Retrieve video URL and metadata when complete
6. Extract video duration for cost calculation (charged per second)

### Image Editing Pipeline
1. Prepare source image and editing instructions
2. Submit image-to-image request with image URL and text prompt
3. Receive task_id
4. Query task status until completion
5. Retrieve edited image from result resources
6. Optionally chain multiple edits by using output as input

### Error Recovery with Retry Logic
1. Attempt API request
2. Check response code
3. If 429: Extract X-RateLimit-Reset header, wait until reset time
4. If 500/503: Apply exponential backoff (1s, 2s, 4s) with max 3 retries
5. If 400/401/404: Fix request parameters and retry
6. Log error details including timestamp, parameters, and error message

## Integration

### MCP (Model Context Protocol) Integration
- Remote MCP server available at: `https://docs.modellix.ai/mcp`
- Compatible with Cursor, Claude Desktop, and other MCP clients
- Search tool for Modellix documentation with filter parameters (version, language, apiReferenceOnly, codeOnly)
- Enables AI applications to search documentation during response generation

### OpenAI Integration
- Use Modellix as remote MCP server with OpenAI models
- Configure MCP tool in OpenAI API calls with server URL and label
- Allows GPT models to access Modellix documentation and capabilities

### Multi-Provider Support
- Alibaba (Qwen, Wanx, Wan models)
- ByteDance (Seedream, Seedance, Seededit)
- MiniMax (Hailuo, Image-01)
- Additional providers continuously added

## Context

### Async Processing Model
All Modellix API calls are asynchronous. Agents must submit a request, receive a task_id, then poll the task status endpoint to retrieve results. This enables handling of long-running generation tasks without blocking connections.

### Pricing Structure
- Text-to-image and image-to-image: Charged per image (USD/img)
- Text-to-video and image-to-video: Charged per second of video (USD/sec)
- Transparent pricing with granular unit costs for different models and parameters
- More competitive rates for select core models compared to official pricing

### Result Retention
Generated results are stored for 24 hours after task completion. Agents must download or save results within this window or they will be permanently deleted.

### Rate Limiting Strategy
Team-level rate limiting applies to all API keys under the same account. Agents should implement client-side concurrency control and monitor X-RateLimit-Remaining header to avoid frequent limit triggers. Exponential backoff is recommended for retryable errors.

### Enterprise Reliability
- AWS Singapore infrastructure with redundant deployment
- 15-year enterprise IT service experience
- Rolling upgrades and strict SLA operational standards
- Support in Mandarin, Cantonese, and English via email and Discord community

---

> For additional documentation and navigation, see: https://docs.modellix.ai/llms.txt