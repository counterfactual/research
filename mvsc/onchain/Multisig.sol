pragma solidity ^0.4.17;

contract Multisig {

  address[] public owners;

  function constructor(address[] _owners) public {
    owners = _owners;
  }

  function executeDelegate(address to, bytes data, uint8[] v, bytes32[] r, bytes32[] s) public {

    bytes32 digest = keccak256(this, to, data);

    for (uint256 i = 0; i < owners.length; i++) {
      require(owners[i] == ecrecover(transactionHash, v[i], r[i], s[i]));
    }

    assembly {
      delegatecall(not(0), to, add(data, 0x20), mload(data), 0, 0)
    }

  }

  function () public payable {}

}
