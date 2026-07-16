# AGENTS.md

Agent instructions for maintaining and updating the **Modellix agent skill** in this repository.

Human-facing overview lives in [README.md](README.md). This file is for coding agents working on the skill package itself.

## Project overview

This repo publishes the Modellix skill consumed by AI coding agents (Cursor, Claude, ClawHub, Smithery, etc.).

| Path | Role |
|------|------|
| [`modellix-skill/`](modellix-skill/) | **Published skill package** (install path / git subtree URL target) |
| [`modellix-skill/SKILL.md`](modellix-skill/SKILL.md) | Skill entrypoint (frontmatter + agent instructions) |
| [`modellix-skill/skill.json`](modellix-skill/skill.json) | Registry metadata (name, version, credentials) |
| [`modellix-skill/references/`](modellix-skill/references/) | Progressive disclosure playbooks (CLI / REST / capability matrix) |
| [`modellix-skill/scripts/`](modellix-skill/scripts/) | Optional Python helpers (thin wrappers around CLI / REST) |
| [`modellix-skill/assets/`](modellix-skill/assets/) | Schemas and other static assets |
| [`modellix-skill/evals/`](modellix-skill/evals/) | Eval prompts for skill-creator style regression |
| [`modellix-workspace/`](modellix-workspace/) | Local eval run artifacts (do not publish; keep out of skill package) |
| [`.agents/skills/skill-creator/`](.agents/skills/skill-creator/) | Local skill-creator tooling (evals, viewer, packaging helpers) |
| [`.github/workflows/skill_update.yml`](.github/workflows/skill_update.yml) | On `main` push: sync Smithery + `npx skills add` |

There is no application runtime, package.json, or test suite for a product app. The “product” is the skill markdown + scripts.

## Sources of truth (do not invent)

When updating CLI usage or model guidance, prefer live sources over memory or stale website pages:

