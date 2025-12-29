# syntax=docker/dockerfile:1

# =========================
# 1) Build stage
# =========================
FROM eclipse-temurin:21-jdk AS builder
WORKDIR /app

# Gradle wrapper & build scripts 먼저 복사 (캐시 효율)
COPY gradlew gradlew
COPY gradlew.bat gradlew.bat
COPY gradle gradle
COPY build.gradle* settings.gradle* ./

# 실행 권한 (중요)
RUN chmod +x /app/gradlew

# 소스 복사 후 빌드
COPY . .
RUN ./gradlew clean bootJar -x test

# =========================
# 2) Run stage
# =========================
FROM eclipse-temurin:21-jre
WORKDIR /app

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
