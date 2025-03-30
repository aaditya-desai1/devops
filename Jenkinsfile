pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'aadityadesai/devops:latest'
    }

    stages {

        stage('Checkout Code') {
            steps {
                script {
                    checkout([$class: 'GitSCM',
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[url: 'https://github.com/aaditya-desai1/devops.git']]
                    ])
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                    echo "Building Docker Image..."
                    docker build -t $DOCKER_IMAGE -f Dockerfile .
                    '''
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'dockerhub-credentials', variable: 'DOCKER_HUB_PASS')]) {
                        sh '''
                        echo "$DOCKER_HUB_PASS" | docker login -u "aadityadesai" --password-stdin
                        '''
                    }
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    sh '''
                    echo "Pushing Docker Image to Docker Hub..."
                    docker push $DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Start Minikube') {
            steps {
                script {
                    sh '''
                    echo "Starting Minikube..."
                    minikube start --driver=docker
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                    echo "Deploying to Kubernetes..."
                    kubectl apply -f k8s/deployment.yml
                    kubectl apply -f k8s/service.yml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build and Deployment Successful!'
        }
        failure {
            echo '❌ Build or Deployment Failed!'
        }
    }
}
