#### Importing local images to k3s

This  is  obscure.   Buildah  and  `k3s`  `containerd`  dont  seem  to
cooperate.   One  needs  to  export   an  image  to  a  tarball,  here
`llama-cpp.tar` and then import it again so that `k3s` can find it:

    $ image=localhost/llama-cpp:b3278
    $ buildah push $image oci-archive:llama-cpp.tar:$image
    $ sudo ctr --namespace=k8s.io images import --no-unpack llama-cpp.tar
    $ sudo ctr --namespace=k8s.io images ls | grep -i llama
    $ rm -f llama-cpp.tar

For import to work `k3s` needs to be running.
