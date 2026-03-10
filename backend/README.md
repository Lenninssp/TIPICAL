# Bun API Deployment Workflow (Docker Hub + VPS + Nginx)

Serve endpoint at:
- https://lenninsabogal.online/tipical/

---



## One-time setup (VPS)

### 1) Create app folder
SSH into VPS:
- mkdir -p ~/apps/bun-auth-api
- cd ~/apps/bun-auth-api

Put these files in this folder:
- docker-compose.yml
- .env (production secrets, not in git)

### 2) docker-compose.yml (bind API only to localhost)
Example:
- ports:
  - "127.0.0.1:3000:3000"

This ensures only Nginx can reach the API publicly.

### 3) Nginx routes /tipical/ to the container
The /tipical/ location should proxy to localhost:3000 and strip the prefix.

Key rule:
- proxy_pass must have a trailing slash so /tipical/ is stripped:
  - proxy_pass http://127.0.0.1:3000/;

Reload Nginx after edits:
- sudo nginx -t
- sudo systemctl reload nginx

---

## Repeatable release workflow (every deploy)

### Step A) Develop locally
- Make code changes
- Run locally:
  - bun run start
  - (optional) bun test

### Step B) Build + push Docker image (multi-arch)
This avoids exec format error on amd64 VPS.

One-time (first time only):
- docker buildx create --use --name multiarch || docker buildx use multiarch
- docker buildx inspect --bootstrap

Every deploy (build + push):
- docker buildx build --platform linux/amd64,linux/arm64 -t <DOCKERHUB_USER>/<IMAGE_NAME>:latest --push .

Optional version tag:
- docker buildx build --platform linux/amd64,linux/arm64 -t <DOCKERHUB_USER>/<IMAGE_NAME>:v1.0.0 --push .

### Step C) Deploy on VPS (pull + restart)
SSH into VPS:
- cd ~/apps/bun-auth-api
- docker compose pull
- docker compose up -d
- docker compose logs -f

### Step D) Verify
From anywhere:
- curl -i https://lenninsabogal.online/tipical/

Protected endpoint (expected 401 until login):
- curl -i https://lenninsabogal.online/tipical/me

Direct upstream check on VPS (should return OK):
- curl -i http://127.0.0.1:3000/

---

## Troubleshooting

### 1) exec format error
Cause:
- image built for arm64, VPS is amd64 (or vice versa)

Fix:
- always build multi-arch:
  - docker buildx build --platform linux/amd64,linux/arm64 ...

### 2) 502 Bad Gateway from Nginx
Cause:
- Nginx cannot reach upstream

Check on VPS:
- curl -i http://127.0.0.1:3000/
- docker ps
- sudo tail -n 80 /var/log/nginx/error.log

### 3) Update did not apply
Fix on VPS:
- docker compose pull
- docker compose up -d
- docker compose logs -f
- (optional) docker image prune -f

---

## Secrets management

- Keep real secrets in VPS file: ~/apps/bun-auth-api/.env
- Keep template in repo: .env.example
- Firebase private key in .env must preserve newlines:
  - store with \\n in env
  - backend code must convert:
    - privateKeyRaw.replace(/\\n/g, "\n")