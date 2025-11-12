FROM alpine:latest

# Set environment variable defaults
ARG MINECRAFT_VERSION=latest

# Read .env file for environment variable changes
ENV MINECRAFT_VERSION=$MINECRAFT_VERSION

# Set working directory
WORKDIR /server

# Install required packages
RUN apk update && \
    apk add bash \
        curl \
        jq \
        openjdk21 \
        wget

# Copy bin scripts and make executable
COPY ./bin /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Copy required files
COPY ./server.properties .
COPY ./eula.txt .

# Set server properties
#RUN set-server-properties

# Download server jar file
RUN download-server-jar

ENTRYPOINT ["start-server"]
 
