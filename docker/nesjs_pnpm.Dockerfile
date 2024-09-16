FROM node:20.12.2-alpine3.19 AS base 
RUN npm install -g pnpm

FROM base AS build
ENV NODE_ENV=production
WORKDIR /app
COPY --chown=node:node package.json pnpm-lock.yaml ./
RUN pnpm i --frozen-lockfile
COPY --chown=node:node ./ ./
RUN pnpm build


FROM node:20.12.2-alpine3.19 AS production
WORKDIR /app
ENV NODE_ENV=production
COPY --chown=node:node --from=build /app/node_modules ./node_modules
COPY --chown=node:node --from=build /app/dist ./dist

USER node
EXPOSE 5001
CMD [ "node", "dist/main.js" ]