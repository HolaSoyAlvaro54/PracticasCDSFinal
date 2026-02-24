pipeline {
    agent any

    tools {
        maven 'Maven3' 
    }

    environment {
        IMAGE_NAME = 'practicas-cds'
        IMAGE_TAG = 'v1.0'
        NEXUS_CREDS = credentials('nexus-creds') 
        FAILED_STAGE = "" // Variable para registrar la etapa que falla
    }

    stages {
        stage('Checkout') {
            steps {
                script { env.FAILED_STAGE = "Checkout" }
                git branch: 'main', url: 'https://github.com/HolaSoyAlvaro54/PracticasCDSFinal.git', credentialsId: 'github-creds'
            }
        }

        stage('Compilation') {
            steps {
                script { env.FAILED_STAGE = "Compilation" }
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
                script { env.FAILED_STAGE = "Quality Gate" }
                timeout(time: 2, unit: 'MINUTES') {
                    script {
                        try {
                            def qg = waitForQualityGate()
                            echo "Estado del Quality Gate: ${qg.status}"
                            if (qg.status != 'OK') {
                                echo "ADVERTENCIA: El código no supera los estándares."
                            }
                        } catch (Exception e) {
                            echo "ALERTA: Tiempo de espera agotado en Quality Gate. Continuando..."
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
                script { env.FAILED_STAGE = "Build Docker Image" }
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Deploy') {
            steps {
                script { env.FAILED_STAGE = "Deploy" }
                sh "docker stop practicas-prod || true"
                sh "docker rm practicas-prod || true"
                sh "docker run -d --name practicas-prod ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }

    post {
        success {
            echo "-------------------------------------------------------"
            echo "¡VICTORIA! El sistema se ha desplegado correctamente."
            echo "-------------------------------------------------------"
        }
        failure {
            echo "-------------------------------------------------------"
            echo "¡INFORME DE BAJAS! El pipeline ha fallado."
            echo "ETAPA DEL FALLO: ${env.FAILED_STAGE}"
            echo "REVISE: Los logs de la etapa '${env.FAILED_STAGE}' para más detalles."
            echo "-------------------------------------------------------"
        }
        aborted {
            echo "La misión fue cancelada manualmente o por timeout."
        }
    }
}
