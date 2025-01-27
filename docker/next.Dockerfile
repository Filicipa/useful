### PNPM ###
FROM node:22.13.1-alpine AS base
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
CMD ["node", "server.js"]

### NPM ###

FROM node:22.13.1-alpine AS builder
WORKDIR /app
COPY package.json next.config.js ./
RUN npm install --force
COPY ./ ./
RUN npm run build

FROM node:22.13.1-alpine AS runner
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY ./public ./public
COPY ./.env ./
EXPOSE 3000
CMD ["node", "server.js"]