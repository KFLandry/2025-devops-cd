FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace

COPY . .

RUN ./mvnw clean package -DskipTests

COPY target .

RUN java -Djarmode=layertools -jar target/tp-cd-2025-0.0.1-SNAPSHOT.jar extract --destination extracted


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
