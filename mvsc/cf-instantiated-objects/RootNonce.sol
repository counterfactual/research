pragma solidity 0.4.24;

contract RootNonce {

  address[] public owners;
  uint256 public instanceNonce;

  uint256 public latestNonce;

  bool public isFinal;
  uint256 public finalizesAt;

  constructor(uint256 _instanceNonce, address[] _owners) public {
    instanceNonce = _instanceNonce;
    owners = _owners;
  }

  function update(uint256 nonce, uint8[] v, bytes32[] r, bytes32[] s) public {

    require(nonce > latestNonce);

    bytes32 digest = keccak256(abi.encode(instanceNonce, nonce));

    for (uint256 i = 0; i < owners.length; i++) {
      require(owners[i] == ecrecover(digest, v[i], r[i], s[i]));
    }

    latestNonce = nonce;

    finalizesAt = block.number + 10;
  }

  function finalizedNonce() public view returns (uint256){
    require(block.number >= finalizesAt);
    return latestNonce;
  }

}
