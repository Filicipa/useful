FROM node:20.3.1-alpine3.18 AS build
WORKDIR /usr
COPY package*.json ./
RUN npm ci
COPY ./ ./
RUN npx prisma generate
RUN npm run build
RUN npm ci --omit=dev

FROM node:20.3.1-alpine3.18 AS production
WORKDIR /app
COPY --chown=node:node --from=build /usr/prisma /app/prisma/
COPY --chown=node:node --from=build /usr/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/dist ./dist

USER node
EXPOSE 3000

CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main"]
