#
# Usage:
#
#     $ buildah bud --layers -t llama-cpp .
#     $ buildah images
#     $ podman run localhost/llama-cpp -h
#
# See original Dockerfiles [1].  Für LLAMA versions see release tags
# [2].
#
# [1] https://raw.githubusercontent.com/ggerganov/llama.cpp/master/.devops/main.Dockerfile
# [2] https://github.com/ggerganov/llama.cpp/releases
ARG UBUNTU_VERSION=22.04
ARG LLAMA_RELEASE=b3078


FROM ubuntu:$UBUNTU_VERSION as build
ARG LLAMA_RELEASE

RUN apt-get update && \
    apt-get install -y build-essential git curl

WORKDIR /app

# How do  we get  the sources  and supply  them to  Buildah/Docker? We
# assume the  sources are  in ./llama.cpp  as if  one cloned  the repo
# locally.   This  might  be  the  best  workflow  for  iterations  in
# development. Then  a simple  COPY would suffice,  see .dockerignore!
# FWIW, GitHub does not allow  "git archive --remote=..." but provides
# an alternative vor tarballs.
#
# COPY . .
RUN mkdir llama.cpp && \
    curl -sL https://github.com/ggerganov/llama.cpp/tarball/$LLAMA_RELEASE | tar zxf - -C llama.cpp/ --strip-components=1
RUN make -C llama.cpp -j$(nproc) server main

FROM ubuntu:$UBUNTU_VERSION as runtime

# /main: error while loading shared libraries: libgomp.so.1: cannot
# open shared object file: No such file or directory
RUN apt-get update && \
    apt-get install libgomp1

# Does it work with --layers?
COPY --from=build /app/llama.cpp/main /main
COPY --from=build /app/llama.cpp/server /server

ENV LC_ALL=C.utf8

ENTRYPOINT [ "/main" ]
