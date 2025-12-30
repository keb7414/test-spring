# syntax=docker/dockerfile:1

# 실행 환경만 설정 (JRE 사용)
FROM eclipse-temurin:21-jre
WORKDIR /app

# 젠킨스가 빌드한 JAR 파일을 복사 (경로 주의: build/libs/ 아래에 생성됨)
COPY build/libs/*.jar app.jar

EXPOSE 5081
ENTRYPOINT ["java","-jar","/app/app.jar"]