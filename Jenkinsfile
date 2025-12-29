pipeline {
	agent any

	tools {
		jdk 'jdk21'
	}

	options {
		disableConcurrentBuilds()
	}

	stages {
		stage('Checkout + Build (workspace: /work)') {
			steps {
				ws("/work/${env.JOB_NAME}/${env.BUILD_NUMBER}") {
					git(
						branch: 'master',
						url: 'https://github.com/keb7414/test-spring.git',
						credentialsId: 'github-token'
					)

					bat 'gradlew.bat clean build'
				}
			}
		}
	}

	post {
		success { echo '✅ Build Success' }
		failure { echo '❌ Build Failed' }

		always {
			// 빌드 끝나면 /work 하위 디스크 사용량이 계속 늘어날 수 있어서,
			// 필요하면 아래 cleanWs() 사용을 고려하세요 (Workspace Cleanup 플러그인 필요)
			// cleanWs()
		}
	}
}
