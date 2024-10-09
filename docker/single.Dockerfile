FROM node:20.18.0-alpine AS build
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install glob rimraf
RUN npm ci
COPY ./ ./
RUN npm run build ${SERVICE_NAME}

FROM node:20.18.0-alpine as production
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
# RUN apk --no-cache add curl
# HEALTHCHECK CMD curl --fail http://localhost:8080/api/health || exit 1
WORKDIR /usr/src/app
COPY package*.json ./
COPY git-sha.* ./
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/dist ./dist
EXPOSE 8000
ENV EXECUTION_FILE=dist/src/main
CMD npm run migrations:prod && node ${EXECUTION_FILE}