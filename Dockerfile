FROM golang:1.19 as build

RUN go version

RUN apt-get update && apt-get install -y git make curl jq wget 

WORKDIR /root/coredns
ARG TARGETARCH
RUN curl --silent "https://api.github.com/repos/kubernetes-sigs/cri-tools/releases/latest" | jq -r .tag_name > VERSION && echo -n Using crictl version: && cat VERSION 
RUN use_version=$(cat VERSION); \
    wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${use_version}/crictl-${use_version}-linux-${TARGETARCH}.tar.gz;\
    tar xf crictl-${use_version}-linux-${TARGETARCH}.tar.gz;\
    rm crictl-${use_version}-linux-${TARGETARCH}.tar.gz; \
    rm VERSION

RUN curl --silent "https://api.github.com/repos/coredns/coredns/releases/latest" | jq -r .tag_name > VERSION && echo -n Building coredns version: && cat VERSION 
RUN use_version=$(cat VERSION) ; git clone https://github.com/coredns/coredns --branch ${use_version}
RUN cd /root/coredns/coredns;make

FROM alpine:latest

COPY --from=build /root/coredns/coredns/coredns /
COPY --from=build /root/coredns/crictl /

RUN apk add --no-cache jq iproute2 iptables bash

COPY make_hosts /make_hosts
COPY run_dns /run_dns
COPY crictl.yaml /crictl.yaml

EXPOSE 53 53/udp
ENTRYPOINT ["/run_dns"]

