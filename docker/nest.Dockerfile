FROM node:22.20.0-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY ./ ./
RUN npm run build && \
    npm ci --omit=dev

FROM node:22.20.0-alpine AS run
WORKDIR /app

COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/dist ./dist

USER 1000
EXPOSE 3000
CMD ["node", "dist/main"]