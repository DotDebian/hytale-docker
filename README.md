# Hytale Server - Docker Edition

This repository provides fully automated Docker containerization for Hytale dedicated servers. Just run one command and you're ready to play!

## Why This Docker Setup?

- **Zero Manual Setup** - Run `./start.sh` and you're done
- **Auto-Download** - Server files downloaded automatically on first start
- **Persistent Credentials** - Authenticate once, never again
- **One-Command Updates** - Delete files, restart container
- **Production Ready** - Resource limits, health checks, proper logging
- **Easy Configuration** - Simple `.env` file for all settings
- **Interactive Script** - Guides you through setup and management

## Prerequisites

- Docker (20.10+)
- Docker Compose (2.0+)
- Valid Hytale game license
- ~4GB disk space for server files
- ~4GB RAM minimum (8GB recommended)

## Quick Start (Automated Setup)

### Method 1: Using the Quick Start Script (Easiest)

Just run:

```bash
./start.sh
```

The interactive script will:
- Check prerequisites
- Create .env with defaults (optional)
- Start the server
- Guide you through first-time setup
- Show logs automatically

### Method 2: Direct Docker Compose

**1. (Optional) Configure Settings**

For default settings, skip this step. To customize:

```bash
cp .env.example .env
nano .env  # Edit configuration
```

Available settings:
- Memory allocation
- Server port
- Auto-download toggle
- AOT cache
- And more...

**2. Start the Server**

```bash
docker-compose up -d
```

The first time you run this command:
1. Docker will build the image (includes Hytale downloader CLI)
2. The server will automatically download the latest game files
3. You'll be prompted to authenticate with your Hytale account

### 2. First-Time Authentication

During the first startup, follow the on-screen instructions:

1. Watch the logs:
   ```bash
   docker-compose logs -f
   ```

2. You'll see a device authentication URL and code. Visit the URL in your browser and enter the code.

3. Once authenticated, credentials are saved and the server will start automatically.

4. Future restarts will use saved credentials - no need to re-authenticate!

### 3. Server Ready!

Once you see "Server started" in the logs, your server is ready for players to connect.

**Connect using:** `your-server-ip:5520`

## Alternative: Manual Setup (No Auto-Download)

If you prefer to provide server files manually:

### 1. Obtain Server Files

Find the files in your launcher installation folder:

**Windows:** `%appdata%\Hytale\install\release\package\game\latest`
**Linux:** `$XDG_DATA_HOME/Hytale/install/release/package/game/latest`
**MacOS:** `~/Application Support/Hytale/install/release/package/game/latest`

Copy the `Server` folder and `Assets.zip` to your project directory.

### 2. Disable Auto-Download

Edit `docker-compose.yml`:

```yaml
environment:
  AUTO_DOWNLOAD: "false"  # Changed from "true"
```

Uncomment the volume mounts:

```yaml
volumes:
  # Uncomment these:
  - ./Server:/hytale/Server:ro
  - ./Assets.zip:/hytale/Assets.zip:ro
```

### 3. Start the Server

```bash
docker-compose up -d
```

### 4. Authenticate

```bash
docker attach hytale-server
# In console: /auth login device
# Follow on-screen instructions
# Detach with Ctrl+P then Ctrl+Q
```

## Directory Structure

After cloning/downloading this repository:

```
hytale-server/
├── start.sh                         # Quick start script (recommended)
├── docker-compose.yml               # Docker Compose configuration
├── Dockerfile                       # Docker image definition
├── docker-entrypoint.sh             # Container startup script
├── .dockerignore                    # Files to exclude from build
├── .env.example                     # Configuration template
├── .env                             # Your configuration (created from .env.example)
├── README.md                        # This file
├── docs/                            # Documentation
└── data/                            # Created automatically on first run
    ├── downloads/                   # Downloaded files & credentials
    │   ├── .hytale-credentials     # Saved OAuth credentials
    │   ├── Server/                 # Downloaded server files
    │   └── Assets.zip              # Downloaded assets
    ├── universe/                    # World saves
    ├── logs/                        # Server logs
    ├── mods/                        # Place your mods here
    └── cache/                       # Server cache files
```

## How Auto-Download Works

When `AUTO_DOWNLOAD=true` (default):

1. **First Start:**
   - Downloads Hytale Downloader CLI during Docker build
   - On container start, checks if Server files exist
   - If not found, prompts for OAuth authentication
   - Downloads latest game files (~3GB)
   - Extracts and prepares server
   - Saves credentials in `/data/downloads/.hytale-credentials`

