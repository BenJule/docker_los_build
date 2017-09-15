#
# Minimum Docker image to build Android AOSP
#
FROM debian:latest

# Metainformation
LABEL name="los_build" \
      maintainer="benlue@s3root.ovh" \
      version="0.1"

ENV DEBIAN_FRONTEND noninteractive

# Build tools
RUN apt-get update && \
    apt-get -y --no-install-recommends install \
    apt-utils sudo openjdk-8-jdk python bc yasm rsync \
    schedtool imagemagick git-core gnupg flex bison \
    gperf build-essential zip curl zlib1g-dev \
    gcc-multilib g++-multilib libc6-dev-i386 \
    lib32ncurses5-dev x11proto-core-dev \
    libx11-dev lib32z-dev ccache libgl1-mesa-dev \
    libxml2-utils xsltproc \
    unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*
    
ADD https://commondatastorage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 755 /usr/local/bin/*

# Install latest version of JDK
# See http://source.android.com/source/initializing.html#setting-up-a-linux-build-environment
WORKDIR /tmp

# All builds will be done by user aosp
COPY gitconfig /root/.gitconfig
COPY ssh_config /root/.ssh/config

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/los"]

# Work in the build directory, repo is expected to be init'd here
WORKDIR /los

COPY utils/docker_entrypoint.sh /root/docker_entrypoint.sh
ENTRYPOINT ["/root/docker_entrypoint.sh"]