#
# Usage:
#
#     $ buildah bud --layers -t llama-cpp .
#     $ buildah images
#     $ podman run localhost/llama-cpp -h
#
# See original Dockerfiles [1].
#
# [1] https://raw.githubusercontent.com/ggerganov/llama.cpp/master/.devops/main.Dockerfile
ARG UBUNTU_VERSION=22.04

FROM ubuntu:$UBUNTU_VERSION as build

RUN apt-get update && \
    apt-get install -y build-essential git

WORKDIR /app

COPY . .

# Where do we get the sources from? We assume the sources are in
# ./llama.cpp:
RUN make -C llama.cpp -j$(nproc) server main

FROM ubuntu:$UBUNTU_VERSION as runtime

# /main: error while loading shared libraries: libgomp.so.1: cannot
# open shared object file: No such file or directory
RUN apt-get update && \
    apt-get install libgomp1

COPY --from=build /app/llama.cpp/main /main
COPY --from=build /app/llama.cpp/server /server

ENV LC_ALL=C.utf8

ENTRYPOINT [ "/main" ]
