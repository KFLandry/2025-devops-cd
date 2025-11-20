FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace
ARG JAR_FILE=gitlab-artifacts/build-ci/target/tp-cd-2025-0.0.1-SNAPSHOT.jar
COPY $JAR_FILE .
RUN java -Djarmode=layertools -jar tp-cd-2025-0.0.1-SNAPSHOT.jar extract --destination extracted


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


ENTRYPOINT ["java", "-jar", "/runtime/app/tcp-cd-2025-0.0.1-SNAPSHOT.jar"]
