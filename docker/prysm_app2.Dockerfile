FROM node:18-alpine As build
WORKDIR /usr
COPY package*.json ./
ENV NODE_ENV production
RUN npm ci --omit=dev && npm cache clean --force
COPY ./ ./
RUN npx prisma generate
RUN npm run build

FROM node:18-alpine AS production
WORKDIR /app
#See in config Prisma
COPY --chown=node:node --from=build /usr/src/prisma/schema/ /app/prisma/
COPY --chown=node:node --from=build /usr/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/dist ./dist
USER node
EXPOSE 3000
CMD npx prisma migrate deploy && node dist/main