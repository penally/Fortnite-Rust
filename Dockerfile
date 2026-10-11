
# Build stage
FROM rust:1-bookworm AS builder

WORKDIR /src

# Copy the workspace, including all local path dependencies.
COPY . .

# Build the inspection CLI in release mode.
RUN cargo build --release -p fn-inspect

# Runtime stage
FROM debian:bookworm-slim AS runtime

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --system --uid 10001 --create-home app \
    && mkdir -p /data/reports \
    && chown -R app:app /data

COPY --from=builder /src/target/release/fn-inspect /usr/local/bin/fn-inspect

ENV FN_ROOT=/data/fortnite
ENV FN_UE4_VERSION=516

USER app
WORKDIR /data

ENTRYPOINT ["fn-inspect"]
