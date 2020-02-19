FROM ubuntu:bionic

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt update \
    && apt -y install \
        btrfs-tools \
        libnl-3-dev \
        libnet-dev \
        protobuf-c-compiler \
        python-minimal \
        libcap-dev \
        libaio-dev \
        libprotobuf-c-dev \
        libprotobuf-dev \
        socat \
        sudo \
        git \
        wget \
        curl \
        libatomic1 \
        libseccomp-dev \
        libnl-route-3-dev \
        libnfnetlink-dev \
        build-essential \
        unzip \
        rsync \
    && apt clean all \
    && wget https://dl.google.com/go/go1.13.8.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.13.8.linux-amd64.tar.gz \
    && rm -f go1.13.8.linux-amd64.tar.gz \
    && echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> /root/.bashrc

ENV GOOS=linux GOPATH=/root/go
