FROM node:20.12.2-alpine3.19 AS base
RUN npm i -g pnpm

FROM base AS dependencies
WORKDIR /app
COPY .npmrc package.json pnpm-lock.yaml next.config.js ./
RUN pnpm install --frozen-lockfile
COPY ./ ./
COPY --from=dependencies /app/node_modules ./node_modules
RUN pnpm build
RUN pnpm prune --prod

FROM base AS runner
WORKDIR /app
COPY .npmrc package.json pnpm-lock.yaml next.config.js ./
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000
CMD ["node", "server.js"]