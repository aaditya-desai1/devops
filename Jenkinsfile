pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
    }

    stages {

        // ---------------- Stage 1: Checkout Code ----------------
        stage('Checkout Code') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        // ---------------- Stage 2: Build Docker Image ----------------
        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                    echo "Building Docker Image..."
                    docker build -t aadityadesai/devops:latest -f Dockerfile .
                    '''
                }
            }
        }

        // ---------------- Stage 3: Login to Docker Hub ----------------
        stage('Login to Docker Hub') {
            steps {
                script {
                    sh '''
                    echo "Logging into Docker Hub..."
                    echo $DOCKER_CREDENTIALS_PSW | docker login -u $DOCKER_CREDENTIALS_USR --password-stdin
                    '''
                }
            }
        }

        // ---------------- Stage 4: Push Docker Image to Docker Hub ----------------
        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    sh '''
                    echo "Pushing Docker Image to Docker Hub..."
                    docker push aadityadesai/devops:latest
                    '''
                }
            }
        }

        // ---------------- Stage 5: Start Minikube with Docker Driver ----------------
        stage('Start Minikube') {
            steps {
                script {
                    sh '''
                    echo "Starting Minikube with Docker Driver and --force..."
                    minikube start --driver=none --force
                    '''
                }
            }
        }

        // ---------------- Stage 6: Deploy to Kubernetes ----------------
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                    echo "Deploying to Kubernetes..."
                    kubectl apply -f deployment.yml
                    '''
                }
            }
        }
    }

    // ---------------- Post Actions ----------------
    post {
        success {
            echo "✅ Build and Deployment Successful!"
        }
        failure {
            echo "❌ Build or Deployment Failed!"
        }
    }
}
