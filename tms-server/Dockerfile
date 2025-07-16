# Multi-stage Dockerfile for TMS Server
# Stage 1: Build stage với Maven và OpenJDK
FROM maven:3.9.9-amazoncorretto-21-debian AS build

# Set working directory
WORKDIR /app

# Copy pom.xml first để cache Maven dependencies
# Điều này giúp tăng tốc rebuild khi chỉ thay đổi source code
COPY pom.xml .

# Download dependencies (sẽ được cache nếu pom.xml không thay đổi)
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build application (skip tests để tránh lỗi PostgreSQL dependency trong Docker build)
RUN mvn clean package -DskipTests

# Stage 2: Runtime stage với JRE nhẹ hơn
FROM openjdk:21-jdk-slim AS runtime

# Install curl cho health check
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create non-root user cho security
RUN addgroup --system spring && adduser --system spring --ingroup spring
USER spring:spring

# Copy JAR file từ build stage
COPY --from=build /app/target/tms-0.0.1-SNAPSHOT.jar /app/tms.jar

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# JVM options cho production
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:+UseContainerSupport"

# Start application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/tms.jar"]