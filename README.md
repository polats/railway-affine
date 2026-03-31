# AFFiNE with AI Copilot — Railway Template

Deploy [AFFiNE](https://affine.pro) — the open-source alternative to Notion and Miro — on [Railway](https://railway.com) with one click.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/affine-with-ai-copilot?referralCode=0ASizM&utm_medium=integration&utm_source=template&utm_campaign=generic)

## Services

| Service | Image | Purpose |
|---|---|---|
| **affine** | `ghcr.io/toeverything/affine:stable` | Main application server |
| **postgres** | `pgvector/pgvector:pg16` | PostgreSQL 16 with pgvector extension |
| **redis** | `redis:7-alpine` | Cache, job queues, and websocket coordination |

## How It Works

- All infrastructure variables are pre-configured — just click Deploy
- **PostgreSQL** starts with the pgvector extension (required by AFFiNE for AI/search)
- **Redis** provides caching, job queues, and websocket coordination
- **AFFiNE** runs database migrations on startup, then starts the server
- Services connect via Railway [private networking](https://docs.railway.com/guides/private-networking)

## AI Copilot (Optional)

Set one (or both) API keys to enable AFFiNE's AI features:

| Provider | Env Var | Get a Key |
|---|---|---|
| **NVIDIA NIM** | `NVIDIA_NIM_API_KEY` | [build.nvidia.com](https://build.nvidia.com/) |
| **Google Gemini** | `GOOGLE_GEMINI_API_KEY` | [aistudio.google.com](https://aistudio.google.com/apikey) |

The template auto-generates AFFiNE's `config.json` on startup based on which keys are set. If both are provided, NIM is used as the default text model and Gemini is available as a secondary provider. No API key is required for basic AFFiNE functionality.

## Custom Domain

1. Add a custom domain to the **affine** service in Railway's settings
2. Set `AFFINE_SERVER_HTTPS=true` and `AFFINE_SERVER_HOST=yourdomain.com` in the affine service variables
3. Create a CNAME record pointing to the Railway target domain shown in the dashboard

## Based On

- [AFFiNE Self-Hosting Documentation](https://docs.affine.pro/self-host-affine)
- [AFFiNE GitHub Repository](https://github.com/toeverything/AFFiNE)
