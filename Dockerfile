FROM eclipse-temurin:25-jdk

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl unzip wget && \
    rm -rf /var/lib/apt/lists/*

# Create server directory
WORKDIR /hytale

# Download Hytale Downloader CLI
RUN wget https://downloader.hytale.com/hytale-downloader.zip && \
    unzip -q hytale-downloader.zip && \
    mv hytale-downloader-linux-amd64 hytale-downloader && \
    chmod +x hytale-downloader && \
    rm hytale-downloader.zip

# Create directories for persistent data
RUN mkdir -p /hytale/universe /hytale/logs /hytale/mods /hytale/.cache /hytale/downloads

# Expose UDP port for QUIC protocol
EXPOSE 5520/udp

# Set default Java options
ENV JAVA_OPTS="-Xms2G -Xmx4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200"
ENV SERVER_OPTS="--assets Assets.zip --bind 0.0.0.0:5520"
ENV AOT_CACHE=""

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD []
