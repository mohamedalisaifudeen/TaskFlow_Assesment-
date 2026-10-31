
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /build

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre

WORKDIR /app

RUN groupadd --system appgroup && \
    useradd --system --gid appgroup --no-create-home appuser

COPY --from=builder /build/target/*.jar app.jar
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD ["java", "-version"]

ENTRYPOINT ["java", "-jar", "app.jar"]
