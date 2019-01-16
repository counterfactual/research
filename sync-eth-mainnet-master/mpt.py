from collections import defaultdict
from dataclasses import dataclass
import json

import keccak256
import rlp

def isHexaryString(s):
    for c in s:
        if c not in '0123456789abcdef':
            return False
    return True

# All tries are hexary

class PatriciaTrieBranch(object):

    def __init__(self, children):
        assert isinstance(children, dict)
        self.children = children

    def __repr__(self):
        return f"<>{self.children}"

    def __getitem__(self, idx):
        return self.children[idx]

class PatriciaTrieExtension(object):
    extension: bytes
    child: any

    def __init__(self, extension, child):
        assert isHexaryString(extension)
        assert isinstance(child, PatriciaTrieBranch)

        self.extension = extension
        self.child = child

    def __repr__(self):
        return f"<{self.extension}>{self.child.children}"

    def __getitem__(self, idx):
        return self.child[idx]

mpt_data = {
    '646f': b'verb',
}

def extend_common_prefix(elems):
    if len(elems) == 0:
        return None
    for elem in elems:
        if len(elem) == 0:
            return None
    prefix = elems[0][0]

    for elem in elems:
        if elem[0] != prefix:
            return None

    return prefix

assert('6' == extend_common_prefix((
    '6abc',
    '6d'
)))

assert(None == extend_common_prefix((
    '6abc',
    '7d'
)))


def common_prefix(elems):
    """
    find the longest common prefix of all elements in elem
    """
    prefix = ''
    while True:
        next_prefix = extend_common_prefix(elems)
        if next_prefix is None:
            return prefix
        prefix += next_prefix
        elems = list(elem[1:] for elem in elems)

assert('ab' == common_prefix(['abc', 'abx']))

def groupByFirst(d):
    ret = defaultdict(dict)
    for key in d:
        if key == '':
            ret[''] = d['']
        else:
            ret[key[0]][key[1:]] = d[key]
    return ret

def makePatriciaTrie(data):
    if not isinstance(data, dict): return data
    prefix = common_prefix(list(data.keys()))
    N = len(prefix)
    pruned_data = {
        key[N:] : data[key] for key in data
    }
    if N > 0:
        return PatriciaTrieExtension(
            extension=prefix,
            child=makePatriciaTrie(pruned_data)
        )
    else:
        gbf = dict(groupByFirst(pruned_data))
        return PatriciaTrieBranch(
            children = { k : makePatriciaTrie(v) for k, v in gbf.items() })

mpt = makePatriciaTrie(mpt_data)

def H(b):
    if len(b) >= 32:
        return bytes(bytearray.fromhex(keccak256.keccak256(b)))
    else:
        return b

def get_mpt_root(mpt):
    if isinstance(mpt, bytes): return mpt
    if isinstance(mpt, PatriciaTrieExtension):
        assert isinstance(mpt.child, PatriciaTrieBranch)
        # compress extension nodes whose child branch node has a single child
        if len(mpt.child.children) == 1:
            assert '' in mpt.child.children
            pathlen = len(mpt.extension) % 2
            if pathlen == 0:
                x = [
                    bytes(bytearray.fromhex('20' + mpt.extension)),
                    mpt.child.children['']
                ]
                print('x=', [e.hex() for e in x])
                print(x, rlp.rlp_encode(x).hex())
                return H(rlp.rlp_encode(x))
            else:
                x = [
                    bytes(bytearray.fromhex('3' + mpt.extension)),
                    mpt.child.children['']
                ]
                print('x=', [e.hex() for e in x])
                return H(rlp.rlp_encode(x))
        else:
            pathlen = len(mpt.extension) % 2
            if pathlen == 0:
                x = [
                    bytes(bytearray.fromhex('00' + mpt.extension)),
                    get_mpt_root(mpt.child)
                ]
                print('x=', [e.hex() for e in x])
                return H(rlp.rlp_encode(x))
            else:
                x = [
                    bytes(bytearray.fromhex('1' + mpt.extension)),
                    get_mpt_root(mpt.child)
                ]
                print('x=', [e.hex() for e in x])
                return H(rlp.rlp_encode(x))

    elif isinstance(mpt, PatriciaTrieBranch):
        indices = list('0123456789abcdef') + ['']
        arr = [get_mpt_root(mpt.children.get(k, b'')) for k in indices]
        print('arr=', [e.hex() for e in arr])
        return H(rlp.rlp_encode(arr))
    else:
        print(type(mpt), mpt)
        raise

print(mpt)
print(keccak256.keccak256(get_mpt_root(mpt)))

# kvp = dict()
# with open('derived_data/genesis_state_kvp') as f:
#     for l in f.readlines():
#         k, v = l[:-1].split(' ')
#         kvp[k] = v
#     makePatriciaTrie(kvp)

