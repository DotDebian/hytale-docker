#!/bin/bash

# Hytale Server - Quick Start Script
# This script helps you get started with your Hytale server quickly

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════╗"
echo "║     Hytale Server - Quick Start Script        ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}ERROR: Docker is not installed${NC}"
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}ERROR: Docker Compose is not installed${NC}"
    echo "Please install Docker Compose from: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✓ Docker is installed${NC}"
echo ""

# Check if .env exists, if not offer to create it
if [ ! -f .env ]; then
    echo -e "${YELLOW}No .env file found${NC}"
    echo ""
    read -p "Would you like to create one with default settings? (Y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        cp .env.example .env
        echo -e "${GREEN}✓ Created .env with default settings${NC}"
        echo -e "${YELLOW}You can customize settings by editing .env${NC}"
        echo ""
    fi
fi

# Check if server is already running
if docker ps | grep -q hytale-server; then
    echo -e "${YELLOW}Server is already running!${NC}"
    echo ""
    echo "Available actions:"
    echo "  1) View logs"
    echo "  2) Restart server"
    echo "  3) Stop server"
    echo "  4) Access console"
    echo "  5) Exit"
    echo ""
    read -p "Choose an option (1-5): " -n 1 -r
    echo ""

    case $REPLY in
        1)
            echo -e "${GREEN}Showing logs (Ctrl+C to exit)...${NC}"
            docker-compose logs -f
            ;;
        2)
            echo -e "${GREEN}Restarting server...${NC}"
            docker-compose restart
            echo -e "${GREEN}✓ Server restarted${NC}"
            ;;
        3)
            echo -e "${YELLOW}Stopping server...${NC}"
            docker-compose stop
            echo -e "${GREEN}✓ Server stopped${NC}"
            ;;
        4)
            echo -e "${GREEN}Connecting to console...${NC}"
            echo -e "${YELLOW}Detach with: Ctrl+P then Ctrl+Q${NC}"
            sleep 2
            docker attach hytale-server
            ;;
        5)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
    exit 0
fi

# Start the server
echo -e "${GREEN}Starting Hytale Server...${NC}"
echo ""

# Build and start
docker-compose up -d --build

echo ""
echo -e "${GREEN}✓ Server container started!${NC}"
echo ""

# Show what's happening
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}  FIRST TIME SETUP - PLEASE READ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}The server is now starting. On first run:${NC}"
echo ""
echo "1. Server files will be downloaded automatically"
echo "2. You'll be prompted to authenticate with your Hytale account"
echo "3. Credentials will be saved for future starts"
echo ""
echo -e "${GREEN}To view logs and complete authentication:${NC}"
echo "  docker-compose logs -f"
echo ""
echo -e "${GREEN}To access server console:${NC}"
echo "  docker attach hytale-server"
echo "  (Detach with Ctrl+P then Ctrl+Q)"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

# Offer to show logs
read -p "Show logs now? (Y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    echo -e "${GREEN}Showing logs (Ctrl+C to exit)...${NC}"
    echo ""
    sleep 1
    docker-compose logs -f
fi
