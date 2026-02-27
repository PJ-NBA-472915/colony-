# Colony

A hardened container image designed to be deployed in hostile or untrusted environments. Colony provides a secure SSH-accessible node over a ZeroTier private network, suitable for bootstrapping remote infrastructure such as K3s cluster nodes.

## Overview

Colony packages Ubuntu 24.04 with ZeroTier and OpenSSH into a single container managed by supervisord. Once deployed, it joins a ZeroTier network and exposes SSH access exclusively via public key authentication. Password auth and root login are disabled by default.

### What's Inside

- **ZeroTier** — encrypted peer-to-peer networking to reach the container without exposing ports to the public internet
- **OpenSSH** — key-only SSH access for remote management
- **Supervisord** — process management for ZeroTier and sshd
- **Sudo** — passwordless sudo for the `colony` user

## Prerequisites

- Docker (installed automatically by the deploy script if missing)
- A [ZeroTier](https://zerotier.com) network ID
- An SSH public key
- A GitHub Personal Access Token (PAT) with `read:packages` scope

## Quick Deploy (One-Liner)

Create a `.env` file on the target machine (see `.env.example`):

```
SSH_PUBLIC_KEY=ssh-ed25519 AAAA...
ZEROTIER_NETWORK=abc123def456
GITHUB_PROJECT=PJ-NBA-472915
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
```

Then run:

```bash
set -a && source .env && set +a && curl -sSL https://raw.githubusercontent.com/PJ-NBA-472915/colony-/main/scripts/deploy.sh | bash
```

This will authenticate with GHCR, pull the image, and start the container.

## Manual Setup

### Clone and Configure

```bash
git clone https://github.com/PJ-NBA-472915/colony-.git
cd colony-
cp .env.example .env
# Edit .env with your values
```

### Build Locally

```bash
docker compose build
```

### Run

```bash
docker compose up -d
```

### Pull Pre-Built Image

```bash
echo "$GITHUB_TOKEN" | docker login ghcr.io -u PJ-NBA-472915 --password-stdin
docker pull ghcr.io/pj-nba-472915/colony:latest
```

## Environment Variables

| Variable | Description |
|---|---|
| `SSH_PUBLIC_KEY` | Public key written to the `colony` user's `authorized_keys` |
| `ZEROTIER_NETWORK` | ZeroTier network ID to join on startup |
| `GITHUB_PROJECT` | GitHub org or user (used for GHCR image path) |
| `GITHUB_TOKEN` | PAT with `read:packages` scope for pulling from GHCR |

## Project Structure

```
.
├── Containerfile              # Container image definition
├── config/
│   └── supervisor/            # Supervisord configs for sshd and ZeroTier
├── docker-compose.yml         # Compose config for local dev / deployment
├── scripts/
│   ├── deploy.sh              # One-liner deploy script
│   └── entrypoint.sh          # Container entrypoint
├── .env.example               # Template for required environment variables
└── LICENSE                    # MIT
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-change`)
3. Make your changes
4. Test locally with `docker compose build && docker compose up`
5. Commit and push to your fork
6. Open a pull request against `main`

## Contributors

- [PJ-NBA-472915](https://github.com/PJ-NBA-472915)

## License

[MIT](LICENSE)