2. **Subsequent Starts:**
   - Uses saved credentials (no re-authentication needed)
   - Only downloads if files are missing
   - Instant startup if files already exist

3. **Benefits:**
   - Zero manual setup required
   - Always get latest version
   - Credentials persist across container restarts
   - Easy to update (just delete files and restart)

4. **Security:**
   - Credentials stored in Docker volume (not in image)
   - OAuth device flow (no password exposure)
   - Can be disabled if you prefer manual file management

## Configuration

### Using .env File (Recommended)

The easiest way to configure your server:

```bash
cp .env.example .env
nano .env  # Edit your settings
docker-compose up -d
```

All settings are documented in `.env.example` with examples.

### Environment Variables

Available configuration options:

| Variable | Default | Description |
|----------|---------|-------------|
| `AUTO_DOWNLOAD` | `true` | Automatically download server files on first start |
| `JAVA_OPTS` | `-Xms2G -Xmx4G ...` | JVM heap size and GC options |
| `SERVER_OPTS` | `--assets Assets.zip --bind 0.0.0.0:5520` | Hytale server arguments |
| `AOT_CACHE` | (disabled) | Enable AOT cache: `-XX:AOTCache=Server/HytaleServer.aot` |
| `DISABLE_SENTRY` | (disabled) | Set to `true` to disable crash reporting |

### Memory Configuration

Adjust memory allocation based on your player count and view distance:

```yaml
environment:
  JAVA_OPTS: "-Xms4G -Xmx8G -XX:+UseG1GC"
```

```yaml
deploy:
  resources:
    limits:
      memory: 10G
```

### Port Configuration

To change the server port, update both the environment variable and port mapping:

```yaml
environment:
  SERVER_OPTS: "--assets Assets.zip --bind 0.0.0.0:25565"
ports:
  - "25565:25565/udp"
```

## Managing Your Server

### View Logs

```bash
docker-compose logs -f
```

Or view persistent logs:
```bash
tail -f data/logs/latest.log
```

### Access Console

```bash
docker attach hytale-server
```

To detach without stopping: `Ctrl+P` then `Ctrl+Q`

### Restart Server

```bash
docker-compose restart
```

### Stop Server

```bash
docker-compose stop
```

### Update Server

With auto-download enabled, updates are automatic:

```bash
# Force re-download of latest version
docker-compose down
rm -rf data/downloads/Server data/downloads/Assets.zip
docker-compose up -d
```

Or manually:
1. Download new server files
2. Replace `Server/` directory and `Assets.zip` (if using manual mode)
3. Restart:
   ```bash
   docker-compose restart
   ```

## Installing Mods

Place mod files (`.zip` or `.jar`) in the `data/mods/` directory:

```bash
cp my-mod.jar data/mods/
docker-compose restart
```

## Advanced Usage

### Building the Image Manually

```bash
docker build -t hytale-server:custom .
```

### Running Without Docker Compose

With auto-download:

```bash
docker run -d \
  --name hytale-server \
  -p 5520:5520/udp \
  -v $(pwd)/data/downloads:/hytale/downloads \
  -v $(pwd)/data/universe:/hytale/universe \
  -v $(pwd)/data/logs:/hytale/logs \
  -v $(pwd)/data/mods:/hytale/mods \
  -v $(pwd)/data/cache:/hytale/.cache \
  -e AUTO_DOWNLOAD=true \
  -e JAVA_OPTS="-Xms2G -Xmx4G" \
  -it \
  hytale-server:latest
```

Without auto-download (manual files):

```bash
docker run -d \
  --name hytale-server \
  -p 5520:5520/udp \
  -v $(pwd)/Server:/hytale/Server:ro \
  -v $(pwd)/Assets.zip:/hytale/Assets.zip:ro \
  -v $(pwd)/data/universe:/hytale/universe \
  -v $(pwd)/data/logs:/hytale/logs \
  -v $(pwd)/data/mods:/hytale/mods \
  -v $(pwd)/data/cache:/hytale/.cache \
  -e AUTO_DOWNLOAD=false \
  -e JAVA_OPTS="-Xms2G -Xmx4G" \
  hytale-server:latest
```

### Enable AOT Cache

Uncomment in `docker-compose.yml`:

```yaml
environment:
  AOT_CACHE: "-XX:AOTCache=Server/HytaleServer.aot"
```

