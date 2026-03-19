FROM node:22.20.0-alpine AS build
ARG SERVICE_NAME='name'
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY ./ ./
RUN npm run build ${SERVICE_NAME}

FROM node:22.20.0-alpine AS production
ARG SERVICE_NAME='name'
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
WORKDIR /app
COPY package*.json ./
COPY git-sha.* ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist

EXPOSE 8080
ENV EXECUTION_FILE=dist/apps/$SERVICE_NAME/apps/$SERVICE_NAME/src/main
CMD npm run migrations:prod && node ${EXECUTION_FILE}