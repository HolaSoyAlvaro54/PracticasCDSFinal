pipeline {
    agent any

    // 1. AÑADE ESTE BLOQUE PARA SOLUCIONAR EL ERROR "mvn: no encontrado"
    tools {
        // El nombre 'Maven3' debe coincidir con el nombre que configuraste
        // en "Administrar Jenkins" -> "Tools"
        maven 'Maven3' 
    }

    environment {
        IMAGE_NAME = 'practicas-cds'
        IMAGE_TAG = 'v1.0'
        NEXUS_CREDS = credentials('nexus-creds') 
    }

    stages {
        stage('Checkout') {
            steps {
                // Configuración de conexión segura a GitHub [cite: 22, 28]
                git branch: 'main', url: 'https://github.com/HolaSoyAlvaro54/PracticasCDSFinal.git', credentialsId: 'github-creds'
            }
        }

        stage('Compilation') {
            steps {
                // Etapa de compilación requerida [cite: 34]
                sh 'mvn clean compile'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                // Análisis de calidad de código con SonarQube [cite: 15, 30]
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=fourier-project'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // Notificación del estado de calidad para actuar en función del resultado [cite: 31]
                timeout(time: 5, unit: 'MINUTES') {
                    script { 
                        def qg = waitForQualityGate()
                        echo "Quality Gate Status: ${qg.status}"
                        if (qg.status != 'OK') {
                            error "Pipeline abortado debido a que no se superó el Quality Gate de SonarQube"
                        }
                    }
                }
            }
        }

        stage('Build Artifact') {
            steps {
                // Generación de artefactos (JAR/WAR) [cite: 36]
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Creación de imagen Docker con el artefacto [cite: 35]
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Deploy') {
            steps {
                // Despliegue en entorno de producción mediante contenedores [cite: 39]
                sh "docker stop practicas-prod || true"
                sh "docker rm practicas-prod || true"
                sh "docker run -d --name practicas-prod ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }
    
    post {
        failure {
            // Notificación de errores en la integración [cite: 38]
            echo "Fallo en el pipeline"
        }
    }
}
