import json

import rlp
from keccak256 import keccak256

with open('data/block0.json') as f:
    block0 = json.load(f)

with open('data/frontier.json') as f:
    frontier_genesis = json.load(f)

# YP: yellow paper, appendix I

# print(block0['difficulty'] == frontier_genesis['difficulty']) # TODO. difficulty set to 2**17, YP
assert(block0['extraData'] == frontier_genesis['extraData']) # testnet block 1028201
assert(block0['gasLimit'] == frontier_genesis['gasLimit']) # ??
assert(block0['gasUsed'] == "0x0")
# hash
assert(set(block0['logsBloom']) == set(['0', 'x'])) # no txns
assert(block0['miner'] == frontier_genesis['coinbase'] == ('0x' + '0'*40))
# mixhash
assert(block0['nonce'] == '0x0000000000000042') # yp
assert(block0['number'] == '0x0') # 0th block
# parentHash
assert(block0['receiptsRoot'] == '0x' + keccak256(rlp.rlp_encode(b'')))
assert(block0['sha3Uncles'] == '0x' + keccak256(rlp.rlp_encode([])))
# size
# stateRoot !important
# timestamp
# totalDifficulty
assert(block0['transactions'] == [])
assert(block0['transactionsRoot'] == '0x' + keccak256(rlp.rlp_encode(b'')))
assert(block0['uncles'] == [])

EMPTY_STORAGEROOT = rlp.to_binary(0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421)
EMPTY_CODEHASH = rlp.to_binary(0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470)

for addr in frontier_genesis['alloc']:
    balance = int(frontier_genesis['alloc'][addr]['balance'], 10)
    print(keccak256(bytearray.fromhex(addr)), rlp.rlp_encode([
        b'', # nonce
        rlp.to_binary(balance),
        EMPTY_STORAGEROOT,
        EMPTY_CODEHASH
    ]).hex())

# { raw:
#    'f84d80890c6ff070f1938b8000a056e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421a0c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470',
#   decoded:
#    [ '0x',
#      '0x0c6ff070f1938b8000',
#      '0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421',
#      '0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470' ] }
