pipeline {
    agent any
    // escenarios -> escenario -> pasos
    environment{
        NPM_CONFIG_CACHE= "${WORKSPACE}/.npm"
        dockerImagePrefix = "us-west1-docker.pkg.dev/lab-agibiz/docker-repository"
        registry = "https://us-west1-docker.pkg.dev"
        registryCredentials = "gcp-registry"
    }
    stages{
        stage ("saludo a usuario") {
            steps {
                sh 'echo "comenzado mi pipeline"'
            }
        }
        stage ("salida de los saludos a usuario") {
            steps {
                sh 'echo "saliendo de este grupo de escenarios"'
            }
        }
        stage ("proceso de build y test") {
            agent {
                docker {
                    image 'node:22'
                    reuseNode true
                }
            }
            stages {
                stage("instalacion de dependencias"){
                    steps {
                        sh 'npm ci'
                    }
                }
                stage("ejecucion de pruebas"){
                    steps {
                        sh 'npm run test:cov'
                    }
                }
                stage("construccion de la aplicacion"){
                    steps {
                        sh 'npm run build'
                    }
                }
            }
        }
        stage ("build y push de imagen docker"){
            steps {
                script {
                    docker.withRegistry("${registry}", registryCredentials ){
                        sh "docker build -t backend-nest-test-kcr ."
                        sh "docker tag backend-nest-test-kcr ${dockerImagePrefix}/backend-nest-test-kcr"
                        sh "docker tag backend-nest-test-kcr ${dockerImagePrefix}/backend-nest-test-kcr:${BUILD_NUMBER}"
                        sh "docker push ${dockerImagePrefix}/backend-nest-test-kcr"
                        sh "docker push ${dockerImagePrefix}/backend-nest-test-kcr:${BUILD_NUMBER}"
                    }
                }
            }
        }
        stage ("ejecución de actualización kubernetes") {
            agent {
                docker {
                    image 'alpine/k8s:1.30.2'
                    reuseNode true
                }
            }
            steps {
                withKubeConfig([credentialsId: 'gcp-kubeconfig']) {
                    sh "kubectl -n lab-kcr set image deployments/backend-nest-test-kcr backend-nest-test-kcr=${dockerImagePrefix}/backend-nest-test-kcr:${BUILD_NUMBER}"
                }
            }
        }
    }
}