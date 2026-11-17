pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    environment {
        DOCKER_CREDENTIALS_ID = 'docker-cred'
        DOCKER_IMAGE          = 'sruthijj/new-test'
        SONAR_SERVER_NAME     = 'Sonarqube_env'
        SONAR_SCANNER_TOOL    = 'sonar-scanner'
        GIT_CREDENTIALS_ID    = 'github-cred'
        MANIFEST_REPO         = 'https://github.com/sruthijj/New-Test.git'
        MANIFEST_BRANCH       = 'main'
        MANIFEST_FILE         = 'manifests/deployment.yaml'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool "${SONAR_SCANNER_TOOL}"
                    withSonarQubeEnv("${SONAR_SERVER_NAME}") {
                        sh "${scannerHome}/bin/sonar-scanner \
                            -Dsonar.host.url=http://localhost:9000 \
                            -Dsonar.projectKey=new-test-key \
                            -Dsonar.projectName='new-test-project' \
                            -Dsonar.sources=."
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        def appImage = docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
                        appImage.push()
                        appImage.push('latest')
                    }
                }
            }
        }

        stage('Update Manifest Repo') {
            steps {
                dir('manifest-workspace') {
                    git branch: "${MANIFEST_BRANCH}",
                        credentialsId: "${GIT_CREDENTIALS_ID}",
                        url: "${MANIFEST_REPO}"

                    withCredentials([usernamePassword(
                            credentialsId: "${GIT_CREDENTIALS_ID}",
                            usernameVariable: 'GIT_USER',
                            passwordVariable: 'GIT_PASS')]) {
                        sh '''
                            set -e

                            if [ ! -f "$MANIFEST_FILE" ]; then
                                echo "ERROR: $MANIFEST_FILE not found in manifest repo"
                                exit 1
                            fi

                            # Update the image tag in the manifest (handles placeholder or existing tags)
                            if grep -q "IMAGE_PLACEHOLDER" "$MANIFEST_FILE"; then
                                sed -i "s|image:.*IMAGE_PLACEHOLDER.*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|" "$MANIFEST_FILE"
                            else
                                sed -i "s|image:.*${DOCKER_IMAGE}.*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|" "$MANIFEST_FILE"
                            fi

                            if git diff --quiet; then
                                echo "No manifest changes to commit."
                            else
                                git -c user.name="Jenkins CI" -c user.email="jenkins@ci.local" \
                                    commit -am "chore(manifest): update ${DOCKER_IMAGE} image tag to ${BUILD_NUMBER} [skip ci]"
                                git push "https://${GIT_USER}:${GIT_PASS}@${MANIFEST_REPO#https://}" "HEAD:${MANIFEST_BRANCH}"
                            fi
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully! Manifest repo updated with new image tag.'
        }
        failure {
            echo 'Pipeline failed. Please review the stage logs above.'
        }
    }
}
