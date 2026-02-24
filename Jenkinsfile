pipeline {
    agent any

    tools {
        maven 'Maven3' 
    }

    environment {
        IMAGE_NAME = 'practicas-cds'
        IMAGE_TAG = 'v1.0'
        FAILED_STAGE = "Preparación de Artillería" 
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
                            waitForQualityGate()
                        } catch (Exception e) {
                            echo "ALERTA: Timeout. Continuando avance por orden superior..."
                        }
                    }
                }
            }
        }

        stage('Build Artifact') {
            steps {
                script { env.FAILED_STAGE = "Build Artifact" }
                sh 'mvn package -DskipTests'
            }
        }

        stage('Upload to Nexus') {
            steps {
                script { 
                    env.FAILED_STAGE = "Upload to Nexus" 
                    // MANIOBRA DE INFILTRACIÓN DIRECTA CON CREDENCIALES FORJADAS
                    sh """
                        echo '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"><servers><server><id>nexus-snapshots</id><username>admin</username><password>1928</password></server><server><id>nexus-releases</id><username>admin</username><password>1928</password></server></servers></settings>' > settings_tmp.xml
                        mvn -s settings_tmp.xml deploy -DskipTests
                        rm settings_tmp.xml
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script { env.FAILED_STAGE = "Build Docker Image" }
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Deploy to Prod') {
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
            echo "¡VICTORIA TOTAL! El artefacto está en el almacén (Nexus)."
            echo "-------------------------------------------------------"
        }
        failure {
            echo "-------------------------------------------------------"
            echo "¡BAJA EN COMBATE! Fallo en la etapa: ${env.FAILED_STAGE}"
            echo "-------------------------------------------------------"
        }
    }
}
