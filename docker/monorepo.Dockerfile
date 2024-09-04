FROM node:20.9.0-alpine AS build
ARG SERVICE_NAME='name'
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install glob rimraf
RUN npm ci
COPY ./ ./
RUN npm run build ${SERVICE_NAME}

FROM node:20.9.0-alpine as production
ARG SERVICE_NAME='name'
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
WORKDIR /usr/src/app
COPY package*.json ./
COPY git-sha.* ./
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/dist ./dist

EXPOSE 8080
ENV EXECUTION_FILE=dist/apps/$SERVICE_NAME/apps/$SERVICE_NAME/src/main
CMD npm run migrations:prod && node ${EXECUTION_FILE}