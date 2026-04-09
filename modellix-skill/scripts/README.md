# Scripts

These scripts make the Modellix skill executable instead of documentation-only.

## preflight.py

Windows-first environment check for CLI-first routing.

Usage:

```powershell
python scripts/preflight.py
python scripts/preflight.py --json
```

Checks:
- `modellix-cli` availability
- `MODELLIX_API_KEY` availability
- Recommended mode (`cli` or `rest`)

## invoke_and_poll.py

Submit a task and poll until `success` or `failed` with exponential backoff.

Usage:

```bash
python scripts/invoke_and_poll.py \
  --model-slug bytedance/seedream-4.5-t2i \
  --body '{"prompt":"A cinematic portrait of a fox in a misty forest at sunrise"}'
```

Key behavior:
- Mode `auto` (default): use CLI when available, otherwise REST
- Retry submit on `429/500/503` (up to 3 retries)
- Normalize output with task metadata and resources
- `--model-slug` is required in `provider/model` format
