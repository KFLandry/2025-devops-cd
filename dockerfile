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
ARG WAR_FILE=target/tp-cd-2025-0.0.1-SNAPSHOT.war
RUN java -Djarmode=layertools -jar ${WAR_FILE} extract --destination /workspace/extracted

FROM eclipse-temurin:21-jre
LABEL wl.maintainer='Wilfried Landry <kankeulandry22@gmail.com>'
ARG EXTRACTED=/workspace/extracted
WORKDIR /runtime/app
COPY --from=build ${EXTRACTED}/dependencies/ ./
COPY --from=build ${EXTRACTED}/spring-boot-loader/ ./
COPY --from=build ${EXTRACTED}/snapshot-dependencies/ ./
COPY --from=build ${EXTRACTED}/application/ ./

ENV TZ="Europe/Paris"

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java -cp /runtime/app org.springframework.boot.loader.WarLauncher"]