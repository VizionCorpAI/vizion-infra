FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dnsutils \
    git \
    jq \
    netcat-openbsd \
    postgresql-client \
    traceroute \
    wget \
    openssl \
    iproute2 \
    iputils-ping \
    procps \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspaces

CMD ["sleep", "infinity"]
