#!/bin/bash

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

images="$DIR/../images"

cd $images

source versions

bitcoind_tag=exchangeunion/bitcoind:$bitcoind
litecoind_tag=exchangeunion/litecoind:$litecoind
lnd_tag=exchangeunion/lnd:$lnd
lnd_simnet_tag=exchangeunion/lnd:$lnd-simnet
geth_tag=exchangeunion/geth:$geth
raiden_tag=exchangeunion/raiden:$raiden
xud_tag=exchangeunion/xud:$xud
parity_tag=exchangeunion/parity:$parity
btcd_tag=exchangeunion/btcd:$btcd
ltcd_tag=exchangeunion/ltcd:$ltcd
ltcd_simnet_tag=exchangeunion/ltcd:$ltcd-simnet

build_bitcoind() {
    docker build -t $bitcoind_tag --build-arg version=$bitcoind bitcoind
    docker push $bitcoind_tag
}

build_litecoind() {
    docker build -t $litecoind_tag --build-arg version=$litecoind litecoind
    docker push $litecoind_tag
}

build_lnd() {
    docker build -t $lnd_tag --build-arg version=$lnd lnd
    docker build -t $lnd_simnet_tag --build-arg version=$lnd -f lnd/Dockerfile.simnet lnd
    docker push $lnd_tag 
    docker push $lnd_simnet_tag
}

build_geth() {
    docker build -t $geth_tag --build-arg version=$geth geth
    docker push $geth_tag
}

build_parity() {
    docker build -t $parity_tag --build-arg version=$parity parity
    docker push $parity_tag
}

build_xud() {
    if [ "$xud" = "latest" ]; then
        docker build -t $xud_tag --build-arg branch=master xud
    else
        docker build -t $xud_tag --build-arg branch=v$xud xud
    fi
    docker push $xud_tag
}

build_raiden() {
    docker build -t $raiden_tag --build-arg version=$raiden raiden
    docker push $raiden_tag
}

build_btcd() {
    if ! [ -e "$images/btcd/data.tar.gz" ]; then
        touch $images/btcd/data.tar.gz
    fi
    if [ "$btcd" = "latest" ]; then
        docker build -t $btcd_tag --build-arg branch=master btcd
    else
        docker build -t $btcd_tag --build-arg branch=v$btcd btcd
    fi
    docker push $btcd_tag
}

build_ltcd() {
    if ! [ -e "$images/ltcd/data.tar.gz" ]; then
        touch $images/ltcd/data.tar.gz
    fi
    if [ "$ltcd" = "latest" ]; then
        docker build -t $ltcd_tag --build-arg branch=master ltcd
        docker build -t $ltcd_simnet_tag --build-arg branch=master -f ltcd/Dockerfile.simnet ltcd
    else
        docker build -t $ltcd_tag --build-arg branch=v$ltcd ltcd
        docker build -t $ltcd_simnet_tag --build-arg branch=v$ltcd -f ltcd/Dockerfile.simnet ltcd
    fi
    docker push $ltcd_tag
    docker push $ltcd_simnet_tag
}

case $1 in
    bitcoind) build_bitcoind;;
    litecoind) build_litecoind;;
    lnd) build_lnd;;
    raiden) build_raiden;;
    geth) build_geth;;
    parity) build_parity;;
    xud) build_xud;;
    btcd) build_btcd;;
    ltcd) build_ltcd;;
esac