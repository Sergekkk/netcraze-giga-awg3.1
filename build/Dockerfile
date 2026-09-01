# Dockerfile for Keenetic Giga KN-1012 (MT7981) AmneziaWG v3 Builder
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libncurses5-dev \
    libncursesw5-dev \
    zlib1g-dev \
    gawk \
    flex \
    bison \
    pkg-config \
    unzip \
    rsync \
    file \
    python3 \
    python3-pip \
    wget \
    curl \
    bc \
    cpio \
    ca-certificates \
    xz-utils \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Non-root builder user
RUN useradd -m -s /bin/bash builder
USER builder
WORKDIR /home/builder

ENV WORKDIR=/home/builder/work
ENV OUTPUT_DIR=/home/builder/out

COPY --chown=builder:builder . /home/builder/build_src

CMD ["bash", "/home/builder/build_src/build.sh"]
