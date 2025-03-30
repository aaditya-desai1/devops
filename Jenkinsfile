pipeline {
    agent any  // Use any available Jenkins agent

    environment {
        DOCKER_IMAGE = 'node-app'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/aaditya-desai1/devops.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push to Minikube') {
            steps {
                sh '''
                eval $(minikube docker-env)
                docker build -t $DOCKER_IMAGE .
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yml'
            }
        }
    }
}
