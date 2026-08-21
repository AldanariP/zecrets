# Zecrets

Zecrets is a secure, ephemeral secret-sharing application built on a zero-knowledge architecture
with [Zig](https://ziglang.org/) and the [Datastar](https://data-star.dev/) web framework and
[http.zig](https://github.com/karlseguin/http.zig) as the HTTP server.
It allows users to share encrypted secrets that can be configured to expire after a certain time, at a certain date and after a single read.

## Requirements

- **Zig**: Version `0.16.0`
- **~~Docker & Docker Compose~~ Podman (see [issue#36278](https://codeberg.org/ziglang/zig/issues/36278))**: For containerized deployment.

## Running the Application

### Development Mode

**Run the server**:
   ```bash
   zig build run
   ```
   The application will be available at `http://localhost:3000` by default.

### Production Mode (Containerized)

To run the server using podman:

```bash
podman compose up --build -d
```
> Note: The port can be changed by setting the `PORT` environment variable.

## TODOs

- [ ] Add How-it-works page, About page.
- [ ] Add custom 404 page for burned secrets.