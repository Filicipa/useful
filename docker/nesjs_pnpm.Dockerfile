FROM node:22.13.1-alpine AS base 
RUN npm install -g pnpm

FROM base AS build
ENV NODE_ENV=production
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY ./ ./
RUN pnpm run build
RUN pnpm install --frozen-lockfile --prod

FROM node:22.13.1-alpine AS production
WORKDIR /app
ENV NODE_ENV=production
COPY --chown=node:node --from=build /app/node_modules ./node_modules
COPY --chown=node:node --from=build /app/dist ./dist

USER node
EXPOSE 5001
CMD [ "node", "dist/main" ]