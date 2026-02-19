pipeline {
    agent any

    environment {
        IMAGE_NAME = 'practicas-cds'
        IMAGE_TAG = 'v1.0'
        // Necesitas haber creado esta credencial en Jenkins antes
        NEXUS_CREDS = credentials('nexus-creds') 
    }

    stages {
        stage('Checkout') {
            steps {
                // Tu URL exacta
                git branch: 'main', url: 'https://github.com/HolaSoyAlvaro54/PracticasCDSFinal.git', credentialsId: 'github-creds'
            }
        }

        stage('Compilation') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    // El projectKey debe ser 'fourier-project' como creaste en SonarQube
                    sh 'mvn sonar:sonar -Dsonar.projectKey=fourier-project'
                }
            }
        }

                stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    // IMPORTANTE: Hemos añadido 'script' alrededor
                    script { 
                        def qg = waitForQualityGate()
                        echo "Quality Gate Status: ${qg.status}"
                    }
                }
            }
        }

        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Deploy') {
            steps {
                // Paramos el contenedor si existe para evitar errores
                sh "docker stop practicas-prod || true"
                sh "docker rm practicas-prod || true"
                sh "docker run -d --name practicas-prod ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }
    post {
        failure {
            echo "Fallo en el pipeline"
        }
    }
}