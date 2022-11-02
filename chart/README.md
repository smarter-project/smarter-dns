# SMARTER DNS

DNS for edge instances

For more information visit https://getsmarter.io

## TL;DR

```console
helm repo add smarter https://smarter-project.gitlab.io/documentation/charts
helm install my-smarter-dns smarter-dns
```

## Overview

DNS queries from normal pods and pods with host networking will all go to the IP address specified as the cluster-dns IP (by default this is `169.254.0.2`)
The smarterdns pod sets up iptable rules to redirect these queries to the actual smarter-dns server which is executing as a pod with host-networking.
Discovery of pod IPs on the node can also be performed by querying the same address: `169.254.0.2`
### Usage Model

Smarter-dns is deployed using a Kubernetes DaemonSet - a smarter-dns Pod is created on every node with the relevant label and provides DNS lookup including Pod discovery.

Different nodes may be using different Container Runtimes and the `smarter.cri` label is used to distinguish between them. At least one of these labels must be present on the node for smarter-dns to be deployed to it.

 Apply label `smarter.cri=docker` when using docker
 Apply label `smarter.cri=containerd` when using containerd

The smarterdnsconfig ConfigMap can be used to customise the smarterdns deployment.

When the k3s server is started, the following arguments must be provided to enable smarter-dns to function correctly:

	`--no-deploy coredns --cluster-dns "169.254.0.2"`

The `--cluster-dns argument` enables k3s to setup each Pod to point to the smarter-dns Pod for name resolution.

Alternatively this flag can be provided to the k3s agent running on each node via the --kubelet-arg flag: 

	`--kubelet-arg cluster-dns=169.254.0.2`

Which ever method is used, the value must match that specified by the CLUSTER\_DNS key/value in the smarterdnsconfig configmap (see the smarterdns_ds_docker.yaml file)

## Uninstalling the Chart

```
helm delete my-smarter-dns
```
