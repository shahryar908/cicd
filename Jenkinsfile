pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "fastapi-cicd"
        DOCKER_TAG = "${BUILD_NUMBER}"
        APP_PORT = "8000"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                script {
                    sh """
                        docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG} \
                        uv run python -c 'from main import app; print("App loaded successfully")'
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                script {
                    sh """
                        docker stop fastapi-app || true
                        docker rm fastapi-app || true
                    """

                    sh """
                        docker run -d \
                          --name fastapi-app \
                          -p ${APP_PORT}:8000 \
                          --restart unless-stopped \
                          ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """

                    sh """
                        docker images ${DOCKER_IMAGE} --format "{{.ID}}" | tail -n +4 | xargs -r docker rmi || true
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                script {
                    sh '''
                        echo "Waiting for app to start..."
                        for i in {1..30}; do
                            if curl -f http://localhost:8000/ 2>/dev/null; then
                                echo "App is healthy!"
                                exit 0
                            fi
                            echo "Attempt $i failed, retrying..."
                            sleep 2
                        done
                        echo "Health check failed after 30 attempts"
                        exit 1
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            echo 'Cleaning up...'
            sh 'docker system prune -f || true'
        }
    }
}
