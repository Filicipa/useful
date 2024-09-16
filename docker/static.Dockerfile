FROM node:20.13.0-alpine3.19 AS builder
WORKDIR /app
ARG MODE
COPY ./package*.json ./
RUN npm ci
COPY ./ ./
RUN npm run build

FROM nginx:alpine AS runner
COPY --from=builder /app/dist/client/browser/ /usr/share/nginx/html/
COPY --from=builder /app/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]
