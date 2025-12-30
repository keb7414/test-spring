pipeline {
	agent any

	options {
		disableConcurrentBuilds()
		timestamps()
	}

	environment {
		IMAGE_NAME = "genq-test"
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
					echo "=== Docker Build ==="
					docker build -t "${IMAGE_NAME}:latest" .
					
					echo "=== Apply Kubernetes Manifests ==="
					# 1. 쿠버네티스 설정 파일 적용 (없으면 생성, 있으면 업데이트)
					kubectl apply -f k8s/deployment.yaml
					kubectl apply -f k8s/service.yaml
					
					echo "=== Force Restart Deployment ==="
					# 2. 이미지가 갱신되었으므로 포드(Pod)를 재시작하여 새 이미지 반영
					kubectl rollout restart deployment/genq-test-deployment
					
					echo "=== K8s Status ==="
					kubectl get pods
					kubectl get service genq-test-service
				'''
			}
		}
	}

	post {
		success { echo '✅ Local Build & Run Success' }
		failure { echo '❌ Local Build & Run Failed' }
	}
}