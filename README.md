#### Experiments with `llama.cpp`

See
https://github.com/ggerganov/llama.cpp/blob/master/examples/main/README.md

#### No Binary Releases for old CPUs

Older CPUs supporting only AVX will get SIGILL:

    $ curl -LO https://github.com/ggerganov/llama.cpp/releases/download/b3075/llama-b3075-bin-ubuntu-x64.zip
    $ unzip llama-b3075-bin-ubuntu-x64.zip
    $ ./build/bin/main -h
    Illegal instruction (core dumped)

#### Models

    $ mkdir models
    $ cd models
    $ curl -LO https://huggingface.co/ggml-org/models/resolve/main/tinyllamas/stories15M-q4_0.gguf
    $ curl -LO https://huggingface.co/ggml-org/models/resolve/main/phi-2/ggml-model-q4_0.gguf

    $ md5sum *
    3a77700850d8cf2b502d2d4a83078f55  ggml-model-q4_0.gguf
    abb77e873442615657e3379baeb50567  stories15M-q4_0.gguf

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

Run models:

    ./llama.cpp/main -m models/stories15M-q4_0.gguf --prompt "Once upon a time"
    ./llama.cpp/main -m models/ggml-model-q4_0.gguf --prompt "Once upon a time"
