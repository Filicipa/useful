FROM node:22.13.1-alpine AS build
WORKDIR /usr
COPY package*.json ./
RUN npm ci
COPY ./ ./
RUN npx prisma generate
RUN npm run build
RUN npm ci --omit=dev

FROM node:22.13.1-alpine AS production
WORKDIR /app
COPY --chown=node:node --from=build /usr/prisma /app/prisma/
COPY --chown=node:node --from=build /usr/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/dist ./dist

USER node
EXPOSE 3000

CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main"]
