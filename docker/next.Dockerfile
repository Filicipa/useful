FROM node:16.20.2-alpine3.18 AS base
RUN npm i -g pnpm

FROM base AS dependencies
WORKDIR /app
COPY .npmrc package.json pnpm-lock.yaml next.config.mjs ./
RUN pnpm install --frozen-lockfile

FROM base AS builder
WORKDIR /app
COPY ./ ./
COPY --from=dependencies /app/node_modules ./node_modules
RUN pnpm build
RUN pnpm prune --prod

FROM base AS runner
WORKDIR /app
COPY .npmrc package.json pnpm-lock.yaml next.config.mjs ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000
CMD ["pnpm", "start"]


####### PNPM ########
FROM node:20.12.2-alpine3.19 AS base
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
COPY --from=builder /app/.next/static ./.next/static
COPY ./public ./public
COPY ./.env ./
EXPOSE 3000
CMD node server.js

#### NPM ####

FROM node:20.12.2-alpine3.19 AS builder
WORKDIR /app
COPY package.json next.config.js ./
RUN npm install --force
COPY ./ ./
RUN npm run build

FROM node:20.12.2-alpine3.19 AS runner
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY ./public ./public
COPY ./.env ./
EXPOSE 3000
CMD node server.js