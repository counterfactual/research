def byte(n):
  return bytes([n])

def rlp_encode_bytes(x):
  if len(x) == 1 and x < b'\x80':
    # For a single byte whose value is in the [0x00, 0x7f] range,
    # that byte is its own RLP encoding.
    return x
  elif len(x) < 56:
    # Otherwise, if a string is 0-55 bytes long, the RLP encoding
    # consists of a single byte with value 0x80 plus the length of
    # the string followed by the string. The range of the first
    # byte is thus [0x80, 0xb7].
    return byte(len(x) + 0x80) + x
  else:
    length = to_binary(len(x))
    # If a string is more than 55 bytes long, the RLP encoding
    # consists of a single byte with value 0xb7 plus the length in
    # bytes of the length of the string in binary form, followed by
    # the length of the string, followed by the string. For example,
    # a length-1024 string would be encoded as \xb9\x04\x00 followed
    # by the string. The range of the first byte is thus [0xb8, 0xbf].
    return byte(len(length) + 0xb7) + length + x

def rlp_encode_list(xs):
  sx = b''.join(rlp_encode(x) for x in xs)
  if len(sx) < 56:
    # If the total payload of a list (i.e. the combined length of all
    # its items being RLP encoded) is 0-55 bytes long, the RLP encoding
    # consists of a single byte with value 0xc0 plus the length of the
    # list followed by the concatenation of the RLP encodings of the
    # items. The range of the first byte is thus [0xc0, 0xf7].
    return byte(len(sx) + 0xc0) + sx
  else:
    length = to_binary(len(sx))
    # If the total payload of a list is more than 55 bytes long, the
    # RLP encoding consists of a single byte with value 0xf7 plus the
    # length in bytes of the length of the payload in binary form,
    # followed by the length of the payload, followed by the concatenation
    # of the RLP encodings of the items. The range of the first byte is
    # thus [0xf8, 0xff].
    return byte(len(length) + 0xf7) + length + sx

def rlp_encode(x):
  if isinstance(x,bytes):
    return rlp_encode_bytes(x)
  elif isinstance(x,list):
    return rlp_encode_list(x)
  else:
    return "unknown type "

# encodes an integer as bytes, big-endian
def to_binary(n):
  return n.to_bytes((n.bit_length() + 7) // 8, 'big')

assert(rlp_encode(b'dog').hex() == '83646f67')
assert(rlp_encode([[], [[]], [[], [[]]]]).hex() == 'c7c0c1c0c3c0c1c0')
