# smarter-dns 

This repository contains the information required to build the smarter-dns image that can be used to provide Pod discovery via DNS in a SMARTER cluster.


## Deploying smarter-dns


Smarter-dns is deployed using a Kubernetes DaemonSet - a smarter-dns Pod is created on every node and provides DNS lookup including Pod discovery.

When the k3s server is started, the following arguments must be provided to enable smarter-dns to function correctly:

`--no-deploy coredns --cluster-dns "169.254.0.2"`

The `--cluster-dns argument` enables k3s to setup each Pod to point to the smarter-dns Pod for name resolution. 

### Configure location of the k3s binary

smarter-dns uses the `k3s crictl` command and assumes that the k3s binary can be found at `/usr/bin/k3s`. This location can be configured by setting the `CRICTL_BIN` value in the smarterdnsconfig configmap in the smarter-dns YAML file.

The `CRI_DIR` and `CRI_FILE` entries in the smarterdnsconfig configmap can be used to point to the socket file for the container runtime.


### Ensure that nodes are labelled

The nodes on which smarter-dns is deployed must be labelled correctly to reflect the container runtime that is being used:

Label `smarter.cri=docker` when using docker 

Label `smarter.cri=containerd` when using containerd

**Note that when using docker as the container runtime it is necessary to run our custom k3s**



### Choose the correct version of the YAML file

Three YAML files are provided for smarter-dns depending on the Container runtime that is being used on the node.

| YAML | Usage |
|------|--------|
|`smarterdns_ds_docker.yaml` | Use this when using k3s with docker as the container runtime |
|`smarterdns_ds_containerd.yaml` | Use this when using k3s with an external containerd |
|`smarterdns_ds_k3s_containerd.yaml` | Use this when using k3s with it's bundled containerd |



Deploy the daemonset using:

`k3s kubectl apply -f smarterdns_ds_docker.yaml`


### How it works

DNS queries from normal pods and pods with host networking will all go to a specific IP address: `169.254.0.2`. This value must be provided in the configuration for the Kubernetes server via the `--cluster-dns` argument.

The smarter-cni sets up iptable rules to redirect these queries to the actual smarter-dns server which is executing as a pod with host-networking.

Discovery of pod IPs from the host can also be performed by querying the same address: `169.254.0.2`

 






## Building the image

To build the smarter-dns image using docker:

    docker buildx create --use --name mybuild
    docker buildx build --platform linux/arm64/v8,linux/arm/v7,linux/amd64 -t registry.gitlab.com/arm-research/smarter-dns/smarter-dns:v1.0 --push .


You can replace "registry.gitlab.com/arm-research/smarter" with your own registry and then adjust the YAML file accordingly.