1. **CLI behavior**: [npm `modellix-cli`](https://www.npmjs.com/package/modellix-cli) README and local `modellix-cli --help` / subcommand help.
2. **REST API**: https://docs.modellix.ai/ways-to-use/api.md
3. **Model index**: https://docs.modellix.ai/llms.txt — then fetch each model’s `.md` (or use `modellix-cli model describe <slug> --json` → `docs_url`).
4. **Do not** treat https://docs.modellix.ai/ways-to-use/cli.md as authoritative until it is updated to match the CLI package.
5. **Do not** reintroduce a bundled `references/REFERENCE.md` mirror of `llms.txt` (removed on purpose; it went stale and duplicated CLI/`llms.txt`).

Canonical agent workflow the skill teaches:

```text
doctor → (defaults or model list/describe) → model run --wait → task download
```

`model invoke` is only a compatibility alias of `model run`.

## Language and communication

Per [`.cursor/rules/language-and-communication.mdc`](.cursor/rules/language-and-communication.mdc):

- **English** for all repo artifacts: `SKILL.md`, playbooks, scripts, comments, commit messages, PR text.
- **Chinese** when chatting with the human maintainer (explanations, progress, questions).

## Setup for maintainers / agents

Optional but recommended when validating CLI changes:

```bash
npm i -g modellix-cli@latest
modellix-cli --version
export MODELLIX_API_KEY="..."   # session only; never commit
modellix-cli doctor --json
```

Python helpers need a normal Python 3 interpreter (stdlib only; no pip deps required for `preflight.py` / `invoke_and_poll.py`).

```bash
python3 modellix-skill/scripts/preflight.py --json
python3 modellix-skill/scripts/clean_build_artifacts.py
```

## Skill package layout rules

Keep progressive disclosure tight:

- **`SKILL.md`**: policies, defaults, short examples, routing pointers. Prefer staying under ~500 lines.
- **`references/cli-playbook.md`**: full CLI command surface (auth, doctor, list/describe, run/wait/download, batch, recovery).
- **`references/rest-playbook.md`**: REST submit/poll only when CLI is unavailable.
- **`references/capability-matrix.md`**: CLI ↔ REST mapping and fallback rules.
- **`scripts/`**: optional; must not block the direct CLI path. Prefer wrapping native CLI (`doctor`, `model run --wait`, `task download`) over reinventing polling.

Install URLs always point at the **subdirectory**:

```text
https://github.com/Modellix/modellix-skill/tree/main/modellix-skill
```

## Default models policy

When the end user does not name a model, the skill must use these defaults (update the table in `SKILL.md` and keep examples/evals in sync):

| Task | Default slug |
|------|----------------|
| T2I | `google/nano-banana-2-lite` |
| T2V | `bytedance/seedance-2.0-mini-t2v` |
| I2I | `bytedance/seedream-5.0-lite-edit` |
| I2V | `bytedance/seedance-2.0-fast-i2v` |
| V2V | `bytedance/seedance-2.0-v2v` |

Verify slugs against OpenAPI / `model describe` (never invent from doc filenames). Changing defaults is a behavior change: bump `skill.json` version and update evals.

## How to update the skill (checklist)

### A) CLI package changed (new flags/commands)

1. Diff npm README / `modellix-cli --help` against `references/cli-playbook.md` and `SKILL.md` Execution Policy.
2. Update `capability-matrix.md` for new CLI-only capabilities.
3. Keep scripts aligned (`preflight.py` → `doctor`; `invoke_and_poll.py` → `model run --wait`, no paid-submit auto-retry).
4. Note paid-submit safety: unknown outcomes → `task history`, do not blind re-POST.
5. Note download quirk: if `task download` fails with private/reserved network (proxy DNS e.g. `198.18.0.0/15` for `file.modellix.ai`), document `--allow-private-network` or curl fallback for trusted Modellix CDN hosts.

### B) Default models or routing changed

1. Edit Default Models in `SKILL.md`.
2. Update examples in `SKILL.md` / playbooks / `scripts/README.md` / root `README.md`.
3. Update [`modellix-skill/evals/evals.json`](modellix-skill/evals/evals.json) assertions.
4. Bump [`modellix-skill/skill.json`](modellix-skill/skill.json) `version` (semver: patch for docs/typos, minor for workflow/default changes, major for breaking skill contract).

### C) REST-only or schema guidance

1. Prefer linking to live model docs via `llms.txt` / `docs_url`.
2. Update `rest-playbook.md` only for shared REST semantics (auth, poll statuses, retry).

### D) Before finishing an edit

- [ ] No secrets (`MODELLIX_API_KEY`, profiles) in files or examples that echo real keys.
- [ ] No reintroduction of `REFERENCE.md` or the deleted `sync_ref_mint_llmstxt` workflow.
- [ ] Root README install/credential/execution sections still match `SKILL.md`.
- [ ] `python3 -m py_compile modellix-skill/scripts/*.py`
- [ ] `python3 modellix-skill/scripts/clean_build_artifacts.py`

## Testing / evals

There is no unit-test runner. Validate with:

1. **CLI smoke** (needs key + balance):

```bash
modellix-cli doctor --json
modellix-cli model run \
  --model-slug google/nano-banana-2-lite \
  --body '{"prompt":"smoke test"}' \
  --wait --timeout 5m --json
# if download fails on private network:
modellix-cli task download <task_id> --output-dir ./tmp-out --json --allow-private-network
```

2. **Script smoke**:

```bash
python3 modellix-skill/scripts/preflight.py --json
```

3. **Skill-creator evals** (optional, uses [`.agents/skills/skill-creator/`](.agents/skills/skill-creator/)):

- Prompts/assertions: `modellix-skill/evals/evals.json`
- Store runs under `modellix-workspace/iteration-N/` (sibling of the skill dir)
- Prefer with_skill vs without_skill comparisons for default-model and CLI-flow regressions
- Viewer: `python3 .agents/skills/skill-creator/eval-viewer/generate_review.py modellix-workspace/iteration-N --skill-name modellix --static modellix-workspace/iteration-N/review.html`

Do not commit API keys. Prefer session env or `/tmp` env files with mode `600`, then delete.

## Code style

- Markdown: clear imperative instructions; explain *why* for non-obvious rules; avoid ALL-CAPS MUST spam.
- Python: stdlib only, cross-platform, type hints welcome; fail with stderr + non-zero exit.
- Examples: prefer `--json` / machine-readable output; redact secrets as `<MODELLIX_API_KEY>` or omit.
- Keep skill triggering description in frontmatter “pushy” enough to fire on Modellix / generation tasks, but accurate.

## Security

- Never commit credentials, `.env`, or profile files with keys.
- Skill must default to session-only credentials; persistent write only on explicit user request (`auth login` / `init` preferred over writing other agents’ configs).
- Do not log or print API keys in transcripts, eval outputs, or README examples.
- Network egress for the skill is Modellix API / CDN / docs (`api.modellix.ai`, `file.modellix.ai`, `docs.modellix.ai`).

## CI / publish

On push to `main`, [`skill_update.yml`](.github/workflows/skill_update.yml):

1. `PUT` Smithery skill `modellix/modellix-skill` with git URL of `modellix-skill/` (requires `SMITHERY_TOKEN` secret).
2. After 60s, runs `npx skills add https://github.com/Modellix/modellix-skill/tree/main/modellix-skill`.

Agents editing the skill do not need to trigger publish manually; merging to `main` does.

## Pull requests and commits

- Commit / PR language: **English**.
- Prefer focused commits: skill behavior vs docs-only vs scripts.
- Suggested title patterns:
  - `feat(skill): ...` — new CLI capability or workflow
  - `fix(skill): ...` — incorrect defaults, flags, or safety
  - `docs(skill): ...` — playbook/README clarity
  - `chore(skill): bump version to x.y.z`
- Before merge: run the relevant smoke checks above; ensure version bump if behavior changes.

## Common gotchas

- Website CLI docs may lag the npm CLI — trust npm/`--help`.
- `task download` may need `--allow-private-network` on machines whose DNS maps CDN hosts into proxy ranges (`198.18.0.0/15`).
- Paid `model run` must not be auto-retried on ambiguous/unknown submission outcomes.
- Filename ≠ model slug (e.g. docs path `seedance-2-0-mini-t2v.md` vs slug `bytedance/seedance-2.0-mini-t2v`).
- Publish path is `modellix-skill/`, not the repo root.

## Quick file map for edits

| Change type | Touch first |
|-------------|-------------|
| Default models | `SKILL.md`, examples, `evals/evals.json`, `skill.json` version |
| CLI workflow | `SKILL.md`, `references/cli-playbook.md`, `capability-matrix.md`, scripts |
| REST fallback | `references/rest-playbook.md`, `capability-matrix.md` |
| Install / registry copy | root `README.md`, `skill.json` |
| Eval prompts | `modellix-skill/evals/evals.json` |

## Listing the skill in external skill directories (PRs)

After meaningful skill updates land on `main`, optionally refresh or open listing PRs in community “awesome skills” repos. All PR titles/bodies and commits for those repos must be **English**.

### Canonical links (keep consistent)

| Purpose | URL |
|---------|-----|
| Skill package (install / PR source) | `https://github.com/Modellix/modellix-skill/tree/main/modellix-skill` |
| Repo root / human README | `https://github.com/Modellix/modellix-skill` |
| ClawHub listing | `https://clawhub.ai/modellix/modellix` |
| Docs index | `https://docs.modellix.ai/llms.txt` |
| CLI package | `https://www.npmjs.com/package/modellix-cli` |

Suggested short description (≤10 words where required):

```text
Unified API for AI image and video generation
```

### Preconditions

1. Push the updated skill to `origin/main` first (listings must point at a public tip).
2. Authenticate GitHub CLI (`gh auth login` or `GH_TOKEN` / git credential with `repo` scope).
3. Prefer a dedicated workdir outside this repo (e.g. `~/Developer/modellix-skill-prs/`). Large awesome repos often fail full clones — use **sparse / shallow** clones or the **Contents API** (see sickn33 below).
4. Branch name convention: `add-modellix-skill`.
5. Fork under the submitting GitHub user, push the branch, open PR with `--head <user>:add-modellix-skill`.

Shared sparse-prep pattern:

```bash
export GH_TOKEN=...   # or rely on gh auth
WORKDIR=~/Developer/modellix-skill-prs
mkdir -p "$WORKDIR" && cd "$WORKDIR"

prep() {
  local upstream="$1" dir="$2" fork_repo="$3"  # fork_repo = name under your user
  shift 3
  gh repo fork "$upstream" --clone=false --default-branch-only || true
  local default_branch
  default_branch=$(gh repo view "$upstream" --json defaultBranchRef -q .defaultBranchRef.name)
  rm -rf "$dir"
  git clone --filter=blob:none --sparse --depth 1 --single-branch \
    --branch "$default_branch" "https://github.com/$upstream.git" "$dir"
  cd "$dir"
  git sparse-checkout set --no-cone "$@"
  git remote rename origin upstream
  git remote add origin "https://github.com/<YOUR_USER>/${fork_repo}.git"
  git checkout -b add-modellix-skill
  cd ..
}
```

Retry `git push` / `gh pr create` on HTTP/2 EOF (use `GIT_HTTP_VERSION=HTTP/1.1` if needed).

### Target repos and how to contribute

#### 1) [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills)

- **Type**: link-only curated list (skill stays in Modellix repo).
- **Where**: Community Skills → Development and Testing (or a future “Skills by Modellix” official section if maintainers prefer).
- **Entry format**:

```markdown
- **[Modellix/modellix](https://github.com/Modellix/modellix-skill/tree/main/modellix-skill)** - Unified API for AI image and video generation
```

- **Rules**: description ≤10 words; public repo + SKILL.md; they may reject brand-new / unused skills.
- **PR title**: `Add skill: Modellix/modellix`
- **Edit**: `README.md` only (append near end of the chosen community subsection).
- **Example PR**: https://github.com/VoltAgent/awesome-agent-skills/pull/801

#### 2) [VoltAgent/awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills)

- **Type**: ClawHub link list only.
- **Requirement**: skill must already be published on [ClawHub](https://clawhub.ai/modellix/modellix) with clean security status. Do **not** use `clawskills.sh` URLs in the PR (CONTRIBUTING forbids them); use `https://clawhub.ai/modellix/modellix`.
- **Where**: Image & Video Generation.
- **Entry format**:

```markdown
- [modellix](https://clawhub.ai/modellix/modellix) - Unified API for AI image and video generation.
```

- **Edit**:
  1. `README.md` — Image & Video Generation `<details>` block (before the “View all …” link).
  2. `categories/image-and-video-generation.md` — insert alphabetically (e.g. after `moonfunsdk`).
- **PR title**: `Add skill: modellix/modellix`
- **PR body**: include the ClawHub URL.
- **Example PR**: https://github.com/VoltAgent/awesome-openclaw-skills/pull/536

#### 3) [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills)

- **Type**: README link (optional local `skill-name/SKILL.md` folder; external GitHub link is accepted).
- **Where**: Creative & Media, alphabetical by display name.
- **Entry format**:

```markdown
- [Modellix](https://github.com/Modellix/modellix-skill/tree/main/modellix-skill) - Generate images and videos via Modellix's unified model API and CLI. *By [Modellix](https://modellix.ai)*
```

- **PR title**: `Add Modellix skill`
- **PR body**: problem solved, audience, source URL, short usage example (per their CONTRIBUTING).
- **Edit**: `README.md` under `### Creative & Media`.
- **Example PR**: https://github.com/ComposioHQ/awesome-claude-skills/pull/1355

#### 4) [sickn33/agentic-awesome-skills](https://github.com/sickn33/agentic-awesome-skills)

- **Type**: vendored `skills/<name>/SKILL.md` in their repo (catalog is auto-generated — **do not** edit `CATALOG.md` / `data/*.json`).
- **Where**: add only `skills/modellix/SKILL.md`.
- **Frontmatter** (folder name must match `name`):

```yaml
---
name: modellix
description: "Integrate Modellix unified API/CLI for async AI image and video generation (model run --wait, task download)."
category: creative
risk: safe
source: community
source_repo: Modellix/modellix-skill
source_type: official
date_added: "YYYY-MM-DD"
author: Modellix
tags: [image-generation, video-generation, modellix, cli, api]
tools: [claude, cursor, gemini]
license: "MIT"
license_source: "https://github.com/Modellix/modellix-skill/blob/main/LICENSE"
---
```

Body: short Overview / When to Use / How It Works / Examples pointing at the upstream package (keep lean; full instructions live upstream).

- **Validate** (if clone works): `npm install && npm run validate`
- **PR title**: `feat: add modellix for AI image and video generation`
- **API fallback** when clone fails (create branch + file on the fork, then PR):

```bash
DEFAULT=$(gh repo view sickn33/agentic-awesome-skills --json defaultBranchRef -q .defaultBranchRef.name)
BASE_SHA=$(gh api repos/sickn33/agentic-awesome-skills/git/ref/heads/$DEFAULT --jq .object.sha)
gh api --method POST repos/<YOUR_USER>/agentic-awesome-skills/git/refs \
  -f ref=refs/heads/add-modellix-skill -f sha="$BASE_SHA"
# PUT skills/modellix/SKILL.md with base64 content on branch add-modellix-skill
gh api --method PUT repos/<YOUR_USER>/agentic-awesome-skills/contents/skills/modellix/SKILL.md \
  -f message='feat: add modellix for AI image and video generation' \
  -f content="$(base64 < SKILL.md | tr -d '\n')" \
  -f branch=add-modellix-skill
gh pr create --repo sickn33/agentic-awesome-skills \
  --head '<YOUR_USER>:add-modellix-skill' \
  --title 'feat: add modellix for AI image and video generation' \
  --body '...'
```

- **Example PR**: https://github.com/sickn33/agentic-awesome-skills/pull/867

#### 5) [anthropics/skills](https://github.com/anthropics/skills)

- **Not a community skill dump.** Do **not** add folders under `./skills/`.
- Optional ask: add a **Partner Skills** README bullet (same style as Notion), link only:

```markdown
- **Modellix** - [Modellix Skill for AI image and video generation](https://github.com/Modellix/modellix-skill/tree/main/modellix-skill)
```

- **PR title**: `Add Modellix to Partner Skills`
- Expect curation; maintainers may decline. Sparse-checkout carefully — only stage `README.md` (avoid deleting unchecked files like `THIRD_PARTY_NOTICES.md`).
- **Example PR**: https://github.com/anthropics/skills/pull/1445

### Update vs first submit

| Situation | Action |
|-----------|--------|
| First time | Open PRs as above (skip any already merged). |
| Skill description / install URL changed | Comment on open PRs or open follow-up PRs editing the same README / `SKILL.md` lines. |
| ClawHub slug/author changed | Update openclaw entry + AGENTS.md canonical links together. |
| Already merged, no listing text change | No directory PR needed; `main` push + Smithery workflow is enough. |

### After opening PRs

- Record URLs in the PR conversation with the maintainer (Chinese chat OK).
- Watch CI on sickn33 (`skill-review` / validate).
- If VoltAgent asks for “community usage”, point at ClawHub installs / Smithery / public repo activity.
