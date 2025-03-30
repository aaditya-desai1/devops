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
        
        // ---------------- Stage 5: Install and Setup Kind ----------------
        stage('Setup Kind Cluster') {
            steps {
                script {
                    sh '''
                    echo "Installing Kind if not already installed..."
                    if ! command -v kind &> /dev/null; then
                        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
                        chmod +x ./kind
                        mv ./kind /usr/local/bin/
                    fi
                    
                    echo "Checking if cluster already exists..."
                    if kind get clusters | grep -q "jenkins-cluster"; then
                        echo "Deleting existing cluster..."
                        kind delete cluster --name jenkins-cluster
                    fi
                    
                    echo "Creating Kind cluster..."
                    kind create cluster --name jenkins-cluster --wait 5m
                    
                    echo "Verifying cluster is running..."
                    kubectl cluster-info
                    kubectl get nodes
                    '''
                }
            }
        }
        
        // ---------------- Stage 6: Deploy to Kubernetes ----------------
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                    echo "Loading Docker image into Kind..."
                    kind load docker-image aadityadesai/devops:latest --name jenkins-cluster
                    
                    echo "Deploying to Kubernetes..."
                    kubectl apply -f deployment.yml
                    
                    echo "Waiting for deployment to be ready..."
                    kubectl rollout status deployment/nodejs-app
                    
                    echo "Showing running pods..."
                    kubectl get pods
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
            
            // Clean up on failure
            script {
                sh '''
                echo "Cleaning up resources..."
                if command -v kind &> /dev/null; then
                    if kind get clusters | grep -q "jenkins-cluster"; then
                        kind delete cluster --name jenkins-cluster
                    fi
                fi
                '''
            }
        }
        always {
            // Clean up Docker images to save space
            sh 'docker system prune -f'
        }
    }
}
