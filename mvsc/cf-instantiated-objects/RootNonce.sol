pragma solidity ^0.4.17;

contract RootNonce {

  address public owners;
  uint256 public instanceNonce;

  uint256 public latestNonce;

  constructor(uint256 _instanceNonce, address[] _owners) public {
    instanceNonce = _instanceNonce;
    owners = _owners;
  }

  function update(uint256 nonce, uint8[] v, bytes32[] r, bytes32[] s) public {

    require(nonce > latestNonce);

    bytes32 digest = keccak256(instanceNonce, nonce);

    for (uint256 i = 0; i < owners.length; i++) {
      require(owners[i] == ecrecover(digest, v[i], r[i], s[i]));
    }

    latestNonce = nonce;
  }

}
