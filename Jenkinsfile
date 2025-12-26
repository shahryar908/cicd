pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "fastapi-cicd"
        DOCKER_TAG = "${BUILD_NUMBER}"
        EC2_HOST = "${EC2_HOST}" // Set in Jenkins credentials
        EC2_USER = "ec2-user" // or ubuntu, depending on your AMI
        APP_PORT = "8000"
        SSH_KEY = credentials('ec2-ssh-key') // Jenkins credential ID for PEM file
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
        
        stage('Deploy to EC2') {
            steps {
                echo 'Deploying to EC2...'
                script {
                    // Save the Docker image as a tar file
                    sh "docker save ${DOCKER_IMAGE}:${DOCKER_TAG} -o ${DOCKER_IMAGE}-${DOCKER_TAG}.tar"
                    
                    // Copy image to EC2 using PEM key
                    sh """
                        scp -i ${SSH_KEY} -o StrictHostKeyChecking=no \
                        ${DOCKER_IMAGE}-${DOCKER_TAG}.tar \
                        ${EC2_USER}@${EC2_HOST}:/tmp/
                    """
                    
                    // Deploy on EC2
                    sh """
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << 'ENDSSH'
                        
                        # Load the Docker image
                        docker load -i /tmp/${DOCKER_IMAGE}-${DOCKER_TAG}.tar
                        
                        # Stop and remove old container
                        docker stop fastapi-app || true
                        docker rm fastapi-app || true
                        
                        # Run new container
                        docker run -d \
                          --name fastapi-app \
                          -p ${APP_PORT}:8000 \
                          --restart unless-stopped \
                          ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        # Clean up
                        rm /tmp/${DOCKER_IMAGE}-${DOCKER_TAG}.tar
                        
                        # Remove old images (keep last 3)
                        docker images ${DOCKER_IMAGE} --format "{{.ID}}" | tail -n +4 | xargs -r docker rmi || true
ENDSSH
                    """
                    
                    // Clean up local tar file
                    sh "rm ${DOCKER_IMAGE}-${DOCKER_TAG}.tar"
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                script {
                    sh """
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} \
                        'curl -f http://localhost:${APP_PORT}/ || exit 1'
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            echo "Application deployed at http://${EC2_HOST}:${APP_PORT}"
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
