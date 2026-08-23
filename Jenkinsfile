pipeline {
    agent any

    environment {
        IMAGE_NAME = 'secure-devsecops-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        TEST_CONTAINER = 'secure-devsecops-app-test'
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
                    docker build \
                        -t "${IMAGE_NAME}:${IMAGE_TAG}" \
                        .
                '''
            }
        }

        stage('Application Test') {
            steps {
                sh '''
                    docker run --rm \
                        "${IMAGE_NAME}:${IMAGE_TAG}" \
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
                        "${IMAGE_NAME}:${IMAGE_TAG}"
                '''
            }
        }

        stage('Container Test') {
            steps {
                sh '''
                    docker run -d \
                        --name "${TEST_CONTAINER}" \
                        --network host \
                        "${IMAGE_NAME}:${IMAGE_TAG}"

                    sleep 5

                    curl --fail \
                        http://localhost:5001/health
                '''
            }
        }
    }

    post {
        always {
            sh '''
                docker rm -f "${TEST_CONTAINER}" 2>/dev/null || true
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
