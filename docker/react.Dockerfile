FROM node:22.13.1-alpine AS builder
WORKDIR /app
COPY ./package*.json ./
RUN npm ci
COPY ./ ./
RUN npm run build
RUN npm ci --omit=dev

FROM node:22.13.1-alpine AS runner
WORKDIR /app
COPY --from=builder /app/public ./public
COPY --from=builder /app/build ./build
COPY --from=builder /app/src ./src
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

CMD ["npm", "run", "start"]