pragma solidity 0.4.24;

contract Payment {

  uint256 TIMEOUT = 100;

  address[] public owners;
  uint256[] public balances;

  bool public isFinal;
  uint256 public finalizesAt;

  uint256 nonce = 0;

  constructor(address[] _owners) public {
    owners = _owners;
    finalizesAt = block.number + TIMEOUT;
  }

  function update(uint8[] v, bytes32[] r, bytes32[] s, uint256[] _balances, uint256 _nonce) public {

    require(!isFinal);
    require(_nonce > nonce);

    bytes32 digest = keccak256(abi.encode(_balances, _nonce));

    for (uint256 i = 0; i < owners.length; i++) {
      require(owners[i] == ecrecover(digest, v[i], r[i], s[i]));
    }

    balances = _balances;

    nonce = _nonce;
    finalizesAt = block.number + 10;
  }

  function finalize () public {
    require(block.number >= finalizesAt);
    isFinal = true;
  }

  function numOwners() public view returns(uint256) {
    return owners.length;
  }

}
