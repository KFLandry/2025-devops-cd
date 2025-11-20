FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace

# cache layer: copy only wrapper + pom to download deps
COPY mvnw pom.xml ./
COPY .mvn .mvn
RUN chmod +x mvnw
RUN ./mvnw -B -DskipTests dependency:go-offline

# copy sources and build
COPY src ./src
COPY settings.xml ./
RUN ./mvnw -B -DskipTests package

# extract layers
ARG JAR_FILE=target/tp-cd-2025-0.0.1-SNAPSHOT.jar
RUN java -Djarmode=layers -jar ${JAR_FILE} extract --destination /workspace/extracted

FROM eclipse-temurin:21-jre
LABEL wl.maintainer='Wilfried Landry <kankeulandry22@gmail.com>'
ARG EXTRACTED=/workspace/extracted
WORKDIR /runtime/app
COPY --from=build ${EXTRACTED}/dependencies/ ./
COPY --from=build ${EXTRACTED}/spring-boot-loader/ ./
COPY --from=build ${EXTRACTED}/snapshot-dependencies/ ./
COPY --from=build ${EXTRACTED}/application/ ./
WORKDIR /runtime
ENV TZ="Europe/Paris"

EXPOSE 8080

ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
