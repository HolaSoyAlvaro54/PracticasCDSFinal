FROM openjdk:8-jdk-alpine
COPY target/practicas-cds-1.0-SNAPSHOT.jar /app/app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]