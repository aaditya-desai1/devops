pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'node-app'       // Docker Image Name
        DOCKER_TAG = 'latest'           // Docker Tag
    }

    stages {

        // ---------------- Stage 1: Clone Repository ----------------
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/aaditya-desai1/devops.git'
            }
        }

        // ---------------- Stage 2: Build Docker Image ----------------
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG .'
            }
        }

        // ---------------- Stage 3: Push to Minikube ----------------
        stage('Push to Minikube') {
            steps {
                script {
                    // Set Minikube environment variables
                    sh 'eval $(minikube docker-env)'
                    sh 'docker tag $DOCKER_IMAGE:$DOCKER_TAG $(minikube ip):5000/$DOCKER_IMAGE:$DOCKER_TAG'
                    sh 'docker push $(minikube ip):5000/$DOCKER_IMAGE:$DOCKER_TAG'
                }
            }
        }

        // ---------------- Stage 4: Deploy to Kubernetes ----------------
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yml'
            }
        }
    }

    // ---------------- Post-Build: Clean up ----------------
    post {
        always {
            sh 'docker system prune -f'
        }
    }
}
