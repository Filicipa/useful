### PNPM ###
FROM node:22.20.0-alpine AS base
RUN npm i -g pnpm

FROM base AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml next.config.js ./
RUN pnpm install --frozen-lockfile
COPY ./ ./
RUN pnpm build

FROM base AS runner
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static
EXPOSE 3000
CMD ["node", "server.js"]

### NPM ###

FROM node:22.20.0-alpine AS builder
WORKDIR /app
COPY package*.json next.config.mjs ./
RUN npm ci
COPY ./ ./
RUN npm run build
RUN npm ci --omit=dev

FROM node:22.20.0-alpine AS runner
WORKDIR /app

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000
CMD ["node", "server.js"]