pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    checkout scm
                }
            }
        }

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

        stage('Setup Kubernetes with k3d') {
            steps {
                script {
                    sh '''
                    echo "Installing kubectl if not already installed..."
                    if ! command -v kubectl &> /dev/null; then
                        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                        chmod +x kubectl
                        sudo mv kubectl /usr/local/bin/
                    fi

                    echo "Installing k3d if not already installed..."
                    if ! command -v k3d &> /dev/null; then
                        curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
                    fi

                    echo "Checking for existing clusters..."
                    if k3d cluster list | grep -q "jenkins-cluster"; then
                        echo "Deleting existing cluster..."
                        k3d cluster delete jenkins-cluster
                    fi

                    echo "Creating k3d cluster..."
                    k3d cluster create jenkins-cluster \
                        --api-port 6550 \
                        --port "8090:80@loadbalancer" \
                        --agents 1 \
                        --wait

                    echo "Waiting for cluster to be ready..."
                    sleep 10

                    echo "Updating kubeconfig and using correct context..."
                    export KUBECONFIG=$(k3d kubeconfig write jenkins-cluster)
                    kubectl config use-context k3d-jenkins-cluster

                    echo "Checking cluster health..."
                    kubectl cluster-info
                    kubectl get nodes
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                    echo "Deploying to Kubernetes..."
                    kubectl apply -f deployment.yml

                    echo "Waiting for deployment to be ready..."
                    kubectl rollout status deployment/nodejs-app --timeout=90s

                    echo "Showing running pods..."
                    kubectl get pods
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build and Deployment Successful!"
        }
        failure {
            echo "❌ Build or Deployment Failed!"
            script {
                sh '''
                echo "Cleaning up if cluster exists..."
                if command -v k3d &> /dev/null; then
                    if k3d cluster list | grep -q "jenkins-cluster"; then
                        k3d cluster delete jenkins-cluster
                    fi
                fi
                '''
            }
        }
        always {
            sh 'docker system prune -f'
        }
    }
}
