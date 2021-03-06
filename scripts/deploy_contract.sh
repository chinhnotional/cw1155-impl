#!/bin/bash

NODE="http://65.108.128.139:2281"
ACCOUNT="Developer"
CHAINID="anone-testnet-1"
CONTRACT_DIR="artifacts/cw1155_impl.wasm"
SLEEP_TIME="15s"

MINTER=$(anoned keys show $ACCOUNT -a)
INIT="{\"minter\": \"$MINTER\"}"
INIT_JSON=$(anoned tx wasm instantiate "82" "$INIT" --from "$ACCOUNT" --label "cw1155-impl" -y --chain-id "$CHAINID" --node "$NODE" --gas 180000 --fees 0uan1 -o json)

echo "INIT_JSON = $INIT_JSON"

if [ "$(echo $INIT_JSON | jq -r .raw_log)" != "[]" ]; then
	# exit
	echo "ERROR = $(echo $INIT_JSON | jq .raw_log)"
	exit 1
else
	echo "INSTANTIATE SUCCESS"
fi

# sleep for chain to update
sleep "$SLEEP_TIME"

RAW_LOG=$(anoned query tx "$(echo $INIT_JSON | jq -r .txhash)" --chain-id "$CHAINID" --node "$NODE" --output json | jq -r .raw_log)

echo "RAW_LOG = $RAW_LOG"

CONTRACT_ADDRESS=$(echo $RAW_LOG | jq -r .[0].events[0].attributes[0].value)

echo "CONTRACT ADDRESS = $CONTRACT_ADDRESS"