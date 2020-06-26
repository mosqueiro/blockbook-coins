# initialize from the image

FROM ubuntu:focal

ENV GOLANG_VERSION=go1.13.8.linux-amd64
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin
ENV CGO_CFLAGS="-I/usr/lib/include"
ENV CGO_LDFLAGS="-L/usr/lib/rocksdb -lrocksdb -lstdc++ -lm -lz -lbz2 -lsnappy -llz4"
ENV DEBIAN_FRONTEND="noninteractive"

# Install rocksdb
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential git wget pkg-config lxc-dev libzmq3-dev \
                        libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev \
                        liblz4-dev graphviz librocksdb-dev && \    
    apt-get clean

# install and configure go
RUN cd /opt && wget https://storage.googleapis.com/golang/$GOLANG_VERSION.tar.gz && \
    tar xf $GOLANG_VERSION.tar.gz
RUN ln -s /opt/go/bin/go /usr/bin/go
RUN mkdir -p $GOPATH
RUN echo -n "GO version: " && go version
RUN echo -n "GOPATH: " && echo $GOPATH

# install build tools\

RUN go get github.com/gobuffalo/packr/...

RUN mkdir /build

# download pre-loaded depencencies
RUN \
    cleanup() { rm -rf $GOPATH/src/github.com/grupokindynos ; } && \
    trap cleanup EXIT && \
    mkdir -p $GOPATH/src/github.com/grupokindynos && \
    cd $GOPATH/src/github.com/grupokindynos && \
    git clone https://github.com/grupokindynos/coins-explorer.git && \
    cd coins-explorer && \
    env GO111MODULE=on go mod vendor && \
    cp -r vendor /build/vendor

ADD Makefile /build/Makefile

VOLUME /out

WORKDIR /build