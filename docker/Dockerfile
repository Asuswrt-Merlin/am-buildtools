# Build environment for Asuswrt-Merlin.
# Select the Ubuntu release with --build-arg UBUNTU_VERSION=20.04|22.04
ARG UBUNTU_VERSION=22.04
FROM ubuntu:${UBUNTU_VERSION}

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=UTC
ENV TZ=${TZ}
ENV SHELL=/bin/bash

# Build dependencies
RUN apt-get update && \
    apt-get install -y tzdata && \
    apt-get install -y \
        make gcc g++ build-essential xxd gdisk bc rsync sudo bsdmainutils git git-lfs \
        zip unzip wget curl \
        software-properties-common \
        libncurses5 libncurses5-dev m4 bison gawk flex gengetopt zlib1g-dev autoconf \
        autopoint libtool-bin shtool autogen mtd-utils intltool sharutils docbook-xsl-* \
        libstdc++5 texinfo dos2unix xsltproc u-boot-tools device-tree-compiler qemu gperf \
        liblzo2-dev uuid-dev lzma-dev liblzma-dev lzma binutils-dev patch \
        cmake libglib2.0-dev libssl-dev gtk-doc-tools libyaml-dev \
        libc6-i386 lib32stdc++6 lib32z1 libc6-dev-i386 \
        libpopt-dev cpio patchelf python3-packaging python-is-python3 python2 \
        golang && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get install -y git

# Google's repo tool
RUN curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo -o /usr/bin/repo && \
    chmod +x /usr/bin/repo

# Optional interactive conveniences, not needed for building
RUN apt-get install -y screen vim man-db manpages-posix gitk git-gui

# The firmware build scripts rely on bash-specific syntax in /bin/sh
RUN ln -sf bash /bin/sh

# Paths expected to exist for stock compile (or else sudo tries and fails to create them in stock GPL Makefile)
RUN mkdir -p /projects/bca/tools/linux/hndtools-armeabi-2013.11 \
             /projects/hnd/tools/linux/hndtools-armeabi-2011.09 \
             /projects/hnd/tools/linux/hndtools-armeabi-2013.11

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

LABEL org.opencontainers.image.title="fw-build" \
      org.opencontainers.image.description="Build environment for Asuswrt-Merlin firmware" \
      org.opencontainers.image.source="https://github.com/asuswrt-merlin/am-buildtools"

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
