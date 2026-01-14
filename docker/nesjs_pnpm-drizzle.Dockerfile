FROM node:22.13.1-alpine AS base
RUN npm install -g pnpm

FROM base AS build
WORKDIR /app
COPY package*.json pnpm-lock.yaml tsconfig.json ./
RUN pnpm install --frozen-lockfile
COPY ./ ./
RUN pnpm run build
RUN pnpm install --frozen-lockfile --prod

FROM base AS production

WORKDIR /app
# COPY git-sha.* ./
COPY --from=build --chown=node:node /app/package.json ./package.json
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/dist ./dist
COPY --from=build --chown=node:node /app/src/migrations ./src/migrations
COPY --from=build --chown=node:node /app/drizzle.config.ts ./drizzle.config.ts
COPY --from=build --chown=node:node /app/start.sh ./start.sh
RUN chmod 500 ./start.sh

USER node

ENTRYPOINT "./start.sh"