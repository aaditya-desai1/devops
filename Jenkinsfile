pipeline {
    agent {
        docker {
            image 'node:latest'
        }
    }

    environment {
        DOCKER_IMAGE = 'node-app'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/your-username/your-repo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push to Minikube') {
            steps {
                sh 'eval $(minikube docker-env) && docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yml'
            }
        }
    }
}
