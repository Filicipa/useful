#!/bin/bash
/home/ubuntu/.foundry/bin/anvil --host 0.0.0.0 --state /home/ubuntu/state/statev6.json --balance 1000000000 --disable-block-gas-limit

/home/ubuntu/.foundry/bin/anvil --host 0.0.0.0 --fork-chain-id 137 --no-rate-limit -f https://polygon-mainnet.g.alchemy.com/v2/NlZ2xJx1w0vxWONvIWd74IWZXh8tBroW --fork-block-number 63432900 --block-time 3

anvil --host 0.0.0.0 --rpc-url https://ava-mainnet.public.blastapi.io/ext/bc/C/rpc --auto-impersonate --chain-id 43114