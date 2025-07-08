# From maven base image with Amazon Corretto 21
FROM maven:3.9.9-amazoncorretto-21-debian AS build

# Set the working directory
WORKDIR /app

# Copy pom.xml and source code => app/pom.xml
COPY pom.xml .

# Install maven dependencies
RUN mvn dependency:go-offline

# Copy the source code => app/src
COPY src ./src
RUN mvn -B install

# From OpenJDK 21 base image
FROM openjdk:21-jdk-slim AS runtime

# Set working directory inside the container
WORKDIR /app

# Copy the built JAR file from the build stage
COPY --from=build /app/target/tms-0.0.1-SNAPSHOT.jar /app/tms.jar

# Expose the application port
EXPOSE 8080

# Start the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/tms.jar"]