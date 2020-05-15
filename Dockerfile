FROM debian:stable-slim as build

RUN apt-get update && apt-get -uy upgrade
RUN apt-get -y install ca-certificates && update-ca-certificates
RUN apt-get -y install jq wget 

RUN wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.18.0/crictl-v1.18.0-linux-arm64.tar.gz
RUN tar zxvf crictl-v1.18.0-linux-arm64.tar.gz -C /usr/local/bin
RUN rm -f crictl-v1.18.0-linux-arm64.tar.gz


COPY make_hosts /make_hosts
COPY run_dns /run_dns
COPY coredns /coredns

EXPOSE 53 53/udp
ENTRYPOINT ["/run_dns"]
