FROM eclipse-temurin:25-jre-alpine 

# Set environment variable defaults
ARG MINECRAFT_VERSION=latest

# Read .env file for environment variable changes
ENV MINECRAFT_VERSION=$MINECRAFT_VERSION

WORKDIR /server

# Install required packages
RUN apk update && \
    apk add bash \
        curl \
        jq \
        wget

# Copy bin scripts and make executable
COPY ./bin /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Copy required files
COPY ./server.properties .
COPY ./eula.txt .

# Download server jar file
RUN download-fabric-jar

# Start the server and immediately stop it so that
# it exits cleanly after generating files.
RUN java -jar server.jar nogui > server.log 2>&1 & \
    PID=$!; \
    echo "Waiting for server to initialize..." && \
    while ! grep -q "Done" server.log; do sleep 1; done; \
    echo "Server initialized. Stopping..." && \
    kill -SIGTERM $PID && \
    wait $PID || true

# Download Floodgate and Geyser
RUN mkdir -p /server/plugins/Geyser-Spigot/ && \
    wget -O /server/plugins/floodgate.jar "https://modrinth.com/mod/floodgate" && \
    wget -O /server/plugins/geyser-spigot.jar "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/fabric"

# Copy Geyser config to container
COPY ./config.yaml ./plugins/Geyser-Spigot/config.yml

ENTRYPOINT ["start-server"]
 
