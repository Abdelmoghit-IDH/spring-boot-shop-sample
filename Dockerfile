FROM openjdk:11
ARG JAR_FILE=./target/*.jar
WORKDIR /usr/src/app
EXPOSE 8080
COPY ${JAR_FILE} ./app.jar
ENTRYPOINT ["java","-jar","./app.jar"]
