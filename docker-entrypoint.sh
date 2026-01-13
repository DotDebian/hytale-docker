#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      Hytale Server - Docker Edition    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Function to download server files
download_server_files() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}  AUTO-DOWNLOAD: Server files not found ${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""

    # Check if credentials exist
    if [ ! -f "/hytale/downloads/.hytale-credentials" ]; then
        echo -e "${YELLOW}First time setup - OAuth authentication required${NC}"
        echo ""
        echo -e "${GREEN}Starting authentication process...${NC}"
        echo ""

        cd /hytale/downloads
        /hytale/hytale-downloader -download-path game.zip

        # Save credentials for next time
        if [ -f "$HOME/.hytale-credentials" ]; then
            cp "$HOME/.hytale-credentials" /hytale/downloads/.hytale-credentials
            echo -e "${GREEN}✓ Credentials saved for future use${NC}"
        fi
    else
        echo -e "${GREEN}Using saved credentials...${NC}"
        cp /hytale/downloads/.hytale-credentials "$HOME/.hytale-credentials"
        cd /hytale/downloads
        /hytale/hytale-downloader -download-path game.zip
    fi

    echo ""
    echo -e "${GREEN}Extracting server files...${NC}"
    unzip -q game.zip -d /hytale/downloads/extracted

    # Copy files to proper locations
    if [ -d "/hytale/downloads/extracted/Server" ]; then
        cp -r /hytale/downloads/extracted/Server /hytale/
        echo -e "${GREEN}✓ Server files extracted${NC}"
    fi

    if [ -f "/hytale/downloads/extracted/Assets.zip" ]; then
        cp /hytale/downloads/extracted/Assets.zip /hytale/
        echo -e "${GREEN}✓ Assets extracted${NC}"
    fi

    # Cleanup
    rm -f /hytale/downloads/game.zip
    rm -rf /hytale/downloads/extracted

    echo -e "${GREEN}✓ Download complete!${NC}"
    echo ""
}

# Check if server files exist, download if needed
if [ ! -f "Server/HytaleServer.jar" ] || [ ! -f "Assets.zip" ]; then
    if [ "${AUTO_DOWNLOAD}" = "true" ]; then
        download_server_files
    else
        echo -e "${RED}ERROR: Server files not found${NC}"
        echo -e "${YELLOW}Either:${NC}"
        echo -e "${YELLOW}1. Set AUTO_DOWNLOAD=true to download automatically${NC}"
        echo -e "${YELLOW}2. Mount Server/ and Assets.zip manually${NC}"
        exit 1
    fi
fi

# Final check
if [ ! -f "Server/HytaleServer.jar" ]; then
    echo -e "${RED}ERROR: HytaleServer.jar not found after download${NC}"
    exit 1
fi

if [ ! -f "Assets.zip" ]; then
    echo -e "${RED}ERROR: Assets.zip not found after download${NC}"
    exit 1
fi

# Display Java version
echo -e "${GREEN}Java Version:${NC}"
java --version
echo ""

# Build Java command
JAVA_CMD="java"

# Add Java options
if [ -n "$JAVA_OPTS" ]; then
    JAVA_CMD="$JAVA_CMD $JAVA_OPTS"
    echo -e "${GREEN}Java Options:${NC} $JAVA_OPTS"
fi

# Add AOT cache if specified and file exists
if [ -n "$AOT_CACHE" ] && [ -f "Server/HytaleServer.aot" ]; then
    JAVA_CMD="$JAVA_CMD $AOT_CACHE"
    echo -e "${GREEN}AOT Cache:${NC} Enabled"
elif [ -f "Server/HytaleServer.aot" ]; then
    echo -e "${YELLOW}AOT Cache available but not enabled. Set AOT_CACHE env var to enable.${NC}"
fi

# Add the JAR
JAVA_CMD="$JAVA_CMD -jar Server/HytaleServer.jar"

# Add server options
if [ -n "$SERVER_OPTS" ]; then
    JAVA_CMD="$JAVA_CMD $SERVER_OPTS"
else
    JAVA_CMD="$JAVA_CMD --assets Assets.zip"
fi

# Add disable-sentry if requested
if [ "$DISABLE_SENTRY" = "true" ]; then
    JAVA_CMD="$JAVA_CMD --disable-sentry"
    echo -e "${YELLOW}Sentry crash reporting:${NC} Disabled"
fi

# Add any additional arguments passed to the container
if [ $# -gt 0 ]; then
    JAVA_CMD="$JAVA_CMD $@"
fi

echo ""
echo -e "${GREEN}Starting Hytale Server...${NC}"
echo -e "${GREEN}Command:${NC} $JAVA_CMD"
echo ""
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}AUTHENTICATION REQUIRED ON FIRST START${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}After first launch, you need to authenticate:${NC}"
echo -e "${YELLOW}1. In the console, run: /auth login device${NC}"
echo -e "${YELLOW}2. Visit the provided URL in your browser${NC}"
echo -e "${YELLOW}3. Enter the code shown${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo ""

# Execute the command
exec $JAVA_CMD
