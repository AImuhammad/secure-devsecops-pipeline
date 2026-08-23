pipeline {
    agent any

    environment {
        IMAGE_NAME = "secure-devsecops-app"
        IMAGE_TAG = "5"
        CONTAINER_NAME = "secure-devsecops-app-test"
        APP_PORT = "5001"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/AImuhammad/secure-devsecops-pipeline.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
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

        stage('Container Test') {
            steps {
                sh '''
                    set -e

                    echo "Starting test container..."

                    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true

                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        ${IMAGE_NAME}:${IMAGE_TAG}

                    echo "Waiting for application to start..."

                    sleep 5

                    echo "Getting container IP..."

                    CONTAINER_IP=$(docker inspect \
                        -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
                        ${CONTAINER_NAME})

                    echo "Container IP: ${CONTAINER_IP}"

                    echo "Testing health endpoint..."

                    curl --fail \
                        --retry 5 \
                        --retry-delay 2 \
                        http://${CONTAINER_IP}:${APP_PORT}/health

                    echo ""
                    echo "Container health check passed."
                '''
            }
        }
    }

    post {
        always {
            sh '''
                docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
            '''
        }

        success {
            echo 'CI/CD pipeline completed successfully.'
        }

        failure {
            echo 'CI/CD pipeline failed.'
        }
    }
}