This improves startup time by ~30-50%.

### Additional Server Arguments

Pass extra arguments through `SERVER_OPTS`:

```yaml
environment:
  SERVER_OPTS: "--assets Assets.zip --bind 0.0.0.0:5520 --backup --backup-frequency 60"
```

Available arguments (see all with `--help`):
- `--accept-early-plugins` - Allow early plugins (unsupported)
- `--allow-op` - Enable operator permissions
- `--auth-mode <authenticated|offline>` - Authentication mode
- `--backup` - Enable automatic backups
- `--backup-dir <path>` - Backup directory
- `--backup-frequency <minutes>` - Backup interval

## Monitoring

### Resource Usage

```bash
docker stats hytale-server
```

### Recommended Plugins

Install these community plugins for better monitoring:

- [Nitrado:Query](https://github.com/nitrado/hytale-plugin-query) - HTTP status API
- [Nitrado:WebServer](https://github.com/nitrado/hytale-plugin-webserver) - Web API base
- [ApexHosting:PrometheusExporter](https://github.com/apexhosting/hytale-plugin-prometheus) - Metrics

## Networking

### Firewall Configuration

Hytale uses **UDP** (QUIC protocol), not TCP. Ensure your firewall allows UDP traffic:

**Linux (ufw):**
```bash
sudo ufw allow 5520/udp
```

**Linux (iptables):**
```bash
sudo iptables -A INPUT -p udp --dport 5520 -j ACCEPT
```

### Port Forwarding

If running behind a router, forward **UDP port 5520** to your server's local IP.

### Multiple Servers

To run multiple servers, duplicate `docker-compose.yml` with different ports:

```yaml
ports:
  - "5521:5520/udp"
```

## Troubleshooting

### Auto-Download Authentication Times Out

If OAuth authentication expires (15 minutes):
```bash
docker-compose restart
# Complete authentication faster this time
```

### Download Fails or Corrupted Files

Clear downloads and retry:
```bash
docker-compose down
rm -rf data/downloads/*
docker-compose up -d
```

### Want to Switch Between Auto/Manual Mode

**To Auto:** Set `AUTO_DOWNLOAD=true` and remove Server/Assets volume mounts

**To Manual:** Set `AUTO_DOWNLOAD=false`, add volume mounts, copy files locally

### Container Exits Immediately

Check logs for details:
```bash
docker-compose logs
```

Common causes:
- Authentication required (follow OAuth prompts)
- Download failed (check internet connection)
- Missing credentials (re-authenticate)

### High Memory Usage

Reduce view distance or allocated memory:
```yaml
environment:
  JAVA_OPTS: "-Xms1G -Xmx3G"
  SERVER_OPTS: "--assets Assets.zip --max-view-distance 8"
```

### Authentication Fails

Ensure you have a valid Hytale license and haven't exceeded the 100 server limit. For more servers, see the [Server Provider Authentication Guide](https://support.hytale.com/hc/en-us/articles/45328341414043).

### Players Can't Connect

1. Verify port forwarding (UDP, not TCP)
2. Check firewall rules
3. Confirm server is running: `docker ps`
4. Test local connection first

## Performance Tips

1. **Limit View Distance**: Default 12 chunks (384 blocks) recommended
2. **Enable AOT Cache**: Faster startup times
3. **Use G1GC**: Already configured in default `JAVA_OPTS`
4. **Monitor Resources**: Use `docker stats` to watch RAM/CPU
5. **Install Performance Plugins**: Nitrado:PerformanceSaver

## Backup Strategy

Enable automatic backups:

```yaml
environment:
  SERVER_OPTS: "--assets Assets.zip --backup --backup-dir /hytale/backups --backup-frequency 30"
volumes:
  - ./data/backups:/hytale/backups
```

Or manually backup the `data/` directory:
```bash
tar -czf backup-$(date +%Y%m%d).tar.gz data/
```

## License Limits

Each Hytale license allows **100 authenticated servers**. If you need more:

1. Purchase additional licenses
2. Apply for a Server Provider account ([Guide](https://support.hytale.com/hc/en-us/articles/45328341414043))

## Support

- Official Manual: [Hytale Server Manual](https://support.hytale.com/hc/en-us/articles/45326769420827)
- Community: [Discord](https://discord.gg/hytale)
- Mods: [CurseForge](https://www.curseforge.com/hytale)

## Credits

Docker implementation based on the official Hytale Server Manual by Hypixel Studios.
