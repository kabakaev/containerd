#!/bin/bash -xe

if [[ $USER ]]; then # we are outside of container
    docker inspect containerd-dev-env:latest > /dev/null \
    || docker build -t containerd-dev-env -f compile.Dockerfile .

    docker run -ti --rm -v `pwd`:/repo containerd-dev-env:latest bash
    #docker run -ti --rm -v `pwd`:/repo containerd-dev-env:latest /repo/compile.sh

else # we are inside container because $USER is not set

mkdir -p $GOPATH/src/github.com/containerd/
rsync -avH --delete --exclude releases --exclude bin/ /repo/ $GOPATH/src/github.com/containerd/containerd
#git clone https://github.com/containerd/containerd.git
export TRAVIS_BUILD_DIR=$GOPATH/src/github.com/containerd/containerd
cd $TRAVIS_BUILD_DIR

if [[ $1 != "skip-install" ]] ; then
    sudo PATH=$PATH GOPATH=$GOPATH script/setup/install-protobuf
    sudo chmod +x /usr/local/bin/protoc
    sudo chmod og+rx /usr/local/include/google /usr/local/include/google/protobuf /usr/local/include/google/protobuf/compiler
    sudo chmod -R og+r /usr/local/include/google/protobuf/
    protoc --version
    go get -u github.com/vbatts/git-validation
    go get -u github.com/kunalkushwaha/ltag
    go get -u github.com/LK4D4/vndr
    sudo PATH=$PATH GOPATH=$GOPATH script/setup/install-seccomp
    sudo PATH=$PATH GOPATH=$GOPATH script/setup/install-runc
    sudo PATH=$PATH GOPATH=$GOPATH script/setup/install-cni
    sudo PATH=$PATH GOPATH=$GOPATH script/setup/install-critools
    wget https://github.com/checkpoint-restore/criu/archive/v3.13.tar.gz -O /tmp/criu.tar.gz
    tar -C /tmp/ -zxf /tmp/criu.tar.gz
    pushd /tmp/criu-3.13
        sudo make install-criu
    popd

    pushd ..; ls project || git clone https://github.com/containerd/project; popd

    git fetch

    #DCO_VERBOSITY=-q ../project/script/validate/dco
    #../project/script/validate/fileheader ../project/
    #../project/script/validate/vendor
    GOOS=linux GO111MODULE=off script/setup/install-dev-tools
fi

go build -i .
#make check
#if [ "$GOOS" = "linux" ]; then make check-protos check-api-descriptors; fi
if [ "$GOOS" = "linux" ]; then make man ; fi
make build
make binaries
make release cri-release

mkdir -p /repo/bin/
cp -rpf ./releases /root/go/src/github.com/containerd/cri/hack/../_output/ /repo/bin/

fi
