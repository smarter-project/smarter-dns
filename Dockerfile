FROM golang:1.14 as go

FROM debian:stable-slim as build

COPY --from=go /usr/local/go /usr/local/
RUN go version

RUN apt-get update && apt-get -uy upgrade
RUN apt-get install -y git

RUN git clone https://github.com/coredns/coredns

RUN apt-get install -y make
WORKDIR coredns
RUN make


FROM debian:stable-slim

COPY --from=build /coredns/coredns /

RUN apt-get update && apt-get -uy upgrade
RUN apt-get -y install ca-certificates && update-ca-certificates
RUN apt-get -y install jq wget iproute2 iptables 


COPY make_hosts /make_hosts
COPY run_dns /run_dns

EXPOSE 53 53/udp
ENTRYPOINT ["/run_dns"]
#
