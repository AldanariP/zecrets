FROM alpine AS builder

RUN /usr/bin/wget -q "https://github.com/tristanisham/zvm/releases/latest/download/zvm-linux-amd64.tar" -O zvm.tar
RUN tar -xf ./zvm.tar
RUN ./zvm install 0.15.2

WORKDIR /app
COPY build.zig build.zig.zon ./
COPY src src
RUN /root/.zvm/bin/zig build \
    -Doptimize=ReleaseSafe \
    -Dtarget=x86_64-linux-musl \
    -Dopenssl_lib_name=ssl \
    -Denvironment=production \
    -Dbuild_static=false

FROM scratch

COPY --from=builder /app/zig-out/bin/zecrets /
COPY public public

CMD ["/zecrets", "-b", "0.0.0.0"]
