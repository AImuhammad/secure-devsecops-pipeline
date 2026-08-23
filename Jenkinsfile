pipeline {
    agent any

    environment {
        REPO_URL   = 'https://github.com/AImuhammad/secure-devsecops-pipeline.git'
        IMAGE_NAME = 'secure-devsecops-app'
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: "${REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        .
                '''
            }
        }

        stage('Application Test') {
            steps {
                sh '''
                    docker run --rm \
                        ${IMAGE_NAME}:${IMAGE_TAG} \
                        python -c "import flask; print('Flask:', flask.__version__)"
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                    trivy image \
                        --severity HIGH,CRITICAL \
                        --exit-code 1 \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

stage('Test') {
    steps {
        sh '''
            docker run --rm \
              -v "$PWD/app:/app" \
              python:3.12-alpine \
              sh -c "pip install --no-cache-dir -r /app/requirements.txt && cd /app && python -m pytest"
        '''
    }
}



post {
    always {
        sh '''
            docker rm -f "${IMAGE_NAME}-test" 2>/dev/null || true
        '''
    }

    success {
        echo 'CI/CD pipeline completed successfully.'
    }

    failure {
        echo 'CI/CD pipeline failed.'
    }
}
