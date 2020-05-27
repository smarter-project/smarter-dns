# Smarterdns 

This repository contains the information required to build the smarterdns image that can be used to provide Pod discovery via DNS in a SMARTER cluster.


## Deploying smarterdns

The default smarterdns deployment assumes that `k3s` has been configured to use `containerd` as the container runtime. 
Smarterdns is deplyed using a Kubernetes DaemonSet - a smarterdns Pod is created on every node and provides DNS lookup including Pod discovery.

When the k3s master is started, the following arguments must be provided to enable smarterdns to function correctly:

`   --flannel-backend=none --dsiable-agent --no-deploy coredns --cluster-cidr=172.38.0.0/16  --cluster-dns "172.38.0.1"`

The `--cluster-dns argument` enables k3s to setup each Pod to point to the smarterdns Pod for name resolution. This value is the gateway address for the bridge network used by the smartercni. Changes to the cluster-cidr value must be reflected in changes to the smarter-cni configuration also.


Deploy the daemonset using:

`   k3s kubectl apply -f smarterdns.yaml`



## Building the image
To build the image it is necessary to acquire a coredns binary. This can be downloaded from the CoreDNS repository: https://github.com/coredns/coredns/releases 

Alternatively, you can build the coredns binary by following the indtructions on https://github.com/coredns/coredns

Once you have a coredns binary, it should be placed in this top-level directory.

Example to build the smarterdns image using docker:

`   docker build -t registry.gitlab.com/arm-research/smarter/smarterdns:1.0 .`

You can trhen push the image into the registry:

`   docker push registry.gitlab.com/arm-research/smarter/smarterdns:1.0`

You will need to replace "registry.gitlab.com/arm-research/smarter" with your own registry and then adjust the YAML file accordingly.


