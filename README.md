# smarter-dns 

This repository contains the information required to build the smarter-dns image that can be used to provide Pod discovery via DNS in a SMARTER cluster.


## Deploying smarter-dns

The k3s binary should be available at `/usr/local/bin/k3s`.
The `CRI_DIR` and `CRI_FILE` entries in the smarterdnsconfig configmap can be used to point to the socket file for the container runtime.

The default smarter-dns deployment assumes that `k3s` has been configured to use a standalone `containerd` as the container runtime.


Smarter-dns is deplyed using a Kubernetes DaemonSet - a smarter-dns Pod is created on every node and provides DNS lookup including Pod discovery.

When the k3s master is started, the following arguments must be provided to enable smarter-dns to function correctly:

`   --flannel-backend=none --dsiable-agent --no-deploy coredns --cluster-cidr=172.38.0.0/16  --cluster-dns "172.38.0.1"`

The `--cluster-dns argument` enables k3s to setup each Pod to point to the smarter-dns Pod for name resolution. This value is the gateway address for the bridge network used by the smartercni. Changes to the cluster-cidr value must be reflected in changes to the smarter-cni configuration also.


Deploy the daemonset using:

`   k3s kubectl apply -f smarterdns_ds.yaml`



## Building the image

To build the smarter-dns image using docker:

    docker buildx create --use --name mybuild
    docker buildx build --platform linux/arm64/v8,linux/arm/v7,linux/amd64 -t registry.gitlab.com/arm-research/smarter-dns/smarter-dns:v1.0 --push .


You can replace "registry.gitlab.com/arm-research/smarter" with your own registry and then adjust the YAML file accordingly.


