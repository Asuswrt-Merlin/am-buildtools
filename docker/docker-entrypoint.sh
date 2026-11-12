#!/bin/bash

export TOOLCHAIN_BASE=/opt/toolchains

# Legacy ARM (2.6.36 kernel)
PATH=$PATH:/opt/brcm-arm/bin

# HND 4.1 kernel, gcc 5.3
PATH=$PATH:/opt/toolchains/crosstools-arm-gcc-5.3-linux-4.1-glibc-2.22-binutils-2.25/usr/bin
PATH=$PATH:/opt/toolchains/crosstools-aarch64-gcc-5.3-linux-4.1-glibc-2.22-binutils-2.25/usr/bin
LD_LIBRARY_PATH=/opt/toolchains/crosstools-arm-gcc-5.3-linux-4.1-glibc-2.22-binutils-2.25/usr/lib

# HND 4.1 kernel, gcc 5.5
PATH=$PATH:/opt/toolchains/crosstools-aarch64-gcc-5.5-linux-4.1-glibc-2.26-binutils-2.28.1/usr/bin
PATH=$PATH:/opt/toolchains/crosstools-arm-gcc-5.5-linux-4.1-glibc-2.26-binutils-2.28.1/usr/bin
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/toolchains/crosstools-arm-gcc-5.5-linux-4.1-glibc-2.26-binutils-2.28.1/usr/lib

# HND 5.04 (4.19 kernel)
PATH=$PATH:/opt/toolchains/crosstools-aarch64-gcc-9.2-linux-4.19-glibc-2.30-binutils-2.32/usr/bin
PATH=$PATH:/opt/toolchains/crosstools-arm-gcc-9.2-linux-4.19-glibc-2.30-binutils-2.32/usr/bin
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/toolchains/crosstools-arm-gcc-9.2-linux-4.19-glibc-2.30-binutils-2.32/usr/lib

export PATH LD_LIBRARY_PATH

exec "$@"
