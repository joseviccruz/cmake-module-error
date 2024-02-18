FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

ARG CMAKE_VERSION='3.28.1'
ARG NINJA_VERSION='1.11.1'

RUN apt update && apt upgrade -y

COPY .devcontainer/scripts /tmp/scripts
WORKDIR /tmp/scripts

RUN bash g++.sh
RUN bash llvm.sh
RUN bash cmake.sh $CMAKE_VERSION
RUN bash ninja.sh $NINJA_VERSION

RUN bash googletest.sh '/opt'

RUN rm -rf /tmp/scripts
