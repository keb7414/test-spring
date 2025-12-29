pipeline {
	agent any

	tools {
		jdk 'jdk21'
	}

	options {
		disableConcurrentBuilds()
		timestamps()
	}

	environment {
		IMAGE_NAME = "genq"
		IMAGE_TAG = "${BUILD_NUMBER}"
		CONTAINER_NAME = "genq-local"

		HOST_PORT = "5081"
		CONTAINER_PORT = "5081"
	}

	stages {

		stage('Build Gradle') {
			steps {
				bat '''
					@echo on
					echo === Java Version ===
					java -version
					echo === Gradle Wrapper Version ===
					if exist gradlew.bat (
						gradlew.bat -v
					) else (
						echo ERROR: gradlew.bat not found
						exit /b 1
					)

					echo === Gradle Build ===
					gradlew.bat clean build -x test --info
				'''
			}
		}

		stage('Docker Build') {
			steps {
				bat '''
					@echo on
					echo === Docker Version ===
					docker version

					if not exist Dockerfile (
						echo ERROR: Dockerfile not found in workspace
						dir
						exit /b 1
					)

					echo === Docker Build ===
					docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
				'''
			}
		}

		stage('Run (Local Deploy)') {
			steps {
				bat '''
					@echo on
					echo === Stop/Remove Existing Container (if any) ===
					docker rm -f %CONTAINER_NAME% 2>nul

					echo === Run Container ===
					docker run -d --name %CONTAINER_NAME% -p %HOST_PORT%:%CONTAINER_PORT% %IMAGE_NAME%:%IMAGE_TAG%

					echo === Container Status ===
					docker ps --filter "name=%CONTAINER_NAME%"

					echo === Recent Logs ===
					docker logs --tail 80 %CONTAINER_NAME%
				'''
			}
		}
	}

	post {
		success { echo '✅ Local Build & Run Success' }
		failure { echo '❌ Local Build & Run Failed' }
	}
}
