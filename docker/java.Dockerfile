FROM maven:3-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY ./ ./
RUN mvn clean package -DskipTests

FROM bellsoft/liberica-runtime-container:jdk-17-crac-slim-musl
WORKDIR /app
COPY --from=build /app/target/cex24.jar ./
COPY --from=build /app/application-stage.properties ./
COPY --from=build /app/application.properties ./
COPY --from=build /app/quartz.properties ./
EXPOSE 8080

CMD java -jar cex24.jar