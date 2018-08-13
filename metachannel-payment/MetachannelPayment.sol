pragma solidity 0.5;

uint256 TIMEOUT = 100;

contract MetachannelPayment {

  address intermediary;
  address[2] public owners;
  uint256 public balance; // balance of owners[0]

  bool public isFinal;
  uint256 public finalizesAt;

  uint256 nonce = 0;

  constructor(address[2] _owners) public {
    owners = _owners;
    finalizesAt = block.number + TIMEOUT;
  }

  function removeIntermediary(
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) public {
    bytes32 digest = keccak256(abi.encode(intermediary, owners));
    require(intermediary == ecrecover(digest, v[i], r[i], s[i]));
    intermediary = 0x0;
  }

  function update(
    uint8[] v,
    bytes32[] r,
    bytes32[] s,
    uint256 _balance,
    uint256 _nonce
  ) public {

    require(!isFinal);
    require(_nonce > nonce);
    require(intermediary == 0);

    bytes32 digest = keccak256(_balances, _nonce);

    for (uint256 i = 0; i < owners.length; i++) {
      require(owners[i] == ecrecover(digest, v[i], r[i], s[i]));
    }

    balance = _balance;

    nonce = _nonce;
    finalizesAt = block.number + 10;
  }

  function finalize () public {
    require(block.number >= finalizesAt);
    isFinal = true;
  }

}
