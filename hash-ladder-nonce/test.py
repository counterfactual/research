#!/usr/bin/env python3

import binascii
import bitcoin

from ethereum.tools import tester
from ethereum.tools._solidity import get_solidity

with open('HashLadder.sol') as f:
    code = f.read()

with open('Nonce.sol') as f:
    nonceCode = f.readlines()

nonceCode = ''.join(line for line in nonceCode if "import" not in line)

c = tester.Chain()

HashLadder = c.contract(
    sourcecode=code,
    language="solidity"
)

root = b''
ladder = []

tip = root
for i in range(5):
    ladder += [tip]
    tip = HashLadder.kHash(tip)

ladder = ladder[::-1]

HashLadder.reveal(ladder[0], ladder[3], 3)

print(HashLadder.height(ladder[0]))

Nonce = c.contract(
    sourcecode=code+nonceCode,
    language="solidity",
    args=([ladder[0]], HashLadder.address)
)

print(Nonce.getLatestNonce())
