FROM alpine AS builder

RUN /usr/bin/wget -q "https://github.com/tristanisham/zvm/releases/latest/download/zvm-linux-amd64.tar" -O zvm.tar
RUN tar -xf ./zvm.tar
RUN chmod +x ./zvm
RUN ./zvm install 0.16.0

WORKDIR /app
COPY build.zig build.zig.zon ./
COPY src src

RUN /root/.zvm/bin/zig build -Doptimize=ReleaseFast

FROM scratch

COPY --from=builder /app/zig-out/bin/zecrets /

CMD ["/zecrets"]
