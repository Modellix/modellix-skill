---
name: modellix-skill
description: Documentation and capabilities reference for Modellix
metadata:
    mintlify-proj: modellix
    version: "1.0"
---

## Capabilities

Modellix is a unified Model as a Service (MaaS) platform that provides API access to 100+ AI models covering generative AI tasks. Agents can leverage Modellix to generate images from text, create videos from text or images, edit existing images, translate image text, perform virtual try-ons, and more. The platform supports asynchronous task processing with transparent pricing, detailed logging, and enterprise-grade reliability backed by 15 years of IT service expertise.

## Skills

### Text-to-Image Generation
Generate high-quality images from text prompts using models like Qwen Image, Wan 2.6 T2I, and Seedream series. Models support multiple styles, aspect ratios, and creative parameters.

**Endpoint**: `POST /api/v1/text-to-image/{provider}/{model}/async`

**Example**:
```bash
curl --request POST \
  --url https://api.modellix.ai/api/v1/text-to-image/alibaba/qwen-image-plus/async \
  --header 'Authorization: Bearer <api_key>' \
  --header 'Content-Type: application/json' \
  --data '{"prompt": "A cute cat playing in a garden on a sunny day"}'
```

### Image-to-Image Transformation
Edit and transform existing images using text prompts. Capabilities include image editing, style transfer, object addition/removal, color adjustment, and detail enhancement. Models like Qwen Image Edit Plus and Wan 2.6 Image support precise bilingual text editing and multi-image fusion.

**Endpoint**: `POST /api/v1/image-to-image/{provider}/{model}/async`

### Text-to-Video Generation
Create videos from text descriptions with cinematic quality. Models like Seedance 1.5 Pro and Wan 2.6 T2V support multi-shot narrative capabilities, automatic dubbing, and custom audio file uploads.

**Endpoint**: `POST /api/v1/text-to-video/{provider}/{model}/async`

### Image-to-Video Generation
Convert static images into video sequences with motion and animation. Models like Wan 2.6 I2V and Seedance support rich artistic styles, multi-shot narratives, and audio integration.

**Endpoint**: `POST /api/v1/image-to-video/{provider}/{model}/async`

### Image Editing Operations
Perform specialized image editing tasks including:
- Text editing in images (bilingual Chinese-English support)
- Color adjustment and enhancement
- Style transfer and repaint
- Object addition and removal
- Image outpainting (free extension with rotation and expansion)
- Background generation
- Sketch-to-image conversion

### Virtual Try-On and Fashion
Generate AI virtual try-on effects for clothing and fashion applications. Models like AI Try-On, AI Try-On Plus, and AI Try-On Refiner support garment fitting visualization with secondary refinement for higher fidelity results.

### Image Translation
Translate text within images across 11 languages using Qwen MT Image. Preserves original layout and content information with custom features like terminology definitions and sensitive word filtering.

### Specialized Image Generation
- **Wordart Creation**: Generate artistic text with textures and 3D effects
- **Sketch-to-Image**: Convert sketches into detailed images
- **Background Generation**: Create backgrounds for images
- **Image Outpainting**: Extend images with free expansion in all directions

### Task Management
Query the status and results of asynchronous tasks using task IDs.

**Endpoint**: `GET /api/v1/tasks/{task_id}`

**Response Example**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "status": "success",
    "task_id": "task-abc123",
    "model_id": "qwen-image-plus",
    "duration": 3500,
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

## Workflows

### Basic Image Generation Workflow
1. Register and obtain API key from Modellix console
2. Submit text-to-image request with prompt: `POST /api/v1/text-to-image/alibaba/qwen-image-plus/async`
3. Receive `task_id` in response
4. Poll task status: `GET /api/v1/tasks/{task_id}`
5. Download generated image from result URL when status is "success"
6. Save results within 24 hours (results expire after 24 hours)

### Video Generation with Audio Workflow
1. Prepare text prompt or reference image
2. Submit text-to-video or image-to-video request to Wan 2.6 or Seedance model
3. Optionally specify automatic dubbing or provide custom audio file
4. Query task status until completion
5. Retrieve video from result resources
6. Download and process video content

### Image Editing Workflow
1. Prepare source image and editing instructions
2. Submit image-to-image request with prompt describing desired edits
3. For text editing, use Qwen Image Edit Plus with bilingual support
4. Query task status for completion
5. Retrieve edited image from results
6. Apply secondary refinement if needed using AI Try-On Refiner

### Multi-Step Image Creation Workflow
1. Generate base image using text-to-image
2. Retrieve generated image URL
3. Apply style transfer or editing using image-to-image
4. Optionally extend image using outpainting
5. Apply final refinements
6. Download final result

## Integration

### MCP (Model Context Protocol) Integration
Modellix provides a remote MCP server for documentation search at `https://docs.modellix.ai/mcp`. Compatible with Cursor, Claude Desktop, and other MCP clients. Enables AI applications to search Modellix documentation directly.

**OpenAI Integration Example**:
```python
from openai import OpenAI

client = OpenAI()

resp = client.responses.create(
    model="gpt-4.1",
    tools=[
        {
            "type": "mcp",
            "server_label": "modellix-docs",
            "server_url": "https://docs.modellix.ai/mcp",
            "require_approval": "never",
        },
    ],
    input="Do you have access to the modellix docs mcp server?",
)
```

### Agent Skills Integration
Add Modellix Skill to development projects using:
```bash
npx skills add https://github.com/Modellix/modellix-skill
```

Supports integration with Claude Code, Cursor, Codex, Antigravity, Gemini CLI, OpenCode, and GitHub Copilot.

### API Authentication
All requests require Bearer token authentication:
```bash
Authorization: Bearer <your_api_key>
```

## Context

### Asynchronous Processing Model
All model API calls are asynchronous. Requests return immediately with a `task_id`, and results must be queried separately. This enables efficient handling of long-running generation tasks.

### Pricing Structure
- **Text-to-Image & Image-to-Image**: Charged per image (USD/img)
- **Text-to-Video & Image-to-Video**: Charged per second of video (USD/sec)
- Transparent pricing with granular unit costs for different models and parameters

### Supported Providers
- **Alibaba**: Qwen, Wan, Wanx, WordArt models
- **ByteDance**: Seedance video generation models
- **MiniMax**: Hailuo, MiniMax Image/Video models

### Error Handling
Unified error response format with categorized messages:
- **400**: Bad Request (invalid parameters, missing required fields)
- **401**: Unauthorized (invalid/missing API key)
- **404**: Not Found (task or resource doesn't exist)
- **429**: Rate limit exceeded (team rate limit or concurrent task limit)
- **500**: Internal server error
- **503**: Service unavailable

Rate limit headers provided: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

### Result Retention
Generated results are retained for 24 hours. Agents must download and save results within this timeframe.

### Enterprise Features
- Full-stack request/response logging with timestamps and cost tracking
- Detailed transaction ledger for every API call
- Financial-grade transaction clarity for audit and compliance
- AWS Singapore infrastructure with redundant deployment
- SLA operational standards for high availability
- Support in Mandarin, Cantonese, and English via email and Discord

---

> For additional documentation and navigation, see: https://docs.modellix.ai/llms.txt