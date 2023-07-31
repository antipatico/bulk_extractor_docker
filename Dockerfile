FROM ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive
ARG BULK_EXTRACTOR_VERSION=v2.0.3

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install git build-essential sudo libssl-dev zlib1g-dev autoconf automake make flex gcc g++ git libtool libewf-dev libexpat1-dev -y
RUN git clone --recursive -b $BULK_EXTRACTOR_VERSION https://github.com/simsong/bulk_extractor /root/bulk_extractor
RUN cd /root/bulk_extractor && \
    ./bootstrap.sh && \
    ./configure && \
    make -j $(nproc)

FROM ubuntu:22.04
COPY --from=builder /root/bulk_extractor/src/bulk_extractor /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install libewf2 libexpat1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
USER nobody:nogroup
CMD ["/usr/local/bin/bulk_extractor"]