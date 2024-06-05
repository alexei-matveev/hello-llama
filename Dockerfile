#
# Usage:
#
#     $ buildah bud --layers -t llama-cpp .
#     $ buildah images
#     $ podman run --rm localhost/llama-cpp -h
#
# With populated models/ run the server:
#
#     $ podman run --rm -p 8080:8080 -v $PWD/models:/models localhost/llama-cpp -m models/ggml-model-q4_0.gguf -c 2048 --host 0.0.0.0
#
# Default  --host 127.0.0.1  ist  not sufficient  for  serving from  a
# container.  See  original Dockerfiles  [1].  Für LLAMA  versions see
# release tags [2]. Red Hat Catalog does not like direkt links, you'll
# need to search for "universal base image" for updates [3].
#
# [1] https://raw.githubusercontent.com/ggerganov/llama.cpp/master/.devops/main.Dockerfile
# [2] https://github.com/ggerganov/llama.cpp/releases
# [3] https://catalog.redhat.com/search?searchType=containers

ARG BASE_IMAGE=registry.access.redhat.com/ubi8:8.10
#RG BASE_IMAGE=ubuntu:22.04
ARG LLAMA_RELEASE=b3078

FROM $BASE_IMAGE as build
ARG LLAMA_RELEASE

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
    curl -sL https://github.com/ggerganov/llama.cpp/tarball/$LLAMA_RELEASE | tar zxf - -C llama.cpp/ --strip-components=1
RUN make -C llama.cpp -j$(nproc) server # main

FROM $BASE_IMAGE as runtime

# /main: error while loading shared libraries: libgomp.so.1: cannot
# open shared object file: No such file or directory
# RUN apt-get update && apt-get install libgomp1
RUN dnf install -y libgomp

# Does it work with --layers?
# COPY --from=build /app/llama.cpp/main /main
COPY --from=build /app/llama.cpp/server /server

ENV LC_ALL=C.utf8

ENTRYPOINT [ "/server" ]
