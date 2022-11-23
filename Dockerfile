FROM golang:1.19 as build

RUN go version

RUN apt-get update && apt-get install -y git make curl jq 

WORKDIR /root/coredns

RUN curl --silent "https://api.github.com/repos/coredns/coredns/releases/latest" | jq -r .tag_name > VERSION && echo -n Building coredns version: && cat VERSION 
RUN use_version=$(cat VERSION) ; git clone https://github.com/coredns/coredns --branch ${use_version}

RUN cd /root/coredns/coredns;make

FROM alpine:latest

COPY --from=build /root/coredns/coredns/coredns /

RUN apk update && apk add ca-certificates jq iproute2 iptables bash

COPY make_hosts /make_hosts
COPY run_dns /run_dns
COPY crictl.yaml /crictl.yaml

ARG TARGETARCH
RUN apk add wget; \
    wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.25.0/crictl-v1.25.0-linux-${TARGETARCH}.tar.gz;\
    apk del wget;\
    tar xf crictl-v1.25.0-linux-${TARGETARCH}.tar.gz;\
    rm crictl-v1.25.0-linux-${TARGETARCH}.tar.gz

EXPOSE 53 53/udp
ENTRYPOINT ["/run_dns"]

