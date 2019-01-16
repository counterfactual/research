# README

Grab a copy of the genesis block from here:

```
curl https://raw.githubusercontent.com/ethereum/ethereumj/develop/ethereumj-core/src/main/resources/genesis/frontier.json > ./data/frontier.json
```

Or use run the script from https://blog.ethereum.org/2015/07/27/final-steps/

To query infura for the first block header:

```
curl "https://api.infura.io/v1/jsonrpc/mainnet/eth_getBlockByNumber?params=\[\"0x0\",false\]" | jq '.["result"]' > ./data/block0.json
```
