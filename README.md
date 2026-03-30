# AFFiNE Railway Template

Deploy [AFFiNE](https://affine.pro) — the open-source alternative to Notion and Miro — on [Railway](https://railway.com) with one click.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/jp52av)

## Services

This template deploys three services:

| Service | Image | Purpose |
|---|---|---|
| **affine** | `ghcr.io/toeverything/affine:stable` | Main application server |
| **postgres** | `pgvector/pgvector:pg16` | PostgreSQL 16 with pgvector extension |
| **redis** | `redis:7-alpine` | Cache, job queues, and websocket coordination |

## How It Works

- **PostgreSQL** starts first with the pgvector extension (required by AFFiNE for AI/search features)
- **Redis** starts alongside PostgreSQL
- **AFFiNE** runs database migrations on startup before the main server (via custom `startCommand`)
- Services connect via Railway [private networking](https://docs.railway.com/guides/private-networking) (no egress fees)

## Environment Variables

### Required (set in the affine service)

| Variable | Description |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string — e.g., `postgresql://affine:PASSWORD@postgres.NETWORK_NAME.internal:5432/affine` |
| `REDIS_SERVER_HOST` | Redis hostname — e.g., `redis.NETWORK_NAME.internal` |
| `REDIS_SERVER_PORT` | Redis port — `6379` |

### Required (set in the postgres service)

| Variable | Description |
|---|---|
| `POSTGRES_PASSWORD` | Database password — use `${{secret(32)}}` to auto-generate |

### Optional (set in the affine service)

| Variable | Default | Description |
|---|---|---|
| `NVIDIA_NIM_API_KEY` | — | NVIDIA NIM API key — enables AI Copilot. Get one at [build.nvidia.com](https://build.nvidia.com/) |
| `NVIDIA_NIM_MODEL` | `moonshotai/kimi-k2.5` | NIM model. See [available models](https://build.nvidia.com/models) |
| `GOOGLE_GEMINI_API_KEY` | — | Google Gemini API key — enables AI Copilot. Get one at [aistudio.google.com](https://aistudio.google.com/apikey) |
| `GOOGLE_GEMINI_MODEL` | `gemini-2.5-flash` | Gemini model |
| `CLOUDFLARE_TOKEN` | — | Cloudflare API token (Zone:DNS:Edit) — auto-creates CNAME for your custom domain |
| `CLOUDFLARE_DOMAIN` | — | Custom domain (e.g., `affine.yourdomain.com`) — used with `CLOUDFLARE_TOKEN` |
| `AFFINE_SERVER_HTTPS` | `false` | Set `true` when using a custom domain with SSL |
| `AFFINE_SERVER_HOST` | `localhost` | Your domain (e.g., `affine.yourdomain.com`) |
| `AFFINE_SERVER_EXTERNAL_URL` | — | Full base URL (alternative to host + https) |
| `AFFINE_INDEXER_ENABLED` | `false` | Enable full-text search indexer |

## Setup Instructions

### Option 1: One-Click Deploy

1. Click the **Deploy on Railway** button above
2. Railway will prompt you to configure variables — the template pre-fills sensible defaults
3. Wait for all services to deploy and pass health checks
4. Access AFFiNE via the generated Railway domain

### Option 2: Manual Setup

1. Create a new project on Railway
2. Add three services from this repo, each pointing to its subdirectory:
   - `postgres/` — root directory for the PostgreSQL service
   - `redis/` — root directory for the Redis service
   - `affine/` — root directory for the AFFiNE service
3. Configure environment variables as described above, using Railway's `${{service.VAR}}` reference syntax
4. Create a **private network** in the project and add all three services to it
5. Set `DATABASE_URL` and `REDIS_SERVER_HOST` using the private network DNS names (`*.NETWORK_NAME.internal`)
6. Add a volume to the **postgres** service mounted at `/var/lib/postgresql/data` (NOT at the pgdata subdirectory — PostgreSQL creates the subdirectory itself)
7. Add a volume to the **affine** service mounted at `/root/.affine`
8. Enable public networking on the **affine** service (generates a `*.up.railway.app` domain)
9. Deploy

### Custom Domain (Cloudflare)

To use a custom domain with automatic DNS setup:

1. Set `CLOUDFLARE_TOKEN` to a Cloudflare API token with DNS edit permissions
2. Set `CLOUDFLARE_DOMAIN` to your desired domain (e.g., `affine.yourdomain.com`)
3. Set `AFFINE_SERVER_HTTPS=true` and `AFFINE_SERVER_HOST=affine.yourdomain.com`
4. Add the custom domain in Railway's service settings
5. The template automatically creates/updates the CNAME record in Cloudflare on each deploy

### Custom Domain (Manual)

1. Add a custom domain to the **affine** service in Railway's settings
2. Set `AFFINE_SERVER_HTTPS=true` and `AFFINE_SERVER_HOST=affine.yourdomain.com`
3. Create a CNAME record pointing to the Railway target domain shown in the dashboard

## Volumes

For data persistence, attach Railway volumes:

| Service | Mount Path | Purpose |
|---|---|---|
| postgres | `/var/lib/postgresql/data` | Database files (PGDATA is set to the `pgdata` subdirectory) |
| affine | `/root/.affine` | Uploads, config, and blob storage |

## AI Copilot

Set one (or both) API keys to enable AFFiNE's AI features:

| Provider | Env Var | Get a Key |
|---|---|---|
| **NVIDIA NIM** | `NVIDIA_NIM_API_KEY` | [build.nvidia.com](https://build.nvidia.com/) |
| **Google Gemini** | `GOOGLE_GEMINI_API_KEY` | [aistudio.google.com](https://aistudio.google.com/apikey) |

The template auto-generates AFFiNE's `config.json` on startup based on which keys are set. If both are provided, NIM is used as the default text model and Gemini is available as a secondary provider.

## Based On

This template is based on AFFiNE's [official self-hosting configuration](https://github.com/toeverything/AFFiNE/tree/canary/.docker/selfhost).
