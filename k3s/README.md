#### Importing local images to k3s

This  is  obscure.   Buildah  and  `k3s`  `containerd`  dont  seem  to
cooperate.   One  needs  to  export   an  image  to  a  tarball,  here
`llama-cpp.tar` and then import it again so that `k3s` can find it:

    $ buildah push localhost/llama-cpp oci-archive:llama-cpp.tar:localhost/llama-cpp:latest
    $ sudo ctr --namespace=k8s.io images import --no-unpack llama-cpp.tar
    $ sudo ctr --namespace=k8s.io images ls | grep -i llama
