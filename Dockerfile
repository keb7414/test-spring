# syntax=docker/dockerfile:1

# 1. 실행 환경 설정 (JRE 21 사용)
FROM eclipse-temurin:21-jre
WORKDIR /app

# 2. 빌드된 JAR 파일 복사
# Kaniko 실행 시 --context로 지정된 경로를 기준으로 파일을 찾습니다.
COPY build/libs/*-SNAPSHOT.jar app.jar

# 3. t3.micro 환경을 위한 JVM 메모리 최적화 환경 변수
# -Xmx256m: 최대 힙 메모리를 256MB로 제한 (1GB 서버에서 안정적)
# -XX:+UseSerialGC: 저사양 환경에서 CPU 사용량을 줄여주는 가비지 컬렉터
ENV JAVA_OPTS="-Xmx256m -Xms128m -XX:+UseSerialGC"

EXPOSE 5081

# 4. ENTRYPOINT 수정
# 변수(JAVA_OPTS)를 인식하기 위해 sh -c 형식을 사용합니다.
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
