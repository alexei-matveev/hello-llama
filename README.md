#### Experiments with `llama.cpp`

See
https://github.com/ggerganov/llama.cpp/blob/master/examples/main/README.md

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
