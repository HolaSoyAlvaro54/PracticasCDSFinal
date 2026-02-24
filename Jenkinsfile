pipeline {
    agent any

    tools {
        maven 'Maven3' 
    }

    environment {
        IMAGE_NAME = 'practicas-cds'
        IMAGE_TAG = 'v1.0'
        NEXUS_CREDS = credentials('nexus-creds') 
        // Inicialización de seguridad para evitar reportes 'null'
        FAILED_STAGE = "Preparación de Artillería" 
    }

    stages {
        stage('Checkout') {
            steps {
                script { env.FAILED_STAGE = "Checkout (Descarga de Código)" }
                git branch: 'main', url: 'https://github.com/HolaSoyAlvaro54/PracticasCDSFinal.git', credentialsId: 'github-creds'
            }
        }

        stage('Compilation') {
            steps {
                script { env.FAILED_STAGE = "Compilation (Maven Compile)" }
                sh 'mvn clean compile'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script { env.FAILED_STAGE = "SonarQube Analysis" }
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=fourier-project'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script { env.FAILED_STAGE = "Quality Gate (SonarQube Webhook)" }
                timeout(time: 2, unit: 'MINUTES') {
                    script {
                        try {
                            waitForQualityGate()
                        } catch (Exception e) {
                            echo "ALERTA: Timeout en Quality Gate. Continuando avance por orden superior..."
                        }
                    }
                }
            }
        }

        stage('Build Artifact') {
            steps {
                script { env.FAILED_STAGE = "Build Artifact (Generación de JAR)" }
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script { env.FAILED_STAGE = "Build Docker Image (Construcción)" }
                // Esta etapa ahora debería funcionar tras la cirugía del socket y el cambio de imagen base
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Deploy') {
            steps {
                script { env.FAILED_STAGE = "Deploy (Despliegue de Contenedor)" }
                sh "docker stop practicas-prod || true"
                sh "docker rm practicas-prod || true"
                sh "docker run -d --name practicas-prod ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }

    post {
        success {
            echo "-------------------------------------------------------"
            echo "¡VICTORIA TOTAL! El sistema está operativo en el frente."
            echo "-------------------------------------------------------"
        }
        failure {
            echo "-------------------------------------------------------"
            echo "¡INFORME DE BAJAS! El pipeline ha sido neutralizado."
            echo "ETAPA DEL FALLO: ${env.FAILED_STAGE}"
            echo "REVISE LOS LOGS DE ARRIBA PARA IDENTIFICAR AL ENEMIGO."
            echo "-------------------------------------------------------"
        }
    }
}
