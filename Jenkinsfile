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
		CONTAINER_PORT = "8080"
	}

	stages {

		stage('Build Gradle') {
			steps {
				sh '''
					set -e
					echo "=== Java Version ==="
					java -version

					echo "=== Gradle Wrapper Version ==="
					if [ -f ./gradlew ]; then
						chmod +x ./gradlew
						./gradlew -v
					else
						echo "ERROR: gradlew not found"
						ls -al
						exit 1
					fi

					echo "=== Gradle Build ==="
					./gradlew clean build -x test --info
				'''
			}
		}

		stage('Docker Build') {
			steps {
				sh '''
					set -e
					echo "=== Docker Version ==="
					docker version

					if [ ! -f Dockerfile ]; then
						echo "ERROR: Dockerfile not found in workspace"
						pwd
						ls -al
						exit 1
					fi

					echo "=== Docker Build ==="
					docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
				'''
			}
		}

		stage('Run (Local Deploy)') {
			steps {
				sh '''
					set -e
					echo "=== Stop/Remove Existing Container (if any) ==="
					docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

					echo "=== Run Container ==="
					docker run -d --name "${CONTAINER_NAME}" -p "${HOST_PORT}:${CONTAINER_PORT}" "${IMAGE_NAME}:${IMAGE_TAG}"

					echo "=== Container Status ==="
					docker ps --filter "name=${CONTAINER_NAME}"

					echo "=== Recent Logs ==="
					docker logs --tail 80 "${CONTAINER_NAME}" || true
				'''
			}
		}
	}

	post {
		success { echo '✅ Local Build & Run Success' }
		failure { echo '❌ Local Build & Run Failed' }
	}
}
