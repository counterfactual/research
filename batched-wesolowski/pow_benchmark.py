from hashlib import blake2s
import random
import math
from collections import defaultdict
from functools import reduce
import operator
import time

MODULUS = 25195908475657893494027183240048398571429282126204032027777137836043662020707595556264018525880784406918290641249515082189298559149176184502808489120072844992687392807287776735971418347270261896375014971824691165077613379859095700097330459748808428401797429100642458691817195118746121515172654632282216869987549182422433637259085141865462043576798423387184774447920739934236584823824281198163815010674810451660377306056201619676256133844143603833904414952634432190114657544454178424020924616515723350778707749817125772467962926386356373289912154831438167899885040445364023527381951378636564391212010397122822120720357
TOTAL = 2**20
TRANSACTIONS_PER_BLOCK = 10**4

def get_size(num):
    return sizeof_fmt(math.log(1 + num, 2) // 8)

def print_size(num):
    print(get_size(num))

def sizeof_fmt(num, suffix='B'):
    for unit in ['','Ki','Mi','Gi','Ti','Pi','Ei','Zi']:
        if abs(num) < 1024.0:
            return "%3.1f%s%s" % (num, unit, suffix)
        num /= 1024.0
    return "%.1f%s%s" % (num, 'Yi', suffix)

old_pow = pow

def pow(a, b):
    sz = get_size(b)

    start = time.time()
    old_pow(a, b, MODULUS)
    end = time.time()
    print(f"{sz}\t{end - start}")

def random_int(size):
    return int(
        ''.join(
            str(random.randint(0, 1)) for i in range(size)
        ),
        2
    )

for i in range(20):
    ri = random_int(2**i)
    pow(9999999999999999999, ri)
