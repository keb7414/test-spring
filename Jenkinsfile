pipeline {
	agent any

	options {
		disableConcurrentBuilds()
		timestamps()
	}

	environment {
		IMAGE_NAME = "genq-test"
		IMAGE_TAG = "${BUILD_NUMBER}"
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
					echo "=== Docker Build & Deploy ==="
					docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
					
					docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
					
					docker run -d --name "${CONTAINER_NAME}" \
						-p "${HOST_PORT}:${CONTAINER_PORT}" \
						"${IMAGE_NAME}:${IMAGE_TAG}"
					
					docker ps --filter "name=${CONTAINER_NAME}"
				'''
			}
		}
	}

	post {
		success { echo '✅ Local Build & Run Success' }
		failure { echo '❌ Local Build & Run Failed' }
	}
}