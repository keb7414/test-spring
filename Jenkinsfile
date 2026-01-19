pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        // 1. 본인의 도커 허브 ID로 수정 필수
        DOCKERHUB_ID = "eunbyeol120" 
        IMAGE_NAME = "test-job"
        // latest 대신 빌드 번호를 태그로 사용하여 버전 관리를 합니다.
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        FULL_IMAGE = "${DOCKERHUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        // 1. 빌드 준비
        stage('Prepare') {
            steps {
                sh '''
                    echo "=== Check Environment ==="
                    java -version
                    kubectl version --client
                '''
            }
        }

        // 2. 프로젝트 빌드 (Jar 생성)
        stage('Build') {
            steps {
                sh '''
                    set -e
                    # t3.micro 메모리 보호: Gradle 데몬을 끄고 메모리 사용량을 제한합니다.
                    export GRADLE_OPTS="-Dorg.gradle.jvmargs='-Xmx512m' -Dorg.gradle.daemon=false"
                    
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

        // 3. Kaniko를 이용한 이미지 빌드 및 푸시 (Docker 데몬 대체)
        stage('Kaniko Build & Push') {
            steps {
                echo "=== Starting Kaniko Build ==="
                sh """
                    kubectl run kaniko-${IMAGE_TAG} --rm -i --restart=Never \
                      --image=gcr.io/kaniko-project/executor:latest \
                      --overrides='{
                        "spec": {
                          "containers": [{
                            "name": "kaniko",
                            "image": "gcr.io/kaniko-project/executor:latest",
                            "args": [
                              "--dockerfile=Dockerfile",
                              "--context=dir:///workspace",
                              "--destination=${FULL_IMAGE}"
                            ],
                            "volumeMounts": [
                              {"name": "workspace", "mountPath": "/workspace"},
                              {"name": "docker-config", "mountPath": "/kaniko/.docker/"}
                            ]
                          }],
                          "volumes": [
                            {"name": "workspace", "hostPath": {"path": "${WORKSPACE}"}},
                            {"name": "docker-config", "secret": {"secretName": "dockerhub-config", "items": [{"key": ".dockerconfigjson", "path": "config.json"}]}}
                          ]
                        }
                      }'
                """
            }
        }

        // 4. 배포 (쿠버네티스 업데이트)
        stage('Deploy') {
            steps {
                sh '''
                    set -e
                    echo "=== Apply Kubernetes Manifests ==="
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    
                    echo "=== Update Deployment Image ==="
                    # 새 이미지 태그로 배포를 업데이트합니다.
                    kubectl set image deployment/test-job-deployment test-job-container="${FULL_IMAGE}"
                    
                    echo "=== K8s Status ==="
                    kubectl get pods
                    kubectl get service test-job-service
                '''
            }
        }
    }

    post {
        success { echo "✅ Build & Deploy Success: ${FULL_IMAGE}" }
        failure { echo '❌ Build & Deploy Failed' }
    }
}
