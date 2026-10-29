FROM node:22.20.0-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:22.20.0-alpine AS builder
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY ./ ./
RUN npm run db:generate && \
    npm run build

FROM node:22.20.0-alpine AS runner
WORKDIR /app
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/package.json ./package.json
COPY --from=builder --chown=node:node /app/dist/ ./dist
COPY --from=builder --chown=node:node /app/prisma ./prisma
COPY --chown=node:node entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

USER 1000
EXPOSE 3000
ENTRYPOINT ["./entrypoint.sh"]

#Entrypoint.sh
#!/bin/sh
npm run db:deploy
npm run db:seed
npm run start:prod
