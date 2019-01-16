import sha3

def keccak256(x):
  k = sha3.keccak_256()
  k.update(x)
  return k.hexdigest()
