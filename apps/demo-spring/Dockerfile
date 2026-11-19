# syntax=docker/dockerfile:1.7
FROM maven:3.9.9-eclipse-temurin-21-alpine AS build
WORKDIR /src
COPY pom.xml .
COPY src ./src
RUN mvn --batch-mode -DskipTests package

FROM eclipse-temurin:21-jre-alpine
RUN addgroup -S app && adduser -S -G app -u 10001 app
WORKDIR /app
COPY --from=build /src/target/demo-spring-0.1.0.jar app.jar
USER 10001:10001
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --retries=3 CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
