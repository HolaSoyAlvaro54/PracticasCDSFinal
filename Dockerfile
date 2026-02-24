# Cambiamos la base obsoleta por una activa y segura
FROM eclipse-temurin:8-jdk-alpine

# Definimos el directorio de operaciones
WORKDIR /app

# Copiamos el artefacto JAR (asegúrese de que la ruta coincida con el éxito de Maven)
COPY target/practicas-cds-1.0-SNAPSHOT.jar app.jar

# Orden de ejecución al iniciar el contenedor
ENTRYPOINT ["java", "-jar", "app.jar"]
