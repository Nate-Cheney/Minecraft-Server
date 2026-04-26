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

# Download Paper server jar
RUN download-paper

# Start the server once to generate config files, then stop cleanly
#RUN java -jar server.jar nogui > server.log 2>&1 & \
#    PID=$!; \
#    echo "Waiting for server to initialize..." && \
#    while ! grep -q "Done" server.log; do sleep 1; done; \
#    echo "Server initialized. Stopping..." && \
#    kill -SIGTERM $PID && \
#    wait $PID || true

# Download geyser & floodgate
RUN download-geyser

# Copy Geyser config to container
COPY ./config.yml ./plugins/Geyser-Spigot/

ENTRYPOINT ["start-server"]
 
