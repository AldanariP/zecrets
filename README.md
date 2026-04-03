# Zecrets

Zecrets is a secure, ephemeral secret-sharing application built on a zero-knowledge architecture 
with [Zig](https://ziglang.org/) and the [Jetzig](https://jetzig.dev/) web framework.
It allows users to share encrypted secrets that can be configured to expire after a certain time or after a single read.

## Requirements

- **Zig**: Version `0.15.2` (Recommended to use [zvm](https://github.com/tristanisham/zvm) for version management).
- **Jetzig ([Download](https://www.jetzig.dev/downloads))**: The app was developped using the CLI tool built from the ``zig-0.15``
branch of Jetzig, use other versions of at your own risk (CLI tool is not required for development).
- **Docker & Docker Compose**: For containerized deployment.

## Running the Application

### Development Mode

1. **Start Valkey**:
   ```bash
   docker compose up valkey -d
   ```

2. **Run the Jetzig server**:
   ```bash
   zig build run
   # or
   jetzig server
   # or
   zig build && ./zig-out/bin/zecrets
   ```
   The application will be available at `http://localhost:8080`.

### Production Mode (Docker)

To run the entire stack (Server + Valkey) using Docker Compose:

```bash
docker compose up --build -d
```

The server will be reachable at `http://localhost:8080`.
> Note: The Jetzig container needs to have access to an ``.env`` file containing the `JETZIG_SECRET` environment variable,
> use the ``jetzig generate secret`` command to generate a random secret string.

## TODOs

- [ ] Add How-it-works page, About page and Source link.
- [ ] Add custom 404 page for burned secrets.