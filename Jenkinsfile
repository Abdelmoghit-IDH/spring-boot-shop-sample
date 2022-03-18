def NEXUS_SERVER
def VERSION

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
                    def version = matcher[0][1]
                    VERSION = "$version-$BUILD_NUMBER"
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
                    sh "docker build -t 'Shop:${VERSION}' ."
                    sh "docker tag 'Shop:${VERSION}' '${NEXUS_SERVER}/Shop:${VERSION}'"
                }
            }
        }

        stage("Push image"){

            steps{
                script {
                    withCredentials([usernamePassword(credentialsId: 'nexus-repository', passwordVariable: 'PWD', usernameVariable: 'USER')]) {
                       sh "docker login -u ${USER} -p ${PWD} ${NEXUS_SERVER}"
                       sh "docker push '${NEXUS_SERVER}/Shop:${VERSION}'" 
                    }
                }
            }
        }

        stage("Deploy project"){

            steps{
                script {
                    echo "Deploy to EC2 Amazon ..."
                }
            }
        }

        stage("Commit version update"){
            steps{
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-account', passwordVariable: 'PWD', usernameVariable: 'USER')]) {
                       sh "git remote set-url origin https://${USER}:${PWD}@github.com/Abdelmoghit-IDH//spring-boot-shop-sample.git"
                       sh "git add ."
                       sh "git commit -m 'change the version pox.xml to ${VERSION}'"
                       sh "git push origin HEAD:main"
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