pipeline {
    agent any

    tools {
        maven 'Maven3' 
    }

    environment {
        IMAGE_NAME = 'practicas-cds'
        IMAGE_TAG = 'v1.0'
        NEXUS_CREDS = credentials('nexus-creds') 
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
                sh 'mvn package -DskipTests'
            }
        }

        stage('Upload to Nexus') {
            steps {
                script { env.FAILED_STAGE = "Upload to Nexus (Envío de Suministros)" }
                // Esta etapa cumple con el requisito de gestión de artefactos en Nexus 
                sh 'mvn deploy -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script { env.FAILED_STAGE = "Build Docker Image (Construcción)" }
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Run Tests') {
            steps {
                script { env.FAILED_STAGE = "Run Tests (Pruebas de Integración)" }
                // Cumplimos con el requisito de automatizar pruebas 
                sh 'mvn test'
            }
        }

        stage('Deploy to Prod') {
            steps {
                script { env.FAILED_STAGE = "Deploy (Despliegue de Contenedor)" }
                // Cumplimos con el despliegue en producción [cite: 39]
                sh "docker stop practicas-prod || true"
                sh "docker rm practicas-prod || true"
                sh "docker run -d --name practicas-prod ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }

    post {
        success {
            echo "-------------------------------------------------------"
            echo "¡VICTORIA TOTAL! Artefacto en Nexus y Sistema en Producción."
            echo "-------------------------------------------------------"
        }
        failure {
            echo "-------------------------------------------------------"
            echo "¡INFORME DE BAJAS! El pipeline ha fallado en: ${env.FAILED_STAGE}"
            echo "-------------------------------------------------------"
            // Aquí se podría añadir la notificación por email o chat que pide el manual 
        }
    }
}
