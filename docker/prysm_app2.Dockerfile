FROM node:20.18.0-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:20.18.0-alpine AS builder
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY ./ ./
RUN npm run db:generate
RUN npm run build

FROM node:20.18.0-alpine AS runner
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/dist/ ./dist
COPY --from=builder /app/prisma ./prisma
COPY ./prisma ./
COPY entrypoint.sh ./
RUN chmod +x ./entrypoint.sh
EXPOSE 3000
ENTRYPOINT ["./entrypoint.sh"]


#Entrypoint.sh
#!/bin/sh
#!/bin/sh
npm run db:deploy
npm run db:seed
npm run start:prod
