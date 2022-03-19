FROM openjdk:11
ARG JAR_FILE=./target/*.jar
WORKDIR /usr/src/app
COPY ${JAR_FILE} ./app.jar
ENTRYPOINT ["java","-jar","./app.jar"]
