export XUD_NETWORK=`basename $(pwd)`

case $XUD_NETWORK in
    mainnet)
        alias bitcoin-cli="docker-compose exec bitcoind bitcoin-cli -rpcuser=xu -rpcpassword=xu"
        alias litecoin-cli="docker-compose exec litecoind litecoin-cli -rpcuser=xu -rpcpassword=xu"
        alias lndbtc-lncli="docker-compose exec lndbtc lncli -n mainnet -c bitcoin"
        alias lndltc-lncli="docker-compose exec lndltc lncli -n mainnet -c litecoin"
        alias geth="docker-compose exec geth geth"
        ;;
    testnet)
        alias bitcoin-cli="docker-compose exec bitcoind bitcoin-cli -testnet -rpcuser=xu -rpcpassword=xu"
        alias litecoin-cli="docker-compose exec litecoind litecoin-cli -testnet -rpcuser=xu -rpcpassword=xu"
        alias lndbtc-lncli="docker-compose exec lndbtc lncli -n testnet -c bitcoin"
        alias lndltc-lncli="docker-compose exec lndltc lncli -n testnet -c litecoin"
        alias geth="docker-compose exec geth geth --testnet"
        ;;
    simnet)
        alias btcctl="docker-compose exec btcd btcctl --simnet --rpcuser=xu --rpcpass=xu"
        alias ltcctl="docker-compose exec ltcd ltcctl --simnet --rpcuser=xu --rpcpass=xu"
        alias lndbtc-lncli="docker-compose exec lndbtc lncli -n simnet -c bitcoin"
        alias lndltc-lncli="docker-compose exec lndltc lncli -n simnet -c litecoin"
        ;;
esac

GRACEFUL_SHUTDOWN_TIMEOUT=180

alias logs="docker-compose logs"
alias start="docker-compose start"
alias stop="docker-compose stop -t $GRACEFUL_SHUTDOWN_TIMEOUT"
alias restart="docker-compose restart -t $GRACEFUL_SHUTDOWN_TIMEOUT"
alias up="docker-compose up"
alias down="docker-compose down -t $GRACEFUL_SHUTDOWN_TIMEOUT"

function xucli() {
    LINE=""
    #shellcheck disable=SC2068
    docker-compose exec xud xucli $@ | while read -n 1; do
        if [[ $REPLY == $'\n' ]]; then
            if [[ ! $LINE =~ "<hide>" ]]; then
                echo "$LINE"
            fi
            LINE=""
        else
            LINE="$LINE$REPLY"
            if [[ $LINE =~ 'password: ' ]]; then
                echo -n "$LINE"
                LINE=""
            elif [[ $LINE =~ getenv ]]; then
                LINE="<hide>"
            fi
        fi
  done
}

alias help="xucli help"
alias addcurrency="xucli addcurrency"
alias addpair="xucli addpair"
alias ban="xucli ban"
alias getbalance="xucli getbalance"
alias connect="xucli connect"
alias create="xucli create"
alias discovernodes="xucli discovernodes"
alias executeswap="xucli executeswap"
alias getinfo="xucli getinfo"
alias getnodeinfo="xucli getnodeinfo"
alias listorders="xucli listorders"
alias listpairs="xucli listpairs"
alias listpeers="xucli listpeers"
alias openchannel="xucli openchannel"
alias orderbook="xucli orderbook"
alias removecurrency="xucli removecurrency"
alias removeorder="xucli removeorder"
alias removepair="xucli removepair"
alias shutdown="xucli shutdown"
alias unban="xucli unban"
alias unlock="xucli unlock"
alias buy="xucli buy"
alias sell="xucli sell"

export PS1="$XUD_NETWORK > "

export XUD_DOCKER_HOME=~/.xud-docker

alias status="$XUD_DOCKER_HOME/status.sh"

function get_all_services() {
    cat docker-compose.yml | grep -A 999 services | sed -nE 's/^  ([a-z]+):$/\1/p' | sort | paste -sd " " -
}

function log_details() {
    logfile="$XUD_DOCKER_HOME/$XUD_NETWORK/xud-docker.log"
    commands=(
        "uname -a"
        "docker info"
        "docker stats --no-stream"
        "docker-compose ps"
    )
    services=$(get_all_services)
    for s in $services; do
        commands+=("docker-compose logs --tail=1000 $s")
    done

    set +e
    for cmd in "${commands[@]}"; do
        echo $cmd >> $logfile
        eval $cmd >> $logfile 2>&1
        echo "" >> $logfile
    done
    set -e
}

report() {
    log_details
    echo "Please click on https://github.com/ExchangeUnion/xud/issues/new?assignees=kilrau&labels=bug&template=bug-report.md&title=Short%2C+concise+description+of+the+bug, describe your issue, drag and drop the file \"xud-docker.log\" which is located in $HOME/.xud-docker into your browser window and submit your issue."
}

enter() {
    docker run --rm -it --entrypoint bash $1
}

cat ../banner.txt

python="python3"
if ! which $python >/dev/null 2>&1; then
    python="python"
fi

alias status2="$python ../status.py status"

$python ../status.py check
