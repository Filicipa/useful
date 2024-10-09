FROM node:20.18.0-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY ./ ./
RUN npm run build
RUN npm ci --omit=dev

FROM node:20.18.0-alpine AS run
WORKDIR /app

COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/dist ./dist
COPY --from=build --chown=node:node /app/config ./config

USER node
EXPOSE 3000
CMD ["node", "dist/src/index.js"]