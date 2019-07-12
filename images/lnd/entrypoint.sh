#!/bin/bash

set -euo pipefail
set -m

lncli="lncli -n $NETWORK -c $CHAIN"

check_lnd() {
    n=`ps | grep "lnd " | grep -v grep | wc -l`
    [ $n -eq "1" ] && $lncli getinfo > /dev/null 2>&1
}

post_actions() {

    set +e
    set +o pipefail

    while ! check_lnd; do
        echo "[DEBUG] Sleep 10 seconds to check lnd then perform post actions"
        sleep 10
    done

    btc_peers=(
        "03a0bdf210dcecebb2d6f092b47fb7753af8114261888a365dfcb0d4548bbbdd2a@xud1.test.exchangeunion.com:10012"
        "036f9b004f047283b33a640bc4afdd26e2eb82e73938f8ac0796641ad20dc5bdd4@xud2.test.exchangeunion.com:10012"
        "023f4a4fa9166f1beb2616bf0cce2c5a4fc9fcda6d533cb760bb6630487bfafdf9@xud3.test.exchangeunion.com:10012"
    )

    ltc_peers=(
        "0270e8254e07649cdde230c9e09de6ff63c28a6d275c30b0a6863028d9db0e7c6f@xud1.test.exchangeunion.com:10011"
        "027dbb21be00a4cace0ce73761449f4d329cd400c08d556e2df4c65cf530c4e689@xud2.test.exchangeunion.com:10011"
        "03e26345aa5d7024668e1f16adc2ecd85907a930820ad5a32736946cb824067eeb@xud3.test.exchangeunion.com:10011"
    )

    if [ "$NETWORK" = "simnet" ]; then
        if [ -e index.txt ]; then
            index=`cat index.txt`
        else
            let index="$RANDOM % 3"
            echo "$index" > index.txt
        fi
        if [ "$CHAIN" = "bitcoin" ]; then
            connectstr="${btc_peers[$index]}"
            echo "[DEBUG] Open channel with $connectstr"
            $lncli connect $connectstr
        else
            connectstr="${ltc_peers[$index]}"
            echo "[DEBUG] Open channel with $connectstr"
            $lncli connect $connectstr
        fi
    fi

    set -eo pipefail
}

post_actions &

unlock_wallet() {
    ./wallet.exp
    ./unlock.exp
    # TODO make sure wallet has been unlocked
}

start_lnd() {
    # macaroons is force enabled when listening on public interfaces (--no-macaroons)
    # specify 0.0.0.0:10009 instead of :10009 because `lncli -n simnet getinfo` will not work with ':10009'
    lnd --rpclisten=0.0.0.0:10009 --listen=0.0.0.0:9735 --restlisten=0.0.0.0:8080 $@ &

    sleep 3

    unlock_wallet
}


restart_lnd() {
    set +e
    echo "[DEBUG] Enter restart_lnd function"
    n=`ps | grep "lnd " | grep -v grep | wc -l`
    echo "[DEBUG] We got $n lnd process(es) at first"
    while [ "$n" -gt "0" ]; do
        ps | grep "lnd " | grep -v grep | awk '{print $1}' | xargs kill -9
        echo "[DEBUG] Sleep 10 seconds to see if we kill all lnd processes"
        sleep 10
        n=`ps | grep "lnd " | grep -v grep | wc -l`
        echo "[DEBUG] Now we got $n lnd process(es) running"
    done
    echo "[DEBUG] All lnd process has been killed"
    sleep 10
    start_lnd $@
}


run() {
    start_lnd $@ &
    echo "[DEBUG] Wait 30 seconds then do regular health check"
    sleep 30
    while true; do
        if ! check_lnd; then
            restart_lnd $@
        fi
        sleep 10
    done
}

run $@
