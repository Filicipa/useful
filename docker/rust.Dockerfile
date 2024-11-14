FROM rust:1.77.2 AS builder
WORKDIR /app
RUN rustup target add x86_64-unknown-linux-gnu
COPY ./Cargo.toml ./Cargo.toml
COPY ./src ./src
RUN cargo build --target x86_64-unknown-linux-gnu --release

FROM debian:stable-slim AS runner
# Install required global package
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*
# Release name from Cargo.toml
COPY --from=builder /app/target/x86_64-unknown-linux-gnu/release/solana-mvrv-z-score /usr/local/bin/
CMD ["solana-mvrv-z-score"]

####################

FROM rust:alpine AS builder
RUN apk add build-base libressl-dev
WORKDIR /app
COPY ./ .
RUN cargo build --release

FROM alpine AS runner
RUN apk add ca-certificates
COPY --from=builder /app/target/release/solana-mvrv-z-score /
CMD ["/solana-mvrv-z-score"]

########################

FROM rust:alpine AS builder

RUN apk add --no-cache \
    build-base \
    pkgconfig \
    openssl-dev \
    openssl-libs-static \
    ca-certificates \
    rm -rf /var/cache/apk/*

WORKDIR /app
COPY ./ .
RUN cargo build --release

FROM scratch AS runner

COPY --from=builder /app/target/release/solana-mvrv-z-score /
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

CMD ["/solana-mvrv-z-score"]