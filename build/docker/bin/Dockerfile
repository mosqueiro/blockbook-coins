# initialize from the image

FROM ubuntu:bionic

ENV DEBIAN_FRONTEND="noninteractive"


RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential git wget pkg-config lxc-dev libzmq3-dev \
                       libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev \
                       liblz4-dev graphviz && \
    apt-get clean

ENV GOLANG_VERSION=go1.13.8.linux-amd64
ENV ROCKSDB_VERSION=v5.18.3
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin
ENV CGO_CFLAGS="-I/opt/rocksdb/include"
ENV CGO_LDFLAGS="-L/opt/rocksdb -lrocksdb -lstdc++ -lm -lz -lbz2 -lsnappy -llz4"

RUN mkdir /build

# install and configure go
RUN cd /opt && wget https://dl.google.com/go/$GOLANG_VERSION.tar.gz && \
    tar xf $GOLANG_VERSION.tar.gz
RUN ln -s /opt/go/bin/go /usr/bin/go
RUN mkdir -p $GOPATH
RUN echo -n "GO version: " && go version
RUN echo -n "GOPATH: " && echo $GOPATH

# install rocksdb
RUN cd /opt && git clone -b $ROCKSDB_VERSION --depth 1 https://github.com/facebook/rocksdb.git
RUN cd /opt/rocksdb && CFLAGS=-fPIC CXXFLAGS=-fPIC make -j 4 release
RUN strip /opt/rocksdb/ldb /opt/rocksdb/sst_dump && \
    cp /opt/rocksdb/ldb /opt/rocksdb/sst_dump /build

# install build tools
# RUN go get github.com/gobuffalo/packr/...

# download pre-loaded depencencies
RUN \
    cleanup() { rm -rf $GOPATH/src/github.com/mosqueiro ; } && \
    trap cleanup EXIT && \
    mkdir -p $GOPATH/src/github.com/mosqueiro && \
    cd $GOPATH/src/github.com/mosqueiro && \
    git clone https://github.com/mosqueiro/blockbook-coins.git && \
    cd blockbook-coins && \
    env GO111MODULE=on go mod vendor && \
    cp -r vendor /build/vendor
ADD Makefile /build/Makefile

VOLUME /out

WORKDIR /build
