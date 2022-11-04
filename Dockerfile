FROM golang:1.19 as build

RUN go version

#RUN apt-get update && apt-get -uy upgrade && apt-get install -y git make
RUN apt-get update && apt-get -uy upgrade && apt-get install -y git make

WORKDIR /root/coredns

RUN git clone https://github.com/coredns/coredns

RUN cd /root/coredns/coredns;make

FROM debian:stable-slim 

COPY --from=build /root/coredns/coredns /

#RUN apt-get update && apt-get -uy upgrade && apt-get -y install ca-certificates && update-ca-certificates && apt-get -y install jq iproute2 iptables && apt-get autoremove && apt-get clean
RUN apt-get update && apt-get -y install ca-certificates && update-ca-certificates && apt-get -y install jq iproute2 iptables && apt-get autoremove && apt-get clean
#
COPY make_hosts /make_hosts
COPY run_dns /run_dns
COPY crictl.yaml /crictl.yaml

ARG TARGETARCH
RUN apt-get -y install wget; \
    wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.21.0/crictl-v1.21.0-linux-${TARGETARCH}.tar.gz;\
    apt-get -y remove wget;\
    tar xf crictl-v1.21.0-linux-${TARGETARCH}.tar.gz;\
    rm crictl-v1.21.0-linux-${TARGETARCH}.tar.gz

EXPOSE 53 53/udp
ENTRYPOINT ["/run_dns"]

