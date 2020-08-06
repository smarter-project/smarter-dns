# smarter-dns

This repository contains the information required to build the smarter-dns image that can be used to provide Pod discovery via DNS in a SMARTER cluster.


## Deploying smarter-dns

Smarter-dns is deployed using a Kubernetes DaemonSet - a smarter-dns Pod is created on every node with the relevant label and provides DNS lookup including Pod discovery.

Different nodes may be using different Container Runtimes and the `smarter.cri` label is used to distinguish between them. At least one of these labels must be present on the node for smarter-dns to be deployed to it.

 Apply label  `smarter.cri=docker` when using docker

 Apply label `smarter.cri=containerd` when using containerd

 **Note that when using docker as the container runtime it is necessary to use the SMARTER k3s agent on the node**


### Choose the correct version of the YAML file

Three YAML files are provided for smarter-dns depending on the container runtime that is being used on the node.

| YAML | Usage |
|------|--------|
|`smarterdns_ds_docker.yaml` | Use this when using k3s with docker as the container runtime |
|`smarterdns_ds_containerd.yaml` | Use this when using k3s with an external containerd |
|`smarterdns_ds_k3s_containerd.yaml` | Use this when using k3s with it's bundled containerd |


See <https://gitlab.com/arm-research/smarter/smarter-dns/-/releases> for the latest release of these YAML files.


## Configuration

The smarterdnsconfig ConfigMap can be used to customise the smarterdns deployment.

## cluster dns

When the k3s server is started, the following arguments must be provided to enable smarter-dns to function correctly:

	`--no-deploy coredns --cluster-dns "169.254.0.2"

The `--cluster-dns argument` enables k3s to setup each Pod to point to the smarter-dns Pod for name resolution.

Alternatively this flag can be provided to the k3s agent running on each node via the --kubelet-arg flag: 

	`--kubelet-arg cluster-dns=169.254.0.2`

Which ever method is used, the value must match that specified by the CLUSTER\_DNS key/value in the smarterdnsconfig configmap (see the smarterdns_ds_docker.yaml file)


### Location of the k3s binary

smarter-dns uses the `k3s crictl` command and assumes that the k3s binary can be found at `/usr/bin/k3s`. This location can be configured by setting the `CRICTL_BIN` value in the smarterdnsconfig configmap in the smarter-dns YAML file.

### Location of the Unix socker for the Container Runtime Interface

The `CRI_DIR` entry in the smarterdnsconfig configmap can be used to point to the directory containing the socket file for the container runtime.

The `CRI_FILE` entry in the smarterdnsconfig configmap should then be set to the name of the socket file within the CRI_DIR directory.




Deploy the daemonset using:

`k3s kubectl apply -f smarterdns_ds_docker.yaml`


### How it works


DNS queries from normal pods and pods with host networking will all go to the IP address specified as the cluster-dns IP (by default this is `169.254.0.2`)

The smarterdns pod sets up iptable rules to redirect these queries to the actual smarter-dns server which is executing as a pod with host-networking.

Discovery of pod IPs on the node can also be performed by querying the same address: `169.254.0.2`




## Building the image

To build the smarter-dns image using docker:


    docker buildx create --use --name mybuild
    docker buildx build --platform linux/arm64/v8,linux/arm/v7,linux/amd64 -t registry.gitlab.com/arm-research/smarter/smarter-dns:vX.Y.Z --push .


You can replace "registry.gitlab.com/arm-research/smarter" with your own registry and then adjust the YAML file accordingly.

