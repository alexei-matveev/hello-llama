#### Experiments with `llama.cpp`

See
https://github.com/ggerganov/llama.cpp/blob/master/examples/main/README.md

#### Build Docker Image

This seems to work at least on Ubuntu 24.04 and Debian 12, even for
non-priviliged users:

    $ buildah bud --layers --force-rm -t llama-cpp .
    $ buildah images
    REPOSITORY                        TAG      IMAGE ID       CREATED         SIZE
    localhost/llama-cpp               latest   6075627d893e   3 minutes ago   243 MB
    <none>                            <none>   482b54a890b8   3 minutes ago   490 MB
    registry.access.redhat.com/ubi8   8.10     7b13db19b1f3   4 days ago      212 MB

The intermediate image without tags may be removed with `buildah
rmi`. Try starting executables with Podman:

    $ podman run --rm --entrypoint /main   localhost/llama-cpp -h
    $ podman run --rm --entrypoint /server localhost/llama-cpp -h

See also comments in the Dockerfile.

#### Rund `llama.cpp` Server from Docker Image

WARNING, as is the server exposes port 8080 on 0.0.0.0 which will be
available in local network or, in worst case of a public IP, to all of
the internet. That beeing said, just execute the startup script:

    $ bin/start

Note that on first start it will download a model file over your
link. Those are a few GB big!

#### Using Server OpenAI API

See [Repo](https://github.com/openai/openai-python) ...

    $ python3 -m venv .venv
	$ . .venv/bin/activate
	$ pip install openai

Venv with OpenAI Client API only take about ~34M ob Ubuntu 24.04. Run
example session using OpenAI API by executing

    $ bin/chat

When finished deactivate Venv with:

	$ deactivate

#### No Binary Releases for old CPUs

Older CPUs supporting only AVX will get SIGILL:

    $ curl -LO https://github.com/ggerganov/llama.cpp/releases/download/b3075/llama-b3075-bin-ubuntu-x64.zip
    $ unzip llama-b3075-bin-ubuntu-x64.zip
    $ ./build/bin/main -h
    Illegal instruction (core dumped)

#### Build from Sources

    $ git clone --depth 100 https://github.com/ggerganov/llama.cpp.git
    $ git checkout b3078

    $ sudo aptitude install make gcc g++

    $ cd llama.cpp
    $ make -j

    $ ./main --version
    version: 100 (bde7cd3)
    built with cc (Ubuntu 13.2.0-23ubuntu4) 13.2.0 for x86_64-linux-gnu

    $ ./main -h

#### Get Models

    $ mkdir models
    $ cd models
    $ curl -LO https://huggingface.co/ggml-org/models/resolve/main/tinyllamas/stories15M-q4_0.gguf
    $ curl -LO https://huggingface.co/ggml-org/models/resolve/main/phi-2/ggml-model-q4_0.gguf
    $ curl -LO https://huggingface.co/TheBloke/Mistral-7B-v0.1-GGUF/resolve/main/mistral-7b-v0.1.Q4_K_M.gguf

    $ md5sum *
    3a77700850d8cf2b502d2d4a83078f55  ggml-model-q4_0.gguf
    a5b363017e471c713665d57433f76e65  mistral-7b-v0.1.Q4_K_M.gguf
    abb77e873442615657e3379baeb50567  stories15M-q4_0.gguf

#### Run Models

    ./llama.cpp/main -m models/stories15M-q4_0.gguf --prompt "Once upon a time"
    ./llama.cpp/main -m models/ggml-model-q4_0.gguf --prompt "Once upon a time"
    ./llama.cpp/main -m models/mistral-7b-v0.1.Q4_K_M.gguf --prompt "Once upon a time"

#### Run Server

    $ ./llama.cpp/server -m models/ggml-model-q4_0.gguf -c 2048

    $ curl --request POST --url http://localhost:8080/completion \
           --header "Content-Type: application/json" \
           --data '{"prompt": "Building a website can be done in 10 simple steps:","n_predict": 128}'
