def NEXUS_SERVER
def VERSION
def SERVER_IP
def MATCHER

pipeline {
    agent any
    tools {
        maven "Maven"
    }

    stages {
        stage("init"){

            steps{
                script {
                    NEXUS_SERVER = "68.183.216.191:8082"
                    SERVER_IP = "3.68.213.188"
                }
            }
        }

        stage("Increment version"){

            steps{
                script {
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit' 
                    def matcher = readFile("pom.xml") =~ '<version>(.+)</version>'
                     MATCHER = matcher[0][1]
                    VERSION = "$MATCHER-$BUILD_NUMBER"
                    echo "The version $VERSION"
                }
            }
        }

        stage("Build project"){

            steps{
                script {
                    sh 'mvn package'
                }
            }
        }

        stage("Build image"){
            steps{
                script {
                    sh "docker build -t 'shop:V${VERSION}' ."
                    sh "docker tag 'shop:V${VERSION}' '${NEXUS_SERVER}/shop:V${VERSION}'"
                }
            }
        }

        stage("Push image"){

            steps{
                script {
                    withCredentials([usernamePassword(credentialsId: 'nexus-repository', passwordVariable: 'PWD', usernameVariable: 'USER')]) {
                       sh "docker login -u ${USER} -p ${PWD} ${NEXUS_SERVER}"
                       sh "docker push '${NEXUS_SERVER}/shop:V${VERSION}'" 
                    }
                }
            }
        }

        stage("Deploy project"){

            steps{
                script {
                    def dockerCMD = "docker run -d -p 80:80 --name 'shop.$MATCHER' '${NEXUS_SERVER}/shop:V${VERSION}'"
                        sshagent(['ec2-server-key']) {
                             sh "ssh -o StrictHostKeyChecking=no ec2-user@${SERVER_IP} ${dockerCMD}"
                        }
                }
            }
        }

        stage("Commit version update"){
            steps{
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-account', passwordVariable: 'PWD', usernameVariable: 'USER')]) {
                       sh "git config --global user.email 'jenkins@example.com'"
                       sh "git config --global user.name 'Jenkins'"
                       sh "git config --list"

                       sh "git remote set-url origin https://${USER}:${PWD}@github.com/Abdelmoghit-IDH/spring-boot-shop-sample.git"
                       sh "git add ."
                       sh "git commit -m 'change the version pox.xml to ${VERSION}'"
                       sh "git push origin HEAD:master"
                    }
                }
            }
        }

        stage("Clean Up"){
            steps{
                script {
                    sh 'mvn clean'
                }
            }
        }
    }
}