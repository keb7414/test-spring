pipeline {
	agent any

	options {
		disableConcurrentBuilds()
		timestamps()
	}

	environment {
		IMAGE_NAME = "genq-test"
		BUILD_TAG = "${BUILD_NUMBER}"
		IMAGE_TAG = "latest"
		
		CONTAINER_NAME = "genq-test"
		HOST_PORT = "5081"
		CONTAINER_PORT = "5081"
	}

	stages {
		// 1. 빌드 준비 및 환경 확인
		stage('Prepare') {
			steps {
				sh '''
					echo "=== Check Environment ==="
					java -version
					docker version
				'''
			}
		}

		// 2. 프로젝트 빌드 (Jar 생성)
		stage('Build') {
			steps {
				sh '''
					set -e
					if [ -f ./gradlew ]; then
						chmod +x ./gradlew
						./gradlew clean build -x test --info
					else
						echo "ERROR: gradlew not found"
						exit 1
					fi
				'''
			}
		}

		// 3. 도커 빌드 및 배포 (통합 단계)
		stage('Deploy') {
			steps {
				sh '''
					set -e
					echo "=== Docker Build  ==="
					# 1. 새 이미지 빌드 (기존 이름과 겹치면 기존 것은 이름 없는 이미지가 됨)
					docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" -t "${IMAGE_NAME}:${BUILD_TAG}" .
					
					echo "=== Replace Container ==="
					# 2. 기존 컨테이너 교체
					docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
					
					docker run -d --name "${CONTAINER_NAME}" \
						-p "${HOST_PORT}:${CONTAINER_PORT}" \
						"${IMAGE_NAME}:${IMAGE_TAG}"
					
					docker ps --filter "name=${CONTAINER_NAME}"
					
					echo "=== Cleanup Unused Images ==="
					# 3. 태그가 겹쳐서 이름이 없어진 구버전 이미지들 삭제
					docker image prune -f
				'''
			}
		}
	}

	post {
		success { echo '✅ Local Build & Run Success' }
		failure { echo '❌ Local Build & Run Failed' }
	}
}