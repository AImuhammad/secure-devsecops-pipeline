pipeline {
    agent any

    environment {
        APP_NAME = 'secure-devsecops-app'
        IMAGE_TAG = '5'
        TEST_CONTAINER = 'secure-devsecops-app-test'
        SONAR_PROJECT_KEY = 'secure-devsecops-app'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/AImuhammad/secure-devsecops-pipeline.git'
            }
        }

        stage('Application Tests') {
            steps {
                sh '''
                    set -e

                    python3 -m venv .ci-venv
                    . .ci-venv/bin/activate

                    pip install --upgrade pip
                    pip install -r app/requirements.txt
                    pip install pytest

                    PYTHONPATH=. pytest -v

                    deactivate
                    rm -rf .ci-venv
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                      -t ${APP_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                          -Dsonar.projectName=${SONAR_PROJECT_KEY} \
                          -Dsonar.sources=app \
                          -Dsonar.host.url=http://sonarqube:9000
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      ${APP_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Container Test') {
            steps {
                sh '''
                    set -e

                    docker rm -f ${TEST_CONTAINER} 2>/dev/null || true

                    docker run -d \
                      --name ${TEST_CONTAINER} \
                      ${APP_NAME}:${IMAGE_TAG}

                    echo "Waiting for application..."
                    sleep 5

                    CONTAINER_IP=$(docker inspect \
                      -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
                      ${TEST_CONTAINER})

                    echo "Container IP: ${CONTAINER_IP}"

                    curl --fail \
                      --retry 5 \
                      --retry-delay 2 \
                      http://${CONTAINER_IP}:5001/health

                    echo ""
                    echo "Container health check passed."
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKERHUB_USERNAME',
                        passwordVariable: 'DOCKERHUB_TOKEN'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "$DOCKERHUB_TOKEN" | docker login \
                            -u "$DOCKERHUB_USERNAME" \
                            --password-stdin

                        docker tag \
                            ${APP_NAME}:${IMAGE_TAG} \
                            ${DOCKERHUB_USERNAME}/${APP_NAME}:${IMAGE_TAG}

                        docker push \
                            ${DOCKERHUB_USERNAME}/${APP_NAME}:${IMAGE_TAG}

                        docker logout
                    '''
                }
            }
        }
    }

    post {
        always {
            sh '''
                docker rm -f ${TEST_CONTAINER} 2>/dev/null || true
                rm -rf .ci-venv
            '''
        }

        success {
            echo 'Secure DevSecOps pipeline completed successfully.'
        }

        failure {
            echo 'Secure DevSecOps pipeline failed.'
        }
    }
}
