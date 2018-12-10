from hashlib import blake2s
import random
import math
from collections import defaultdict
from functools import reduce
import operator

MODULUS = 25195908475657893494027183240048398571429282126204032027777137836043662020707595556264018525880784406918290641249515082189298559149176184502808489120072844992687392807287776735971418347270261896375014971824691165077613379859095700097330459748808428401797429100642458691817195118746121515172654632282216869987549182422433637259085141865462043576798423387184774447920739934236584823824281198163815010674810451660377306056201619676256133844143603833904414952634432190114657544454178424020924616515723350778707749817125772467962926386356373289912154831438167899885040445364023527381951378636564391212010397122822120720357
TOTAL = 2**20
TRANSACTIONS_PER_BLOCK = 10**4

def print_size(num):
    print(sizeof_fmt(math.log(1 + num, 2) // 8))

def sizeof_fmt(num, suffix='B'):
    for unit in ['','Ki','Mi','Gi','Ti','Pi','Ei','Zi']:
        if abs(num) < 1024.0:
            return "%3.1f%s%s" % (num, unit, suffix)
        num /= 1024.0
    return "%.1f%s%s" % (num, 'Yi', suffix)

old_pow = pow

def pow(a, b):
    print_size(b)
    return old_pow(a, b, MODULUS)

def prod(iterable):
    return reduce(operator.mul, iterable, 1)

def hash(x):
    return blake2s(x).digest()[:32]

def sieve_for_primes_to(n):
    size = n//2
    sieve = [1]*size
    limit = int(n**0.5)
    for i in range(1,limit):
        if sieve[i]:
            val = 2*i+1
            tmp = ((size-1) - i)//val
            sieve[i+val::val] = [0]*tmp
    return sieve

def sieve_for_primes(numprimes):
    target = 100 + 2*numprimes*math.ceil(math.log(numprimes))
    primes = [2] + [i*2+1 for i, v in enumerate(sieve_for_primes_to(target)) if v and i>0]
    assert(numprimes < len(primes))
    return primes[0:TOTAL]

def get_B_value(base, result):
    a = base.to_bytes(1024, 'big')
    b = result.to_bytes(1024, 'big')
    return int.from_bytes(
        hash(a + b),
        'big'
    )

# prove knowledge of exponent
def prove_exponentiation(base, exponent, result):
    B = get_B_value(base, result)
    b = pow(base, exponent // B)
    remainder = exponent % B
    return (b, remainder)

def verify_proof(base, result, b, remainder):
    B = get_B_value(base, result)
    return pow(b, B) * pow(base, remainder) % MODULUS == result

primes = sieve_for_primes(TOTAL)

def fast_prod(elems):
    return fast_prod_range(0, len(elems), elems)

def fast_prod_range(start, end, elems):
    assert(start < end)
    if (end - start) < 10:
        ret = 1
        for i in range(start, end):
            ret *= elems[i]
        return ret
    else:
        mid = (start + end) // 2
        return fast_prod_range(start, mid, elems) * fast_prod_range(mid, end, elems)

times_touched = defaultdict(int)

for i in range(5):
    print("block #", i)
    coins = random.sample(primes, TRANSACTIONS_PER_BLOCK)

    for coin in coins:
        times_touched[coin] += 1

factors = []

for k, v in times_touched.items():
    factors += [k**v]

n = len(factors)

total_exponent = fast_prod(factors)
print_size(total_exponent)
final_accumulator = pow(3, total_exponent)

print("computing half products...")

B0 = pow(3, fast_prod(factors[n//2:n]))
B1 = pow(3, fast_prod(factors[0:n//2]))

print("computing quarter products...")

B00 = pow(B0, fast_prod(factors[n//4:n//2]))
B01 = pow(B0, fast_prod(factors[0:n//4]))
B10 = pow(B1, fast_prod(factors[n//2+n//4:n]))
B11 = pow(B1, fast_prod(factors[n//2:n//2+n//4]))

for i in range(0, n//4):
    print(f"proving {i}")

    # todo: use B-factors to speed up proof generation
    # todo: exclusion proofs

    factor = factors[i]
    cofactor = total_exponent // factor

    b, remainder = prove_exponentiation(pow(3,factor), cofactor, final_accumulator)
    assert(verify_proof(pow(3,factor), final_accumulator, b, remainder))



