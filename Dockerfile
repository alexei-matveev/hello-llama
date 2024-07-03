#
# Usage:
#
#     $ tag=3190
#     $ image=localhost/llama-cpp:$tag
#     $ buildah bud --layers --build-arg TAG=$tag -t $image .
#     $ buildah images
#     $ podman run --rm --entrypoint /llama-cli    $image -h
#     $ podman run --rm --entrypoint /llama-server $image -h
#
# With populated models/ run inference:
#
#     $ podman run --rm -v $PWD/models:/models --entrypoint /main $image -m models/ggml-model-q4_0.gguf --prompt "Once upon a time"
#
# or the API server:
#
#     $ podman run --rm -p 8080:8080 -v $PWD/models:/models $image -m models/ggml-model-q4_0.gguf -c 2048 --host 0.0.0.0
#
# Default  --host 127.0.0.1  ist  not sufficient  for  serving from  a
# container.  See  original Dockerfiles  [1].  Für LLAMA  versions see
# release tags [2]. Red Hat Catalog does not like direkt links, you'll
# need to search for "universal base image" for updates [3].
#
# [1] https://raw.githubusercontent.com/ggerganov/llama.cpp/master/.devops/main.Dockerfile
# [2] https://github.com/ggerganov/llama.cpp/releases
# [3] https://catalog.redhat.com/search?searchType=containers

ARG BASE_IMAGE=registry.access.redhat.com/ubi8:8.10 # ubi9:9.4
# Llama release:
ARG TAG=b3190
    # b3278 (broken?)
    # b3190 (llama-cli, llama-server)
    # b3078 (main, server)

FROM $BASE_IMAGE as build
ARG TAG

#UN apt-get update && apt-get install -y build-essential curl # git?
RUN dnf install -y gcc gcc-c++ make diffutils # git?

WORKDIR /app

# How do  we get  the sources  and supply  them to  Buildah/Docker? We
# assume the  sources are  in ./llama.cpp  as if  one cloned  the repo
# locally.   This  might  be  the  best  workflow  for  iterations  in
# development. Then  a simple  COPY would suffice,  see .dockerignore!
# FWIW, GitHub does not allow  "git archive --remote=..." but provides
# an  alternative  vor tarballs.   Is  a  message  "fatal: not  a  git
# repository (or any  of the parent directories): .git"  or even "git:
# command not found" during build a problem?
#
# COPY . .
RUN mkdir llama.cpp && \
    curl -sL https://github.com/ggerganov/llama.cpp/tarball/$TAG | tar zxf - -C llama.cpp/ --strip-components=1
RUN make -C llama.cpp -j$(nproc) llama-server llama-cli

FROM $BASE_IMAGE as runtime

# /main: error while loading shared libraries: libgomp.so.1: cannot
# open shared object file: No such file or directory
# RUN apt-get update && apt-get install libgomp1
RUN dnf install -y libgomp

# Does it work with --layers?
COPY --from=build /app/llama.cpp/llama-server /llama-cli
COPY --from=build /app/llama.cpp/llama-server /llama-server

ENV LC_ALL=C.utf8

ENTRYPOINT [ "/llama-server" ]
