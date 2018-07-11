#!/usr/bin/env python3

import binascii
import bitcoin

from ethereum.tools import tester
from ethereum.tools._solidity import get_solidity

def sign(h, priv):
    assert len(h) == 32
    V, R, S = bitcoin.ecdsa_raw_sign(h, priv)
    return V,R,S

with open('multisig.sol') as f:
    code = f.read()

def even(N):
    return N % 2 == 0

def pairs(arr):
    N = len(arr)
    return [
        (arr[2*i], arr[2*i+1])
        for i in range(N // 2)
    ] + (
        [] if even(N) else [(arr[-1],)]
    )

def partner(n):
    if even(n): return n+1
    return n-1

# print(pairs([1, 2, 3, 4, 5]))

c = tester.Chain()

multisig = c.contract(
    sourcecode=code,
    language="solidity"
)

def unorderedHash(a, b):
    return multisig.unorderedHash(a, b)

def guardedUnorderedHash(x):
    if len(x) == 2:
        a, b = x
        return unorderedHash(a, b)
    (a,) = x
    return a

def rootAndProofs(elems, idx):
    elems = list(elems)
    proof = []

    while len(elems) > 1:

        if (idx != len(elems) - 1):
            proof += [elems[partner(idx)]]

        elems = pairs(elems)
        idx = idx // 2

        elems = [guardedUnorderedHash(e) for e in elems]

    return (elems[0], proof)

arr = list(e.encode('ascii') for e in "abcde")
root, proof = rootAndProofs(arr, 1)

assert(multisig.verifyProof(proof, root, arr[1]))
