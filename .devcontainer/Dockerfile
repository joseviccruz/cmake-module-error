#### Base Image
# FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu as setup-cpp-ubuntu
FROM ubuntu:22.04 as setup-cpp-ubuntu

# ARG CMAKE_VERSION='3.28.1'
# ARG NINJA_VERSION='1.11.1'

# RUN apt update && apt upgrade -y
RUN apt-get update -qq && \
    # install nodejs
    apt-get install -y --no-install-recommends git libgtest-dev nodejs npm && \
    # install setup-cpp
    npm install -g setup-cpp@v0.37.0 && \
    # install the compiler and tools
    setup-cpp \
        --nala true \
        --compiler llvm \
        --cmake true \
        --ninja true \
        --python true \
        --make true && \
    # cleanup
    nala autoremove -y && \
    nala autopurge -y && \
    apt-get clean && \
    nala clean --lists && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# COPY .devcontainer/scripts /tmp/scripts
# WORKDIR /tmp/scripts

# RUN bash g++.sh
# RUN bash llvm.sh
# RUN bash cmake.sh $CMAKE_VERSION
# RUN bash ninja.sh $NINJA_VERSION

# RUN bash googletest.sh '/opt'

# RUN rm -rf /tmp/scripts

ENTRYPOINT ["/bin/bash"]

#### Building (example)
FROM setup-cpp-ubuntu AS builder

COPY . /home/app
WORKDIR /home/app
RUN bash -c 'source ~/.cpprc \
    && make all'
ENTRYPOINT ["/bin/bash"]
