# Build stage: compile the app with Maven inside the container
FROM maven:3.9-eclipse-temurin-11 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q dependency:go-offline
COPY src src
RUN mvn -q package -DskipTests && cp target/*.jar app.jar

# Runtime stage: small JRE image, runs as a non-root user
FROM eclipse-temurin:11-jre-alpine
WORKDIR /app
RUN addgroup -S javauser && adduser -S -s /bin/false -G javauser javauser
COPY --from=build --chown=javauser:javauser /app/app.jar .
USER javauser
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
