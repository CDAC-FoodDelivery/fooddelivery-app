FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Install wget for health checks
RUN apk add --no-cache wget

COPY --from=build /app/target/*.jar app.jar
EXPOSE 9081
ENTRYPOINT ["java", "-jar", "app.jar"]
