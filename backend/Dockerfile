# use the official Bun image
FROM oven/bun:1 AS base
# Use a consistent WORKDIR
WORKDIR /app

# ---- deps ----
# Note: Changed 'as' to 'AS' to fix your linter warning
FROM base AS deps
COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile

# ---- runner ----
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production

# Now /app/node_modules will actually exist in the deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY . .

EXPOSE 3000
CMD ["bun", "run", "start"]